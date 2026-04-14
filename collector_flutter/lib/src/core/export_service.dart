import 'dart:convert';

import '../data/models/telemetry_model.dart';
import 'analyzer.dart';
import 'recommender.dart';

/// Serializa uma sessão de telemetria para JSON ou CSV.
///
/// Não possui dependências externas além de [dart:convert] — pode ser usado
/// em testes de unidade sem necessidade de um device físico.
class ExportService {
  /// Exporta [model] + [analysis] + [recommendations] como JSON indentado.
  String toJson({
    required TelemetryModel model,
    required AnalysisResult analysis,
    required List<Recommendation> recommendations,
  }) {
    final networkStats = analysis.networkStats.requestCount == 0 &&
            model.networkEvents.isNotEmpty
        ? NetworkStats.compute(model.networkEvents)
        : analysis.networkStats;

    final map = {
      'session': {
        'start': model.sessionStart.toIso8601String(),
        'capturedAt': model.capturedAt.toIso8601String(),
        'durationSeconds': model.sessionDuration.inSeconds,
        'sampleDurationMs': model.sampleDuration.inMilliseconds,
        'rebuildCount': model.rebuildCount,
        'totalFrameCount': model.totalFrameCount,
        'totalNetworkRequests': model.totalNetworkRequests,
      },
      'frames': {
        'count': model.frameTimings.length,
        'recentCount': model.recentFrameTimings.length,
        'avgMs': _round(analysis.avgFrameMs),
        'p50Ms': _round(analysis.frameStats.p50Ms),
        'p95Ms': _round(analysis.frameStats.p95Ms),
        'p99Ms': _round(analysis.frameStats.p99Ms),
        'stdDevMs': _round(analysis.frameStats.stdDevMs),
        'minMs': _round(analysis.frameStats.minMs),
        'maxMs': _round(analysis.frameStats.maxMs),
        'longFrames': analysis.longFrames,
        'jankRate': _round(analysis.jankRate),
        'targetFps': _round(analysis.targetFps),
        'frameBudgetMs': _round(analysis.frameBudgetMs),
        'confidence': analysis.confidence.name,
      },
      'memory': {
        'currentMB': _round(analysis.memoryStats.currentRssMB),
        'heapMB': _round(analysis.memoryStats.heapUsageMB),
        'peakMB': _round(analysis.memoryStats.peakRssMB),
        'trendMBperMin': _round(analysis.memoryStats.trendMBperMin),
        'samples': analysis.memoryStats.sampleCount,
      },
      'network': {
        'totalRequests': networkStats.requestCount,
        'windowRequests': model.networkEventsInWindow.length,
        'failedRequests': networkStats.failedRequests,
        'avgDurationMs': _round(networkStats.avgDurationMs),
        'p95DurationMs': _round(networkStats.p95DurationMs),
        'totalRequestBytes': networkStats.totalRequestBytes,
        'totalResponseBytes': networkStats.totalResponseBytes,
        'events': model.networkEvents
            .map(
              (e) => {
                'url': e.url,
                'method': e.method,
                'statusCode': e.statusCode,
                'requestBytes': e.requestBytes,
                'responseBytes': e.responseBytes,
                'bytes': e.bytes,
                'durationMs': e.duration.inMilliseconds,
                'timestamp': e.timestamp.toIso8601String(),
                if (e.error != null) 'error': e.error,
              },
            )
            .toList(),
      },
      'customEvents': {
        'latest': model.customEvents.map(
          (key, value) => MapEntry(key, _jsonSafe(value)),
        ),
        'events': model.customEventLog
            .map(
              (event) => {
                'name': event.name,
                'value': _jsonSafe(event.value),
                'timestamp': event.timestamp.toIso8601String(),
              },
            )
            .toList(),
      },
      'analysis': {
        'estimatedFps': _round(analysis.estimatedFps),
        'note': analysis.note,
        'issues': analysis.issues,
      },
      'recommendations': recommendations
          .map(
            (r) => {
              'title': r.title,
              'severity': r.severity.name,
              'detail': r.detail,
            },
          )
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(map);
  }

  /// Exporta os frame timings como CSV para análise em planilha.
  ///
  /// Colunas: index, totalMs, buildMs, rasterMs
  String frameTimingsToCsv(TelemetryModel model) {
    final frames = model.recentFrameTimings.isNotEmpty
        ? model.recentFrameTimings
        : model.frameTimings;
    final buf = StringBuffer();
    buf.writeln('index,totalMs,buildMs,rasterMs');
    for (var i = 0; i < frames.length; i++) {
      final f = frames[i];
      final total = f.totalSpan.inMicroseconds / 1000.0;
      final build = f.buildDuration.inMicroseconds / 1000.0;
      final raster = f.rasterDuration.inMicroseconds / 1000.0;
      buf.writeln('$i,${_round(total)},${_round(build)},${_round(raster)}');
    }
    return buf.toString();
  }

  double _round(double v) => double.parse(v.toStringAsFixed(3));

  dynamic _jsonSafe(dynamic value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    if (value is DateTime) return value.toIso8601String();
    if (value is Iterable) {
      return value.map(_jsonSafe).toList(growable: false);
    }
    if (value is Map) {
      return value.map(
        (key, value) => MapEntry(key.toString(), _jsonSafe(value)),
      );
    }
    return value.toString();
  }
}
