import 'package:flutter_test/flutter_test.dart';
import 'package:collector_flutter/src/core/analyzer.dart';
import 'package:collector_flutter/src/core/recommender.dart';

AnalysisResult _makeResult({
  double fps = 60,
  double avgMs = 16,
  int longFrames = 0,
  int memoryBytes = 0,
  int networkRequests = 0,
  List<String> issues = const [],
  FrameStats? frameStats,
  MemoryStats? memoryStats,
  NetworkStats? networkStats,
  MetricConfidence confidence = MetricConfidence.stable,
  bool hasEnoughWindowFrames = true,
}) {
  return AnalysisResult(
    estimatedFps: fps,
    avgFrameMs: avgMs,
    longFrames: longFrames,
    memoryBytes: memoryBytes,
    networkRequests: networkRequests,
    issues: issues,
    frameStats: frameStats,
    memoryStats: memoryStats,
    networkStats: networkStats,
    confidence: confidence,
    hasEnoughWindowFrames: hasEnoughWindowFrames,
  );
}

void main() {
  late Recommender recommender;

  setUp(() => recommender = Recommender());

  group('Recommender — estado saudável', () {
    test('retorna "Tudo OK" quando não há anomalias', () {
      final recs = recommender.generate(_makeResult());
      expect(recs, hasLength(1));
      expect(recs.first.title, 'Tudo OK');
      expect(recs.first.severity, Severity.info);
    });

    test('retorna "Tudo OK" em idle com RSS alto e uma request lenta/falha',
        () {
      final recs = recommender.generate(
        _makeResult(
          hasEnoughWindowFrames: false,
          memoryStats: const MemoryStats(
            currentRssMB: 900,
            heapUsageMB: 80,
            peakRssMB: 900,
            trendMBperMin: 0,
            sampleCount: 1,
          ),
          networkStats: const NetworkStats(
            requestCount: 1,
            failedRequests: 1,
            totalRequestBytes: 10,
            totalResponseBytes: 0,
            avgDurationMs: 2000,
            p95DurationMs: 2000,
          ),
        ),
      );

      expect(recs, hasLength(1));
      expect(recs.first.title, 'Tudo OK');
    });
  });

  group('Recommender — FPS baixo', () {
    test('gera recomendação de performance quando FPS < 40 (debug)', () {
      // Em debug o limite é 40 FPS
      final recs = recommender.generate(_makeResult(fps: 20, avgMs: 50));
      final fps = recs.where((r) => r.title.contains('performance')).toList();
      expect(fps, isNotEmpty);
      expect(fps.first.severity, Severity.high);
    });

    test('não gera recomendação de FPS quando fps == 0 (aguardando dados)', () {
      final recs = recommender.generate(_makeResult(fps: 0));
      final fps = recs.where((r) => r.title.contains('performance')).toList();
      expect(fps, isEmpty);
    });
  });

  group('Recommender — jank', () {
    test('gera alerta de jank quando longFrames >= 6', () {
      final recs = recommender.generate(_makeResult(longFrames: 6));
      final jank = recs.where((r) => r.title.contains('jank')).toList();
      expect(jank, isNotEmpty);
    });

    test('não gera alerta de jank quando longFrames < 6', () {
      final recs = recommender.generate(_makeResult(longFrames: 5));
      final jank = recs.where((r) => r.title.contains('jank')).toList();
      expect(jank, isEmpty);
    });

    test('não gera alerta de jank por P95 isolado sem issue do Analyzer', () {
      final recs = recommender.generate(
        _makeResult(
          longFrames: 5,
          frameStats: const FrameStats(
            p50Ms: 16,
            p95Ms: 40,
            p99Ms: 40,
            stdDevMs: 8,
            avgMs: 24,
            minMs: 16,
            maxMs: 40,
            sampleCount: 15,
          ),
        ),
      );

      final jank = recs.where((r) => r.title.contains('jank')).toList();
      expect(jank, isEmpty);
    });
  });

  group('Recommender — rede', () {
    test('gera alerta de rede quando requests > 50', () {
      final recs = recommender.generate(_makeResult(networkRequests: 60));
      final net = recs.where((r) => r.title.contains('rede')).toList();
      expect(net, isNotEmpty);
      expect(net.first.severity, Severity.low);
    });

    test('não gera alerta de rede quando requests <= 50', () {
      final recs = recommender.generate(_makeResult(networkRequests: 50));
      final net = recs.where((r) => r.title.contains('rede')).toList();
      expect(net, isEmpty);
    });

    test('não gera alerta de rede por P95/falha isolados sem issue do Analyzer',
        () {
      final recs = recommender.generate(
        _makeResult(
          networkStats: const NetworkStats(
            requestCount: 1,
            failedRequests: 1,
            totalRequestBytes: 10,
            totalResponseBytes: 0,
            avgDurationMs: 2000,
            p95DurationMs: 2000,
          ),
        ),
      );

      final net = recs.where((r) => r.title.contains('rede')).toList();
      expect(net, isEmpty);
    });
  });

  group('Recommender — múltiplos problemas', () {
    test('pode gerar múltiplas recomendações simultaneamente', () {
      final recs = recommender.generate(
        _makeResult(fps: 15, avgMs: 67, longFrames: 20, networkRequests: 100),
      );
      expect(recs.length, greaterThan(1));
      // Não deve conter "Tudo OK" quando há problemas
      expect(recs.any((r) => r.title == 'Tudo OK'), isFalse);
    });
  });

  group('Recommender — Severity ordering', () {
    test('valores do enum estão em ordem crescente', () {
      expect(Severity.info.index < Severity.low.index, isTrue);
      expect(Severity.low.index < Severity.medium.index, isTrue);
      expect(Severity.medium.index < Severity.high.index, isTrue);
    });
  });
}
