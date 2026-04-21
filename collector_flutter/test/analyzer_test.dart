import 'dart:ui' show FrameTiming;

import 'package:flutter_test/flutter_test.dart';
import 'package:collector_flutter/src/core/analyzer.dart';
import 'package:collector_flutter/src/data/models/telemetry_model.dart';

// FrameTiming tem factory para testes; usamos timestamps sintéticos para
// exercitar o Analyzer sem depender do engine reportar frames reais.

FrameTiming _frameTiming(double totalMs) {
  final totalUs = (totalMs * Duration.microsecondsPerMillisecond).round();
  return FrameTiming(
    vsyncStart: 0,
    buildStart: 0,
    buildFinish: totalUs ~/ 2,
    rasterStart: totalUs ~/ 2,
    rasterFinish: totalUs,
    rasterFinishWallTime: totalUs,
  );
}

TelemetryModel _stableTelemetry({
  List<FrameTiming> frameTimings = const [],
  List<MemoryInfo> memoryHistory = const [],
  MemoryInfo? memoryInfo,
  List<NetworkEvent> networkEvents = const [],
}) {
  final start = DateTime(2024, 1, 1, 12);
  return TelemetryModel(
    frameTimings: frameTimings,
    memoryInfo: memoryInfo,
    memoryHistory: memoryHistory,
    networkEvents: networkEvents,
    sessionStart: start,
    capturedAt: start.add(const Duration(seconds: 7)),
    totalFrameCount: frameTimings.length,
    totalNetworkRequests: networkEvents.length,
  );
}

NetworkEvent _networkEvent({
  int statusCode = 200,
  Duration duration = const Duration(milliseconds: 100),
  String? error,
}) {
  return NetworkEvent(
    url: 'https://example.com',
    method: 'GET',
    statusCode: statusCode,
    requestBytes: 10,
    responseBytes: 100,
    timestamp: DateTime(2024),
    duration: duration,
    error: error,
  );
}

