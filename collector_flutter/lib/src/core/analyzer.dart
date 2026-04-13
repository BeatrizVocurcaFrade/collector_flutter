import 'dart:math';
import 'package:flutter/foundation.dart';

import '../data/models/telemetry_model.dart';

/// Calcula percentil de uma lista já ordenada (in-place sort feito pelo caller).
double _percentile(List<double> sorted, double p) {
  if (sorted.isEmpty) return 0;
  final index = (p / 100.0) * (sorted.length - 1);
  final lower = index.floor();
  final upper = index.ceil();
  if (lower == upper) return sorted[lower];
  final frac = index - lower;
  return sorted[lower] * (1 - frac) + sorted[upper] * frac;
}

/// Estatísticas detalhadas de frame timing para uso no dashboard e TCC.
class FrameStats {
  final double p50Ms;
  final double p95Ms;
  final double p99Ms;
  final double stdDevMs;
  final double avgMs;
  final int sampleCount;

  const FrameStats({
    required this.p50Ms,
    required this.p95Ms,
    required this.p99Ms,
    required this.stdDevMs,
    required this.avgMs,
    required this.sampleCount,
  });

  factory FrameStats.empty() => const FrameStats(
    p50Ms: 0,
    p95Ms: 0,
    p99Ms: 0,
    stdDevMs: 0,
    avgMs: 0,
    sampleCount: 0,
  );

  static FrameStats compute(List<double> frameMs) {
    if (frameMs.isEmpty) return FrameStats.empty();
    final sorted = List<double>.from(frameMs)..sort();
    final n = sorted.length;
    final avg = sorted.reduce((a, b) => a + b) / n;
    final variance = sorted.map((v) => pow(v - avg, 2)).reduce((a, b) => a + b) / n;
    return FrameStats(
      p50Ms: _percentile(sorted, 50),
      p95Ms: _percentile(sorted, 95),
      p99Ms: _percentile(sorted, 99),
      stdDevMs: sqrt(variance),
      avgMs: avg,
      sampleCount: n,
    );
  }
}

class Analyzer {
  final double frameThresholdMs;

  // Instance field (não static) para evitar contaminação entre instâncias
  double? _lastMemoryMB;
  final List<double> _memoryHistory = [];

  Analyzer({this.frameThresholdMs = 16.6});

  static const int _minFrameSamples = 10;

  AnalysisResult analyzeTelemetry(TelemetryModel t) {
    final frames = t.frameTimings;
    if (frames.isEmpty) {
      return AnalysisResult.empty();
    }

    if (frames.length < _minFrameSamples) {
      return AnalysisResult.empty(
        note: 'Coletando dados iniciais (${frames.length}/$_minFrameSamples frames)',
      );
    }

    final frameMsList =
        frames.map((f) => f.totalSpan.inMicroseconds / 1000.0).toList();

    final stats = FrameStats.compute(frameMsList);
    final avgFrame = stats.avgMs;
    final fpsApprox = avgFrame > 0 ? 1000.0 / avgFrame : 0.0;
    final effectiveThreshold = kReleaseMode ? frameThresholdMs : frameThresholdMs * 3;

    final longFrames = frames
        .where((f) => f.totalSpan.inMicroseconds / 1000.0 > effectiveThreshold)
        .length;

    final memoryBytes = t.memoryInfo?.currentRssInBytes ?? 0;
    final memoryMB = memoryBytes / (1024 * 1024);

    // Suavização exponencial da leitura de memória
    final smoothedMemory = _lastMemoryMB != null
        ? (_lastMemoryMB! * 0.7 + memoryMB * 0.3)
        : memoryMB;
    _lastMemoryMB = smoothedMemory;

    // Tendência de memória baseada nos últimos N pontos
    _memoryHistory.add(memoryMB);
    if (_memoryHistory.length > 10) _memoryHistory.removeAt(0);
    double memoryTrendMBperMin = 0;
    if (_memoryHistory.length >= 3) {
      final first = _memoryHistory.first;
      final last = _memoryHistory.last;
      // Assumindo coleta a cada 2s: (N-1) amostras × 2s = duração
      final durationSec = (_memoryHistory.length - 1) * 2.0;
      memoryTrendMBperMin = durationSec > 0
          ? ((last - first) / durationSec) * 60
          : 0;
    }

    final networkRequests = t.networkEvents.length;
    final issues = <String>[];

    final isDebug = !kReleaseMode;
    final fpsLimit = kReleaseMode ? 50.0 : 40.0;
    final memoryLimitMB = isDebug ? 600.0 : 300.0;

    if (fpsApprox < fpsLimit && frames.length > _minFrameSamples) {
      issues.add('FPS abaixo do ideal (${fpsApprox.toStringAsFixed(1)})');
    }
    if (longFrames > 5) {
      issues.add('Jank detectado: $longFrames frames longos');
    }
    if (smoothedMemory > memoryLimitMB) {
      issues.add('Uso de memória elevado (${smoothedMemory.toStringAsFixed(1)} MB)');
    }
    if (isDebug && smoothedMemory < 500) {
      issues.removeWhere((i) => i.contains('memória'));
    }
    if (memoryTrendMBperMin > 50) {
      issues.add('Possível leak: +${memoryTrendMBperMin.toStringAsFixed(1)} MB/min');
    }

    return AnalysisResult(
      estimatedFps: fpsApprox,
      avgFrameMs: avgFrame,
      longFrames: longFrames,
      memoryBytes: memoryBytes,
      networkRequests: networkRequests,
      issues: issues,
      frameStats: stats,
      memoryTrendMBperMin: memoryTrendMBperMin,
    );
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
  }) : frameStats = frameStats ?? FrameStats.empty();

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
  double get memoryMB => memoryBytes / (1024 * 1024);
}
