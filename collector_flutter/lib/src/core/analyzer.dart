import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/models/telemetry_model.dart';

double _percentile(List<double> sorted, double p) {
  if (sorted.isEmpty) return 0;
  final index = (p / 100.0) * (sorted.length - 1);
  final lower = index.floor();
  final upper = index.ceil();
  if (lower == upper) return sorted[lower];
  final frac = index - lower;
  return sorted[lower] * (1 - frac) + sorted[upper] * frac;
}

class PerformanceBudget {
  final double targetFrameRate;
  final double memoryWarningMB;
  final int networkRequestWarning;
  final double networkLatencyWarningMs;
  final int minFrameSamples;

  const PerformanceBudget({
    this.targetFrameRate = 60,
    this.memoryWarningMB = 300,
    this.networkRequestWarning = 50,
    this.networkLatencyWarningMs = 1500,
    this.minFrameSamples = 10,
  });

  double get frameBudgetMs => 1000.0 / targetFrameRate;
  double get warningFrameMs => frameBudgetMs * 1.2;
  double get severeFrameMs => frameBudgetMs * 2.0;

  PerformanceBudget copyWith({
    double? targetFrameRate,
    double? memoryWarningMB,
    int? networkRequestWarning,
    double? networkLatencyWarningMs,
    int? minFrameSamples,
  }) {
    return PerformanceBudget(
      targetFrameRate: targetFrameRate ?? this.targetFrameRate,
      memoryWarningMB: memoryWarningMB ?? this.memoryWarningMB,
      networkRequestWarning:
          networkRequestWarning ?? this.networkRequestWarning,
      networkLatencyWarningMs:
          networkLatencyWarningMs ?? this.networkLatencyWarningMs,
      minFrameSamples: minFrameSamples ?? this.minFrameSamples,
    );
  }
}

enum MetricConfidence { none, warmingUp, stable }

/// Estatisticas detalhadas de frame timing para dashboard e exportacao.
class FrameStats {
  final double p50Ms;
  final double p95Ms;
  final double p99Ms;
  final double stdDevMs;
  final double avgMs;
  final double minMs;
  final double maxMs;
  final int sampleCount;

  const FrameStats({
    required this.p50Ms,
    required this.p95Ms,
    required this.p99Ms,
    required this.stdDevMs,
    required this.avgMs,
    required this.minMs,
    required this.maxMs,
    required this.sampleCount,
  });

  factory FrameStats.empty() => const FrameStats(
        p50Ms: 0,
        p95Ms: 0,
        p99Ms: 0,
        stdDevMs: 0,
        avgMs: 0,
        minMs: 0,
        maxMs: 0,
        sampleCount: 0,
      );

  static FrameStats compute(List<double> frameMs) {
    if (frameMs.isEmpty) return FrameStats.empty();
    final sorted = List<double>.from(frameMs)..sort();
    final n = sorted.length;
    final avg = sorted.reduce((a, b) => a + b) / n;
    final variance =
        sorted.map((v) => pow(v - avg, 2)).reduce((a, b) => a + b) / n;
    return FrameStats(
      p50Ms: _percentile(sorted, 50),
      p95Ms: _percentile(sorted, 95),
      p99Ms: _percentile(sorted, 99),
      stdDevMs: sqrt(variance),
      avgMs: avg,
      minMs: sorted.first,
      maxMs: sorted.last,
      sampleCount: n,
    );
  }
}

class MemoryStats {
  final double currentRssMB;
  final double heapUsageMB;
  final double peakRssMB;
  final double trendMBperMin;
  final int sampleCount;

  const MemoryStats({
    required this.currentRssMB,
    required this.heapUsageMB,
    required this.peakRssMB,
    required this.trendMBperMin,
    required this.sampleCount,
  });

  factory MemoryStats.empty() => const MemoryStats(
        currentRssMB: 0,
        heapUsageMB: 0,
        peakRssMB: 0,
        trendMBperMin: 0,
        sampleCount: 0,
      );

  static MemoryStats compute(
    List<MemoryInfo> history, {
    MemoryInfo? current,
  }) {
    final samples = history.isNotEmpty
        ? List<MemoryInfo>.from(history)
        : [
            if (current != null) current,
          ];
    if (samples.isEmpty) return MemoryStats.empty();

    final last = current ?? samples.last;
    final peak = samples.map((s) => s.currentRssMB).reduce((a, b) => max(a, b));
    var trend = 0.0;

    if (samples.length >= 2) {
      final first = samples.first;
      final elapsed = samples.last.timestamp.difference(first.timestamp);
      final minutes = elapsed.inMilliseconds / Duration.millisecondsPerMinute;
      if (minutes > 0) {
        trend = (samples.last.currentRssMB - first.currentRssMB) / minutes;
      }
    }

    return MemoryStats(
      currentRssMB: last.currentRssMB,
      heapUsageMB: last.heapUsageMB,
      peakRssMB: peak,
      trendMBperMin: trend,
      sampleCount: samples.length,
    );
  }
}

