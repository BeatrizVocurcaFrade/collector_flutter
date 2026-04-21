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
  final int minSessionSeconds;

  /// Número mínimo de frames na janela atual para acionar alertas de FPS/jank/P95.
  /// Janelas com poucos frames (app idle, apenas monitoring) são ignoradas.
  final int minWindowFrames;

  /// Número mínimo de requests para considerar alertas de falha/latência.
  final int minNetworkSamples;

  /// Número mínimo de frames longos para alertar jank/P95 por overhead repetido.
  final int minJankLongFrames;

  /// Número mínimo de amostras para considerar tendência de memória confiável.
  final int minMemoryTrendSamples;

  /// Duração mínima da janela de memória para evitar spikes de inicialização.
  final int minMemoryTrendSeconds;

  /// Tempo mínimo de sessão antes de alertar CPU.
  final int minCpuSessionSeconds;

  const PerformanceBudget({
    this.targetFrameRate = 60,
    this.memoryWarningMB = 300,
    this.networkRequestWarning = 50,
    this.networkLatencyWarningMs = 1500,
    this.minFrameSamples = 10,
    this.minSessionSeconds = 6,
    this.minWindowFrames = 15,
    this.minNetworkSamples = 5,
    this.minJankLongFrames = 6,
    this.minMemoryTrendSamples = 5,
    this.minMemoryTrendSeconds = 60,
    this.minCpuSessionSeconds = 10,
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
    int? minSessionSeconds,
    int? minWindowFrames,
    int? minNetworkSamples,
    int? minJankLongFrames,
    int? minMemoryTrendSamples,
    int? minMemoryTrendSeconds,
    int? minCpuSessionSeconds,
  }) {
    return PerformanceBudget(
      targetFrameRate: targetFrameRate ?? this.targetFrameRate,
      memoryWarningMB: memoryWarningMB ?? this.memoryWarningMB,
      networkRequestWarning:
          networkRequestWarning ?? this.networkRequestWarning,
      networkLatencyWarningMs:
          networkLatencyWarningMs ?? this.networkLatencyWarningMs,
      minFrameSamples: minFrameSamples ?? this.minFrameSamples,
      minSessionSeconds: minSessionSeconds ?? this.minSessionSeconds,
      minWindowFrames: minWindowFrames ?? this.minWindowFrames,
      minNetworkSamples: minNetworkSamples ?? this.minNetworkSamples,
      minJankLongFrames: minJankLongFrames ?? this.minJankLongFrames,
      minMemoryTrendSamples:
          minMemoryTrendSamples ?? this.minMemoryTrendSamples,
      minMemoryTrendSeconds:
          minMemoryTrendSeconds ?? this.minMemoryTrendSeconds,
      minCpuSessionSeconds: minCpuSessionSeconds ?? this.minCpuSessionSeconds,
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
  final Duration sampleDuration;

  const MemoryStats({
    required this.currentRssMB,
    required this.heapUsageMB,
    required this.peakRssMB,
    required this.trendMBperMin,
    required this.sampleCount,
    this.sampleDuration = Duration.zero,
  });

  factory MemoryStats.empty() => const MemoryStats(
        currentRssMB: 0,
        heapUsageMB: 0,
        peakRssMB: 0,
        trendMBperMin: 0,
        sampleCount: 0,
        sampleDuration: Duration.zero,
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
    var sampleDuration = Duration.zero;

    if (samples.length >= 2) {
      final first = samples.first;
      sampleDuration = samples.last.timestamp.difference(first.timestamp);
      final minutes =
          sampleDuration.inMilliseconds / Duration.millisecondsPerMinute;
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
      sampleDuration: sampleDuration,
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
              memoryWarningMB: kReleaseMode ? 400 : 800,
            );

  double get frameThresholdMs => budget.frameBudgetMs;

  AnalysisResult analyzeTelemetry(TelemetryModel telemetry) {
    final currentFrames = telemetry.frameTimings;
    // Use only the current collection window for stats/jank — falling back to
    // recentFrameTimings contaminates idle windows with stale jank data.
    final frameMsList = currentFrames
        .map((frame) => frame.totalSpan.inMicroseconds / 1000.0)
        .toList();
    final stats = FrameStats.compute(frameMsList);
    final confidence = _confidenceFor(
      currentFrameCount: currentFrames.length,
      totalSessionFrames: telemetry.totalFrameCount,
      sessionAge: telemetry.sessionDuration,
    );
    final estimatedFps = _estimateFps(
      currentFrames: currentFrames.length,
      frameStats: stats,
    );
    final longFrames =
        frameMsList.where((frameMs) => frameMs > budget.warningFrameMs).length;
    final jankRate =
        stats.sampleCount == 0 ? 0.0 : longFrames / stats.sampleCount;
    // App idle: janela tem só 2-5 frames do próprio monitoring; métricas de
    // frame não são confiáveis até haver atividade real do usuário.
    final hasEnoughWindowFrames = frameMsList.length >= budget.minWindowFrames;
    final memoryStats = MemoryStats.compute(
      telemetry.memoryHistory,
      current: telemetry.memoryInfo,
    );
    final networkStats = NetworkStats.compute(telemetry.networkEvents);
    final issues = _findIssues(
      estimatedFps: estimatedFps,
      confidence: confidence,
      hasEnoughWindowFrames: hasEnoughWindowFrames,
      frameStats: stats,
      longFrames: longFrames,
      jankRate: jankRate,
      memoryStats: memoryStats,
      networkStats: networkStats,
      sessionAge: telemetry.sessionDuration,
      cpuUsagePercent: telemetry.cpuUsagePercent,
      batteryLevel: telemetry.batteryLevel,
      isCharging: telemetry.isCharging,
    );

    return AnalysisResult(
      estimatedFps: estimatedFps,
      avgFrameMs: stats.avgMs,
      longFrames: longFrames,
      memoryBytes: telemetry.memoryInfo?.currentRssInBytes ?? 0,
      networkRequests: networkStats.requestCount,
      issues: issues,
      note: _noteFor(
        confidence,
        telemetry.totalFrameCount,
        telemetry.sessionDuration,
      ),
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
      cpuUsagePercent: telemetry.cpuUsagePercent,
      batteryLevel: telemetry.batteryLevel,
      isCharging: telemetry.isCharging,
      hasEnoughWindowFrames: hasEnoughWindowFrames,
    );
  }

  MetricConfidence _confidenceFor({
    required int currentFrameCount,
    required int totalSessionFrames,
    required Duration sessionAge,
  }) {
    if (totalSessionFrames == 0) return MetricConfidence.none;
    if (totalSessionFrames < budget.minFrameSamples) {
      return MetricConfidence.warmingUp;
    }
    if (sessionAge.inSeconds < budget.minSessionSeconds) {
      return MetricConfidence.warmingUp;
    }
    return MetricConfidence.stable;
  }

  // Uses per-frame quality (1000/avgMs) so an idle Flutter app — which renders
  // very few frames because nothing is dirty — is not penalised with 0 fps.
  double _estimateFps({
    required int currentFrames,
    required FrameStats frameStats,
  }) {
    if (currentFrames == 0) return 0;
    if (frameStats.avgMs <= 0) return 0;
    return min(budget.targetFrameRate, 1000.0 / frameStats.avgMs);
  }

  List<String> _findIssues({
    required double estimatedFps,
    required MetricConfidence confidence,
    required bool hasEnoughWindowFrames,
    required FrameStats frameStats,
    required int longFrames,
    required double jankRate,
    required MemoryStats memoryStats,
    required NetworkStats networkStats,
    required Duration sessionAge,
    double cpuUsagePercent = -1.0,
    int batteryLevel = -1,
    bool isCharging = false,
  }) {
    final issues = <String>[];
    final hasStableFrames = confidence == MetricConfidence.stable;
    // Gate frame-based metrics on window size: idle windows (2-5 frames from
    // monitoring alone) produce misleading P95/FPS/jank readings.
    final canAnalyzeFrames = hasStableFrames && hasEnoughWindowFrames;
    final hasRepeatedLongFrames = longFrames >= budget.minJankLongFrames;
    final hasEnoughNetworkSamples =
        networkStats.requestCount >= budget.minNetworkSamples;
    final hasReliableMemoryTrend = memoryStats.sampleCount >=
            budget.minMemoryTrendSamples &&
        memoryStats.sampleDuration.inSeconds >= budget.minMemoryTrendSeconds;
    final canAnalyzeCpu = sessionAge.inSeconds >= budget.minCpuSessionSeconds;

    if (canAnalyzeFrames && estimatedFps > 0) {
      // 0.75 (45 fps for 60 fps target) gives headroom for the monitoring
      // overhead itself (vm_service queries, periodic setState, etc.).
      final lowFpsLimit = budget.targetFrameRate * 0.75;
      if (estimatedFps < lowFpsLimit) {
        issues.add(
          'FPS abaixo do alvo (${estimatedFps.toStringAsFixed(1)}/${budget.targetFrameRate.toStringAsFixed(0)})',
        );
      }
    }

    // Use severeFrameMs (2× budget ≈ 33 ms) to avoid flagging the small spikes
    // caused by the collector's own vm_service queries every ~1.8 s.
    if (canAnalyzeFrames &&
        hasRepeatedLongFrames &&
        frameStats.p95Ms > budget.severeFrameMs) {
      issues.add(
        'P95 de frame acima do orçamento (${frameStats.p95Ms.toStringAsFixed(1)} ms)',
      );
    }

    if (canAnalyzeFrames && hasRepeatedLongFrames && jankRate > 0.05) {
      issues.add(
        'Jank detectado: $longFrames frames longos (${(jankRate * 100).toStringAsFixed(1)}%)',
      );
    }

    // Absolute RSS is unreliable on Android (system libs inflate it by 200-300 MB).
    // Only the growth trend reliably signals a leak.
    if (hasReliableMemoryTrend && memoryStats.trendMBperMin > 30) {
      issues.add(
        'Possível crescimento de memória: +${memoryStats.trendMBperMin.toStringAsFixed(1)} MB/min',
      );
    }

    if (networkStats.requestCount > budget.networkRequestWarning) {
      issues.add('Muitas requisições de rede (${networkStats.requestCount})');
    }

    if (hasEnoughNetworkSamples && networkStats.failedRequests > 0) {
      issues.add('Falhas de rede (${networkStats.failedRequests})');
    }

    if (hasEnoughNetworkSamples &&
        networkStats.p95DurationMs > budget.networkLatencyWarningMs) {
      issues.add(
        'Latência de rede elevada (P95 ${networkStats.p95DurationMs.toStringAsFixed(0)} ms)',
      );
    }

    if (canAnalyzeCpu && cpuUsagePercent >= 0) {
      if (cpuUsagePercent > 80) {
        issues.add('CPU elevada (${cpuUsagePercent.toStringAsFixed(1)}%)');
      } else if (cpuUsagePercent > 60) {
        issues.add('CPU moderada (${cpuUsagePercent.toStringAsFixed(1)}%)');
      }
    }

    if (batteryLevel >= 0 && !isCharging && batteryLevel < 20) {
      issues.add('Bateria baixa ($batteryLevel%)');
    }

    return issues;
  }

  String? _noteFor(
    MetricConfidence confidence,
    int totalSessionFrames,
    Duration sessionAge,
  ) {
    if (confidence == MetricConfidence.none) {
      return 'Aguardando frames renderizados';
    }
    if (confidence == MetricConfidence.warmingUp) {
      if (totalSessionFrames < budget.minFrameSamples) {
        return 'Coletando dados iniciais ($totalSessionFrames/${budget.minFrameSamples} frames)';
      }
      final remaining = budget.minSessionSeconds - sessionAge.inSeconds;
      return 'Estabilizando métricas... (${remaining}s restantes)';
    }
    return null;
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

  /// Uso de CPU em % (0.0–100.0). -1.0 = indisponível.
  final double cpuUsagePercent;

  /// Nível de bateria em % (0–100). -1 = indisponível.
  final int batteryLevel;

  /// Indica se o dispositivo está carregando.
  final bool isCharging;

  /// Janela atual tem frames suficientes para análise confiável (>= minWindowFrames).
  /// False em app idle — apenas frames do próprio monitoring presentes.
  final bool hasEnoughWindowFrames;

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
    this.cpuUsagePercent = -1.0,
    this.batteryLevel = -1,
    this.isCharging = false,
    this.hasEnoughWindowFrames = false,
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
  bool get hasCpuData => cpuUsagePercent >= 0;
  bool get hasBatteryData => batteryLevel >= 0;
}