void main() {
  group('FrameStats.compute', () {
    test('retorna empty para lista vazia', () {
      final stats = FrameStats.compute([]);
      expect(stats.sampleCount, 0);
      expect(stats.avgMs, 0);
      expect(stats.p50Ms, 0);
      expect(stats.p95Ms, 0);
      expect(stats.p99Ms, 0);
      expect(stats.stdDevMs, 0);
    });

    test('calcula media corretamente', () {
      final stats = FrameStats.compute([10.0, 20.0, 30.0]);
      expect(stats.avgMs, closeTo(20.0, 0.01));
    });

    test('calcula P50 corretamente para lista ímpar', () {
      // mediana de [10, 20, 30] = 20
      final stats = FrameStats.compute([30.0, 10.0, 20.0]);
      expect(stats.p50Ms, closeTo(20.0, 0.01));
    });

    test('calcula P50 por interpolação para lista par', () {
      // [10, 20, 30, 40] → P50 = índice 1.5 → 25
      final stats = FrameStats.compute([10.0, 20.0, 30.0, 40.0]);
      expect(stats.p50Ms, closeTo(25.0, 0.01));
    });

    test('calcula P95 corretamente', () {
      // lista de 100 valores de 1 a 100
      final data = List<double>.generate(100, (i) => (i + 1).toDouble());
      final stats = FrameStats.compute(data);
      // P95 de 100 valores = índice 94.05 → ~95.05
      expect(stats.p95Ms, greaterThan(94.0));
      expect(stats.p95Ms, lessThanOrEqualTo(96.0));
    });

    test('calcula P99 corretamente', () {
      final data = List<double>.generate(100, (i) => (i + 1).toDouble());
      final stats = FrameStats.compute(data);
      expect(stats.p99Ms, greaterThan(98.0));
      expect(stats.p99Ms, lessThanOrEqualTo(100.0));
    });

    test('calcula desvio padrão corretamente', () {
      // [2, 4, 4, 4, 5, 5, 7, 9] → σ = 2.0
      final stats = FrameStats.compute([2, 4, 4, 4, 5, 5, 7, 9]);
      expect(stats.stdDevMs, closeTo(2.0, 0.01));
    });

    test('stdDev é 0 para lista com todos iguais', () {
      final stats = FrameStats.compute([16.6, 16.6, 16.6, 16.6]);
      expect(stats.stdDevMs, closeTo(0.0, 0.0001));
    });

    test('conta corretamente o número de amostras', () {
      final stats = FrameStats.compute([1.0, 2.0, 3.0, 4.0, 5.0]);
      expect(stats.sampleCount, 5);
    });

    test('lista com um único elemento', () {
      final stats = FrameStats.compute([33.3]);
      expect(stats.p50Ms, closeTo(33.3, 0.01));
      expect(stats.p95Ms, closeTo(33.3, 0.01));
      expect(stats.p99Ms, closeTo(33.3, 0.01));
      expect(stats.stdDevMs, closeTo(0.0, 0.001));
    });
  });

  group('AnalysisResult', () {
    test('factory empty retorna zeros e sem issues', () {
      final result = AnalysisResult.empty();
      expect(result.estimatedFps, 0);
      expect(result.avgFrameMs, 0);
      expect(result.longFrames, 0);
      expect(result.memoryBytes, 0);
      expect(result.issues, isEmpty);
      expect(result.hasIssues, isFalse);
    });

    test('hasIssues é true quando há issues', () {
      final result = AnalysisResult(
        estimatedFps: 20,
        avgFrameMs: 50,
        longFrames: 10,
        memoryBytes: 0,
        networkRequests: 0,
        issues: ['FPS abaixo do ideal'],
      );
      expect(result.hasIssues, isTrue);
    });

    test('memoryMB converte corretamente', () {
      final result = AnalysisResult(
        estimatedFps: 60,
        avgFrameMs: 16,
        longFrames: 0,
        memoryBytes: 100 * 1024 * 1024, // 100 MB
        networkRequests: 0,
        issues: [],
      );
      expect(result.memoryMB, closeTo(100.0, 0.01));
    });
  });

  group('Analyzer — instâncias isoladas', () {
    test('duas instâncias não compartilham estado de memória', () {
      final a1 = Analyzer();
      final a2 = Analyzer();

      // Ambas devem retornar AnalysisResult.empty para TelemetryModel vazio
      final r1 = a1.analyzeTelemetry(TelemetryModel());
      final r2 = a2.analyzeTelemetry(TelemetryModel());
      expect(r1.note, 'Aguardando frames renderizados');
      expect(r2.note, 'Aguardando frames renderizados');
    });
  });

  group('MemoryStats.compute', () {
    test('calcula pico e tendência usando timestamps reais', () {
      final start = DateTime(2024, 1, 1, 12, 0);
      final stats = MemoryStats.compute([
        MemoryInfo(
          currentRssInBytes: 100 * 1024 * 1024,
          heapUsageInBytes: 40 * 1024 * 1024,
          timestamp: start,
        ),
        MemoryInfo(
          currentRssInBytes: 130 * 1024 * 1024,
          heapUsageInBytes: 50 * 1024 * 1024,
          timestamp: start.add(const Duration(minutes: 1)),
        ),
      ]);

      expect(stats.currentRssMB, closeTo(130, 0.01));
      expect(stats.peakRssMB, closeTo(130, 0.01));
      expect(stats.trendMBperMin, closeTo(30, 0.01));
      expect(stats.sampleCount, 2);
    });
  });

  group('NetworkStats.compute', () {
    test('calcula falhas, bytes e latência', () {
      final events = [
        NetworkEvent(
          url: 'https://example.com/a',
          method: 'GET',
          statusCode: 200,
          requestBytes: 10,
          responseBytes: 100,
          timestamp: DateTime(2024),
          duration: const Duration(milliseconds: 100),
        ),
        NetworkEvent(
          url: 'https://example.com/b',
          method: 'GET',
          statusCode: 500,
          requestBytes: 20,
          responseBytes: 50,
          timestamp: DateTime(2024),
          duration: const Duration(milliseconds: 300),
        ),
      ];

      final stats = NetworkStats.compute(events);

      expect(stats.requestCount, 2);
      expect(stats.failedRequests, 1);
      expect(stats.totalRequestBytes, 30);
      expect(stats.totalResponseBytes, 150);
      expect(stats.avgDurationMs, closeTo(200, 0.01));
      expect(stats.failureRate, closeTo(0.5, 0.01));
    });
  });

  group('Analyzer — alert gates', () {
    test('não gera issue de memória por RSS alto isolado', () {
      final analyzer = Analyzer();
      final result = analyzer.analyzeTelemetry(
        _stableTelemetry(
          memoryInfo: MemoryInfo(
            currentRssInBytes: 900 * 1024 * 1024,
            heapUsageInBytes: 80 * 1024 * 1024,
            timestamp: DateTime(2024),
          ),
        ),
      );

      expect(
          result.issues.where((issue) => issue.contains('memória')), isEmpty);
    });

    test('gera issue de memória apenas por tendência alta', () {
      final analyzer = Analyzer();
      final start = DateTime(2024, 1, 1, 12);
      final result = analyzer.analyzeTelemetry(
        _stableTelemetry(
          memoryHistory: [
            MemoryInfo(
              currentRssInBytes: 100 * 1024 * 1024,
              heapUsageInBytes: 40 * 1024 * 1024,
              timestamp: start,
            ),
            MemoryInfo(
              currentRssInBytes: 130 * 1024 * 1024,
              heapUsageInBytes: 45 * 1024 * 1024,
              timestamp: start.add(const Duration(seconds: 30)),
            ),
            MemoryInfo(
              currentRssInBytes: 160 * 1024 * 1024,
              heapUsageInBytes: 48 * 1024 * 1024,
              timestamp: start.add(const Duration(seconds: 60)),
            ),
            MemoryInfo(
              currentRssInBytes: 190 * 1024 * 1024,
              heapUsageInBytes: 49 * 1024 * 1024,
              timestamp: start.add(const Duration(seconds: 90)),
            ),
            MemoryInfo(
              currentRssInBytes: 220 * 1024 * 1024,
              heapUsageInBytes: 50 * 1024 * 1024,
              timestamp: start.add(const Duration(minutes: 2)),
            ),
          ],
        ),
      );

      expect(
        result.issues,
        contains(predicate<String>(
          (issue) => issue.contains('Possível crescimento de memória'),
        )),
      );
    });

    test('não gera issue de memória por tendência curta de inicialização', () {
      final analyzer = Analyzer();
      final start = DateTime(2024, 1, 1, 12);
      final result = analyzer.analyzeTelemetry(
        _stableTelemetry(
          memoryHistory: [
            MemoryInfo(
              currentRssInBytes: 100 * 1024 * 1024,
              heapUsageInBytes: 40 * 1024 * 1024,
              timestamp: start,
            ),
            MemoryInfo(
              currentRssInBytes: 130 * 1024 * 1024,
              heapUsageInBytes: 45 * 1024 * 1024,
              timestamp: start.add(const Duration(seconds: 5)),
            ),
            MemoryInfo(
              currentRssInBytes: 160 * 1024 * 1024,
              heapUsageInBytes: 48 * 1024 * 1024,
              timestamp: start.add(const Duration(seconds: 10)),
            ),
            MemoryInfo(
              currentRssInBytes: 190 * 1024 * 1024,
              heapUsageInBytes: 49 * 1024 * 1024,
              timestamp: start.add(const Duration(seconds: 15)),
            ),
            MemoryInfo(
              currentRssInBytes: 220 * 1024 * 1024,
              heapUsageInBytes: 50 * 1024 * 1024,
              timestamp: start.add(const Duration(seconds: 20)),
            ),
          ],
        ),
      );

      expect(
        result.issues.where((issue) => issue.contains('memória')),
        isEmpty,
      );
    });

    test('não gera issue de rede com apenas uma request lenta e falha', () {
      final analyzer = Analyzer();
      final result = analyzer.analyzeTelemetry(
        _stableTelemetry(
          networkEvents: [
            _networkEvent(
              statusCode: 500,
              duration: const Duration(seconds: 2),
            ),
          ],
        ),
      );

      expect(result.issues.where((issue) => issue.contains('rede')), isEmpty);
      expect(
          result.issues.where((issue) => issue.contains('Latência')), isEmpty);
    });

    test('gera issue de rede com 5 requests e P95 alto', () {
      final analyzer = Analyzer();
      final result = analyzer.analyzeTelemetry(
        _stableTelemetry(
          networkEvents: [
            _networkEvent(),
            _networkEvent(),
            _networkEvent(),
            _networkEvent(),
            _networkEvent(duration: const Duration(seconds: 2)),
          ],
        ),
      );

      expect(
        result.issues,
        contains(predicate<String>(
          (issue) => issue.contains('Latência de rede elevada'),
        )),
      );
    });

    test('gera issue de rede com 5 requests e falhas', () {
      final analyzer = Analyzer();
      final result = analyzer.analyzeTelemetry(
        _stableTelemetry(
          networkEvents: [
            _networkEvent(),
            _networkEvent(),
            _networkEvent(),
            _networkEvent(),
            _networkEvent(statusCode: 500),
          ],
        ),
      );

      expect(
        result.issues,
        contains(predicate<String>(
          (issue) => issue.contains('Falhas de rede'),
        )),
      );
    });

    test('não gera jank com 15 frames e 5 frames longos', () {
      final analyzer = Analyzer();
      final result = analyzer.analyzeTelemetry(
        _stableTelemetry(
          frameTimings: [
            ...List.generate(10, (_) => _frameTiming(10)),
            ...List.generate(5, (_) => _frameTiming(40)),
          ],
        ),
      );

      expect(result.longFrames, 5);
      expect(result.issues.where((issue) => issue.contains('Jank')), isEmpty);
      expect(
        result.issues.where((issue) => issue.contains('P95 de frame')),
        isEmpty,
      );
    });

    test('gera jank com 15 frames e 6 frames longos', () {
      final analyzer = Analyzer();
      final result = analyzer.analyzeTelemetry(
        _stableTelemetry(
          frameTimings: [
            ...List.generate(9, (_) => _frameTiming(10)),
            ...List.generate(6, (_) => _frameTiming(40)),
          ],
        ),
      );

      expect(result.longFrames, 6);
      expect(
        result.issues,
        contains(predicate<String>(
          (issue) => issue.contains('Jank detectado'),
        )),
      );
    });
  });
}
