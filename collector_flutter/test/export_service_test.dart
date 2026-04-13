import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:collector_flutter/src/core/analyzer.dart';
import 'package:collector_flutter/src/core/export_service.dart';
import 'package:collector_flutter/src/core/recommender.dart';
import 'package:collector_flutter/src/data/models/telemetry_model.dart';

void main() {
  late ExportService service;
  late TelemetryModel emptyModel;
  late AnalysisResult emptyAnalysis;
  late List<Recommendation> emptyRecs;

  setUp(() {
    service = ExportService();
    emptyModel = TelemetryModel(
      sessionStart: DateTime(2024, 1, 1, 12, 0),
      rebuildCount: 5,
    );
    emptyAnalysis = AnalysisResult.empty();
    emptyRecs = [];
  });

  group('ExportService.toJson', () {
    test('retorna string JSON válida', () {
      final json = service.toJson(
        model: emptyModel,
        analysis: emptyAnalysis,
        recommendations: emptyRecs,
      );
      expect(() => jsonDecode(json), returnsNormally);
    });

    test('inclui campo session com sessionStart e rebuildCount', () {
      final json = service.toJson(
        model: emptyModel,
        analysis: emptyAnalysis,
        recommendations: emptyRecs,
      );
      final map = jsonDecode(json) as Map<String, dynamic>;
      expect(map['session'], isNotNull);
      expect(map['session']['rebuildCount'], 5);
      expect(map['session']['start'], contains('2024-01-01'));
    });

    test('inclui campos de frames com percentis', () {
      final json = service.toJson(
        model: emptyModel,
        analysis: emptyAnalysis,
        recommendations: emptyRecs,
      );
      final map = jsonDecode(json) as Map<String, dynamic>;
      expect(map['frames'], isNotNull);
      expect(map['frames'].containsKey('p50Ms'), isTrue);
      expect(map['frames'].containsKey('p95Ms'), isTrue);
      expect(map['frames'].containsKey('p99Ms'), isTrue);
      expect(map['frames'].containsKey('stdDevMs'), isTrue);
    });

    test('inclui seção de network com lista de eventos', () {
      final model = TelemetryModel(
        networkEvents: [
          NetworkEvent(
            url: 'https://api.example.com/test',
            method: 'GET',
            statusCode: 200,
            bytes: 1024,
            timestamp: DateTime(2024, 1, 1, 12, 0),
            duration: const Duration(milliseconds: 150),
          ),
        ],
      );
      final json = service.toJson(
        model: model,
        analysis: emptyAnalysis,
        recommendations: emptyRecs,
      );
      final map = jsonDecode(json) as Map<String, dynamic>;
      final events = map['network']['events'] as List;
      expect(events, hasLength(1));
      expect(events.first['url'], 'https://api.example.com/test');
      expect(events.first['statusCode'], 200);
      expect(events.first['durationMs'], 150);
    });

    test('inclui recomendações serializadas com severity como string', () {
      final recs = [
        Recommendation(
          title: 'Melhore FPS',
          detail: 'FPS baixo detectado',
          severity: Severity.high,
        ),
      ];
      final json = service.toJson(
        model: emptyModel,
        analysis: emptyAnalysis,
        recommendations: recs,
      );
      final map = jsonDecode(json) as Map<String, dynamic>;
      final recList = map['recommendations'] as List;
      expect(recList, hasLength(1));
      expect(recList.first['severity'], 'high');
      expect(recList.first['title'], 'Melhore FPS');
    });
  });

  group('ExportService.frameTimingsToCsv', () {
    test('retorna header CSV correto para modelo sem frames', () {
      final csv = service.frameTimingsToCsv(emptyModel);
      expect(csv.trim().split('\n').first, 'index,totalMs,buildMs,rasterMs');
    });

    test('CSV vazio tem apenas o header quando não há frames', () {
      final csv = service.frameTimingsToCsv(emptyModel);
      final lines = csv.trim().split('\n');
      expect(lines, hasLength(1)); // só o header
    });
  });
}
