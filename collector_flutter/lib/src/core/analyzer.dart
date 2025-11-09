import 'dart:ui';
import '../data/models/telemetry_model.dart';

/// Analisador simples de métricas para detectar jank, leaks e problemas.
class Analyzer {
  /// threshold de frame em ms (default 16.6 -> 60 FPS)
  final double frameThresholdMs;

  Analyzer({this.frameThresholdMs = 16.6});

  AnalysisResult analyzeTelemetry(TelemetryModel t) {
    final List<FrameTiming> frames = t.frameTimings;
    final longFrames =
        frames
            .where((f) => f.totalSpan.inMilliseconds > frameThresholdMs)
            .length;
    final avgFrame =
        frames.isEmpty
            ? 0.0
            : frames
                    .map((f) => f.totalSpan.inMilliseconds)
                    .reduce((a, b) => a + b) /
                frames.length;
    final fpsApprox = avgFrame > 0 ? 1000.0 / avgFrame : 0.0;

    final memory = t.memoryInfo?.currentRssInBytes ?? 0;
    final networkRequests = t.networkEvents.length;

    final issues = <String>[];
    if (fpsApprox < 45) {
      issues.add('FPS baixo (${fpsApprox.toStringAsFixed(1)})');
    }
    if (longFrames > 3) issues.add('Jank detectado: $longFrames frames longos');
    if (memory > 200 * 1024 * 1024) {
      issues.add(
        'Uso de memória alto (${(memory / (1024 * 1024)).toStringAsFixed(1)} MB)',
      );
    }

    return AnalysisResult(
      estimatedFps: fpsApprox,
      avgFrameMs: avgFrame,
      longFrames: longFrames,
      memoryBytes: memory,
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

  AnalysisResult({
    required this.estimatedFps,
    required this.avgFrameMs,
    required this.longFrames,
    required this.memoryBytes,
    required this.networkRequests,
    required this.issues,
  });
}