class NetworkStats {
  final int requestCount;
  final int failedRequests;
  final int totalRequestBytes;
  final int totalResponseBytes;
  final double avgDurationMs;
  final double p95DurationMs;

  const NetworkStats({
    required this.requestCount,
    required this.failedRequests,
    required this.totalRequestBytes,
    required this.totalResponseBytes,
    required this.avgDurationMs,
    required this.p95DurationMs,
  });

  factory NetworkStats.empty() => const NetworkStats(
        requestCount: 0,
        failedRequests: 0,
        totalRequestBytes: 0,
        totalResponseBytes: 0,
        avgDurationMs: 0,
        p95DurationMs: 0,
      );

  static NetworkStats compute(List<NetworkEvent> events) {
    if (events.isEmpty) return NetworkStats.empty();

    final durations = events
        .map((event) => event.duration.inMicroseconds / 1000.0)
        .toList()
      ..sort();
    final totalDuration = durations.reduce((a, b) => a + b);

    return NetworkStats(
      requestCount: events.length,
      failedRequests: events.where((event) => event.failed).length,
      totalRequestBytes:
          events.fold(0, (sum, event) => sum + event.requestBytes),
      totalResponseBytes:
          events.fold(0, (sum, event) => sum + event.responseBytes),
      avgDurationMs: totalDuration / events.length,
      p95DurationMs: _percentile(durations, 95),
    );
  }

  double get failureRate =>
      requestCount == 0 ? 0 : failedRequests / requestCount;
}

class Analyzer {
  final PerformanceBudget budget;

  Analyzer({
    double frameThresholdMs = 16.6,
    PerformanceBudget? budget,
  }) : budget = budget ??
            PerformanceBudget(
              targetFrameRate: 1000.0 / frameThresholdMs,
              memoryWarningMB: kReleaseMode ? 300 : 600,
            );

  double get frameThresholdMs => budget.frameBudgetMs;

  AnalysisResult analyzeTelemetry(TelemetryModel telemetry) {
    final currentFrames = telemetry.frameTimings;
    final framesForStats =
        currentFrames.isNotEmpty ? currentFrames : telemetry.recentFrameTimings;
    final frameMsList = framesForStats
        .map((frame) => frame.totalSpan.inMicroseconds / 1000.0)
        .toList();
    final stats = FrameStats.compute(frameMsList);
    final confidence = _confidenceFor(currentFrames.length);
    final estimatedFps = _estimateFps(
      currentFrames: currentFrames.length,
      sampleDuration: telemetry.sampleDuration,
      frameStats: stats,
    );
    final longFrames =
        frameMsList.where((frameMs) => frameMs > budget.warningFrameMs).length;
    final jankRate =
        stats.sampleCount == 0 ? 0.0 : longFrames / stats.sampleCount;
    final memoryStats = MemoryStats.compute(
      telemetry.memoryHistory,
      current: telemetry.memoryInfo,
    );
    final networkStats = NetworkStats.compute(telemetry.networkEvents);
    final issues = _findIssues(
      estimatedFps: estimatedFps,
      confidence: confidence,
      frameStats: stats,
      longFrames: longFrames,
      jankRate: jankRate,
      memoryStats: memoryStats,
      networkStats: networkStats,
    );

    return AnalysisResult(
      estimatedFps: estimatedFps,
      avgFrameMs: stats.avgMs,
      longFrames: longFrames,
      memoryBytes: telemetry.memoryInfo?.currentRssInBytes ?? 0,
      networkRequests: networkStats.requestCount,
      issues: issues,
      note: _noteFor(confidence, currentFrames.length),
      frameStats: stats,
      memoryTrendMBperMin: memoryStats.trendMBperMin,
      memoryStats: memoryStats,
      networkStats: networkStats,
      confidence: confidence,
      sampleDuration: telemetry.sampleDuration,
      targetFps: budget.targetFrameRate,
      frameBudgetMs: budget.frameBudgetMs,
      jankRate: jankRate,
      totalFrameCount: telemetry.totalFrameCount,
    );
  }

  MetricConfidence _confidenceFor(int currentFrameCount) {
    if (currentFrameCount == 0) return MetricConfidence.none;
    if (currentFrameCount < budget.minFrameSamples) {
      return MetricConfidence.warmingUp;
    }
    return MetricConfidence.stable;
  }

