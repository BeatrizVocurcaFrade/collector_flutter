import 'package:flutter/foundation.dart';

import '../data/models/telemetry_model.dart';

class Analyzer {
  final double frameThresholdMs;
  Analyzer({this.frameThresholdMs = 16.6});

  static const int _minFrameSamples = 10;

  // Guardar histórico simples para média móvel de memória
  static double? _lastMemoryMB;

  AnalysisResult analyzeTelemetry(TelemetryModel t) {
    final frames = t.frameTimings;
    if (frames.isEmpty) {
      return AnalysisResult.empty();
    }

    // Só analisa se tiver frames suficientes
    if (frames.length < _minFrameSamples) {
      return AnalysisResult.empty(
        note:
            'Coletando dados iniciais (${frames.length}/$_minFrameSamples frames)',
      );
    }

    final avgFrame =
        frames.map((f) => f.totalSpan.inMilliseconds).reduce((a, b) => a + b) /
        frames.length;
    final fpsApprox = avgFrame > 0 ? 1000.0 / avgFrame : 0.0;
    final effectiveThreshold =
        kReleaseMode ? frameThresholdMs : frameThresholdMs * 3;

    // Em debug/profile, tolera frames até ~50 ms
    final longFrames =
        frames
            .where((f) => f.totalSpan.inMilliseconds > effectiveThreshold)
            .length;

    final memoryBytes = t.memoryInfo?.currentRssInBytes ?? 0;
    final memoryMB = memoryBytes / (1024 * 1024);

    // suaviza a leitura de memória
    final smoothedMemory =
        _lastMemoryMB != null
            ? (_lastMemoryMB! * 0.7 + memoryMB * 0.3)
            : memoryMB;
    _lastMemoryMB = smoothedMemory;

    final networkRequests = t.networkEvents.length;
    final issues = <String>[];

    // FPS thresholds mais realistas
    if (fpsApprox < 48 && frames.length > _minFrameSamples) {
      issues.add('FPS abaixo do ideal (${fpsApprox.toStringAsFixed(1)})');
    }
    if (longFrames > 5) {
      issues.add('Jank detectado: $longFrames frames longos');
    }
    // Memória só alerta se realmente alto e já estabilizado
    // Limite dinâmico conforme modo de execução
    final isDebug = !kReleaseMode;
    final memoryLimitMB = isDebug ? 600 : 300;

    if (smoothedMemory > memoryLimitMB) {
      issues.add(
        'Uso de memória elevado (${smoothedMemory.toStringAsFixed(1)} MB)',
      );
    }
    // Se a memória está dentro de faixa normal de debug, não considerar como problema
    if (isDebug && smoothedMemory < 500) {
      issues.removeWhere((i) => i.contains('memória'));
    }
    return AnalysisResult(
      estimatedFps: fpsApprox,
      avgFrameMs: avgFrame,
      longFrames: longFrames,
      memoryBytes: memoryBytes,
      networkRequests: networkRequests,
      issues: issues,
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

  AnalysisResult({
    required this.estimatedFps,
    required this.avgFrameMs,
    required this.longFrames,
    required this.memoryBytes,
    required this.networkRequests,
    required this.issues,
    this.note,
  });

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
}
