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
    final map = {
      'session': {
        'start': model.sessionStart.toIso8601String(),
        'durationSeconds': model.sessionDuration.inSeconds,
        'rebuildCount': model.rebuildCount,
      },
      'frames': {
        'count': model.frameTimings.length,
        'avgMs': _round(analysis.avgFrameMs),
        'p50Ms': _round(analysis.frameStats.p50Ms),
        'p95Ms': _round(analysis.frameStats.p95Ms),
        'p99Ms': _round(analysis.frameStats.p99Ms),
        'stdDevMs': _round(analysis.frameStats.stdDevMs),
        'longFrames': analysis.longFrames,
      },
      'memory': {
        'currentMB': _round(analysis.memoryMB),
        'trendMBperMin': _round(analysis.memoryTrendMBperMin),
      },
      'network': {
        'totalRequests': model.networkEvents.length,
        'events': model.networkEvents
            .map(
              (e) => {
                'url': e.url,
                'method': e.method,
                'statusCode': e.statusCode,
                'bytes': e.bytes,
                'durationMs': e.duration.inMilliseconds,
                'timestamp': e.timestamp.toIso8601String(),
              },
            )
            .toList(),
      },
      'customEvents': model.customEvents,
      'analysis': {
        'estimatedFps': _round(analysis.estimatedFps),
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
    final buf = StringBuffer();
    buf.writeln('index,totalMs,buildMs,rasterMs');
    for (var i = 0; i < model.frameTimings.length; i++) {
      final f = model.frameTimings[i];
      final total = f.totalSpan.inMicroseconds / 1000.0;
      final build = f.buildDuration.inMicroseconds / 1000.0;
      final raster = f.rasterDuration.inMicroseconds / 1000.0;
      buf.writeln('$i,${_round(total)},${_round(build)},${_round(raster)}');
    }
    return buf.toString();
  }

  double _round(double v) => double.parse(v.toStringAsFixed(3));
}