  double _estimateFps({
    required int currentFrames,
    required Duration sampleDuration,
    required FrameStats frameStats,
  }) {
    if (currentFrames == 0) return 0;
    if (currentFrames > 0 && sampleDuration.inMilliseconds >= 250) {
      return currentFrames *
          Duration.millisecondsPerSecond /
          sampleDuration.inMilliseconds;
    }
    if (frameStats.avgMs <= 0) return 0;
    return min(budget.targetFrameRate, 1000.0 / frameStats.avgMs);
  }

  List<String> _findIssues({
    required double estimatedFps,
    required MetricConfidence confidence,
    required FrameStats frameStats,
    required int longFrames,
    required double jankRate,
    required MemoryStats memoryStats,
    required NetworkStats networkStats,
  }) {
    final issues = <String>[];
    final hasStableFrames = confidence == MetricConfidence.stable;

    if (hasStableFrames && estimatedFps > 0) {
      final lowFpsLimit = budget.targetFrameRate * 0.85;
      if (estimatedFps < lowFpsLimit) {
        issues.add(
          'FPS abaixo do alvo (${estimatedFps.toStringAsFixed(1)}/${budget.targetFrameRate.toStringAsFixed(0)})',
        );
      }
    }

    if (hasStableFrames && frameStats.p95Ms > budget.warningFrameMs) {
      issues.add(
        'P95 de frame acima do orçamento (${frameStats.p95Ms.toStringAsFixed(1)} ms)',
      );
    }

    if (hasStableFrames && longFrames >= 3 && jankRate > 0.05) {
      issues.add(
        'Jank detectado: $longFrames frames longos (${(jankRate * 100).toStringAsFixed(1)}%)',
      );
    }

    if (memoryStats.currentRssMB > budget.memoryWarningMB) {
      issues.add(
        'Uso de memória elevado (${memoryStats.currentRssMB.toStringAsFixed(1)} MB)',
      );
    }

    if (memoryStats.sampleCount >= 3 && memoryStats.trendMBperMin > 30) {
      issues.add(
        'Possível crescimento de memória: +${memoryStats.trendMBperMin.toStringAsFixed(1)} MB/min',
      );
    }

    if (networkStats.requestCount > budget.networkRequestWarning) {
      issues.add('Muitas requisições de rede (${networkStats.requestCount})');
    }

    if (networkStats.failedRequests > 0) {
      issues.add('Falhas de rede (${networkStats.failedRequests})');
    }

    if (networkStats.p95DurationMs > budget.networkLatencyWarningMs) {
      issues.add(
        'Latência de rede elevada (P95 ${networkStats.p95DurationMs.toStringAsFixed(0)} ms)',
      );
    }

    return issues;
  }

  String? _noteFor(MetricConfidence confidence, int currentFrameCount) {
    return switch (confidence) {
      MetricConfidence.none => 'Aguardando frames renderizados',
      MetricConfidence.warmingUp =>
        'Coletando dados iniciais ($currentFrameCount/${budget.minFrameSamples} frames)',
      MetricConfidence.stable => null,
    };
  }
}

class AnalysisResult {
  final double estimatedFps;
  final double avgFrameMs;
  final int longFrames;
  final int memoryBytes;
  final int networkRequests;
  final List<String> issues;
  final String? note;
  final FrameStats frameStats;
  final double memoryTrendMBperMin;
  final MemoryStats memoryStats;
  final NetworkStats networkStats;
  final MetricConfidence confidence;
  final Duration sampleDuration;
  final double targetFps;
  final double frameBudgetMs;
  final double jankRate;
  final int totalFrameCount;

  AnalysisResult({
    required this.estimatedFps,
    required this.avgFrameMs,
    required this.longFrames,
    required this.memoryBytes,
    required this.networkRequests,
    required this.issues,
    this.note,
    FrameStats? frameStats,
    this.memoryTrendMBperMin = 0,
    MemoryStats? memoryStats,
    NetworkStats? networkStats,
    this.confidence = MetricConfidence.none,
    this.sampleDuration = Duration.zero,
    this.targetFps = 60,
    double? frameBudgetMs,
    this.jankRate = 0,
    this.totalFrameCount = 0,
  })  : frameStats = frameStats ?? FrameStats.empty(),
        memoryStats = memoryStats ?? MemoryStats.empty(),
        networkStats = networkStats ?? NetworkStats.empty(),
        frameBudgetMs = frameBudgetMs ?? (1000.0 / targetFps);

  factory AnalysisResult.empty({String? note}) => AnalysisResult(
        estimatedFps: 0,
        avgFrameMs: 0,
        longFrames: 0,
        memoryBytes: 0,
        networkRequests: 0,
        issues: const [],
        note: note,
      );

  bool get hasIssues => issues.isNotEmpty;
  bool get hasStableFrameData => confidence == MetricConfidence.stable;
  double get memoryMB => memoryBytes / (1024 * 1024);
}
