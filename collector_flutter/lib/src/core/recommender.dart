import 'package:flutter/foundation.dart';

import 'analyzer.dart';

/// Gera recomendações textuais e prioridade com base em análises.
class Recommender {
  List<Recommendation> generate(AnalysisResult result) {
    final recommendations = <Recommendation>[];
    final modeLabel = kReleaseMode ? 'Release' : 'Debug/Profile';
    final hasStableData = result.confidence == MetricConfidence.stable;
    final lowFps = hasStableData &&
        result.hasEnoughWindowFrames &&
        result.estimatedFps > 0 &&
        result.estimatedFps < result.targetFps * 0.75;
    final hasJank =
        hasStableData && result.hasEnoughWindowFrames && result.longFrames >= 6;
    final currentMemoryMB = result.memoryStats.currentRssMB > 0
        ? result.memoryStats.currentRssMB
        : result.memoryMB;
    final hasNetworkPressure =
        result.networkStats.requestCount > 50 || result.networkRequests > 50;

    if (result.confidence == MetricConfidence.warmingUp) {
      recommendations.add(
        Recommendation(
          title: 'Amostra de frames ainda pequena',
          detail:
              '${result.note}.\nAguarde mais alguns segundos para estabilizar FPS, P95 e jank.',
          severity: Severity.info,
        ),
      );
    }

    if (_hasIssue(result, 'FPS abaixo') || lowFps) {
      recommendations.add(
        Recommendation(
          title: 'Melhore a performance de frames',
          detail: 'FPS observado: ${result.estimatedFps.toStringAsFixed(1)} de '
              '${result.targetFps.toStringAsFixed(0)} FPS.\n'
              'Frame médio: ${result.avgFrameMs.toStringAsFixed(1)} ms; '
              'P95: ${result.frameStats.p95Ms.toStringAsFixed(1)} ms.\n\n'
              'Priorize remover rebuilds amplos, dividir listas grandes, '
              'cachear cálculos e mover trabalho pesado para isolate.',
          severity: Severity.high,
        ),
      );
    }

    if (_hasIssue(result, 'P95 de frame') ||
        _hasIssue(result, 'Jank') ||
        hasJank) {
      recommendations.add(
        Recommendation(
          title: 'Investigue jank na timeline',
          detail:
              'Orçamento por frame: ${result.frameBudgetMs.toStringAsFixed(1)} ms.\n'
              'Frames longos: ${result.longFrames} '
              '(${(result.jankRate * 100).toStringAsFixed(1)}%).\n\n'
              'No modo $modeLabel existe overhead de ferramenta, mas picos '
              'repetidos ainda apontam para build, layout, rasterização ou IO '
              'sincrono no caminho critico.',
          severity: kReleaseMode ? Severity.high : Severity.medium,
        ),
      );
    }

    if (_hasIssue(result, 'memória')) {
      recommendations.add(
        Recommendation(
          title: 'Revise pressão de memória',
          detail: 'RSS atual: ${currentMemoryMB.toStringAsFixed(1)} MB.\n'
              'Pico observado: ${result.memoryStats.peakRssMB.toStringAsFixed(1)} MB.\n'
              'Tendência: ${result.memoryStats.trendMBperMin.toStringAsFixed(1)} MB/min.\n\n'
              'Procure imagens grandes sem resize, caches sem limite, listas '
              'retidas e subscriptions/streams não cancelados.',
          severity: kReleaseMode ? Severity.high : Severity.medium,
        ),
      );
    }

    if (_hasIssue(result, 'rede') ||
        _hasIssue(result, 'Latência') ||
        _hasIssue(result, 'Falhas') ||
        hasNetworkPressure) {
      recommendations.add(
        Recommendation(
          title: 'Ajuste o fluxo de rede',
          detail: 'Requests: ${result.networkStats.requestCount}; '
              'falhas: ${result.networkStats.failedRequests}; '
              'P95: ${result.networkStats.p95DurationMs.toStringAsFixed(0)} ms.\n\n'
              'Use cache, debounce, cancelamento de requests obsoletos e '
              'agrupe chamadas que disparam juntas.',
          severity:
              _hasIssue(result, 'Falhas') ? Severity.medium : Severity.low,
        ),
      );
    }

    if (_hasIssue(result, 'CPU elevada')) {
      recommendations.add(
        Recommendation(
          title: 'Alto uso de CPU detectado',
          detail:
              'CPU atual: ${result.cpuUsagePercent.toStringAsFixed(1)}%.\n\n'
              'Mova computações pesadas para Isolates, reduza timers frequentes '
              'e evite rebuilds desnecessários no caminho crítico.',
          severity: Severity.high,
        ),
      );
    } else if (_hasIssue(result, 'CPU moderada')) {
      recommendations.add(
        Recommendation(
          title: 'Uso moderado de CPU',
          detail:
              'CPU atual: ${result.cpuUsagePercent.toStringAsFixed(1)}%.\n\n'
              'Monitore tendências; considere otimizar loops e reduzir '
              'frequência de coleta se não necessário.',
          severity: Severity.low,
        ),
      );
    }

    if (_hasIssue(result, 'Bateria baixa')) {
      recommendations.add(
        Recommendation(
          title: 'Bateria baixa',
          detail: 'Nível de bateria: ${result.batteryLevel}%.\n\n'
              'Considere reduzir o intervalo de coleta ou desativar o '
              'monitoramento para preservar energia.',
          severity: Severity.medium,
        ),
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        Recommendation(
          title: 'Tudo OK',
          detail: 'Nenhuma anomalia detectada no snapshot atual.\n\n'
              'Modo atual: $modeLabel. Continue monitorando durante fluxos '
              'reais de navegação, carregamento e interação.',
          severity: Severity.info,
        ),
      );
    }

    return recommendations;
  }

  bool _hasIssue(AnalysisResult result, String token) {
    return result.issues.any((issue) => issue.contains(token));
  }
}

enum Severity { info, low, medium, high }

class Recommendation {
  final String title;
  final String detail;
  final Severity severity;

  Recommendation({
    required this.title,
    required this.detail,
    required this.severity,
  });
}
