import 'package:flutter/foundation.dart';

import 'analyzer.dart';

/// Gera recomendações textuais e prioridade com base em análises.
class Recommender {
  List<Recommendation> generate(AnalysisResult res) {
    final List<Recommendation> out = [];

    final modeLabel = kReleaseMode ? 'Release' : 'Debug/Profile';

    // Ajuste de limiares conforme modo
    final memLimit = kReleaseMode ? 300 : 600;
    final fpsLimit = kReleaseMode ? 50 : 40;

    // FPS baixo
    if (res.estimatedFps < fpsLimit && res.estimatedFps > 0) {
      out.add(
        Recommendation(
          title: 'Melhore a performance de frames',
          detail:
              'A média de FPS está em ${res.estimatedFps.toStringAsFixed(1)}.\n'
              'Tempo médio de frame: ${res.avgFrameMs.toStringAsFixed(1)} ms.\n\n'
              '💡 Dica: evite rebuilds desnecessários, mova cálculos pesados para Isolates ou use const widgets.',
          severity: Severity.high,
        ),
      );
    }
    // Jank
    if (res.longFrames > 5) {
      out.add(
        Recommendation(
          title: 'Investigue jank (travamentos de frame)',
          detail:
              'Foram detectados ${res.longFrames} frames longos.\n\n'
              'Modo atual: ${kReleaseMode ? "Release" : "Debug/Profile"}.\n'
              '💡 Em Debug, alguns frames lentos são esperados devido ao overhead do Flutter DevTools e hot reload.',
          severity: kReleaseMode ? Severity.medium : Severity.low,
        ),
      );
    }

    // Memória
    final memoryMB = res.memoryBytes / (1024 * 1024);
    if (memoryMB > memLimit) {
      out.add(
        Recommendation(
          title: 'Uso de memória elevado',
          detail:
              'Memória atual: ${memoryMB.toStringAsFixed(1)} MB (modo $modeLabel).\n\n'
              '💡 Dica: valores entre 300–500 MB são normais em Debug/Profile.\n'
              'Se ultrapassar 600 MB de forma persistente, investigue listas grandes, imagens em cache ou Streams não canceladas.',
          severity: kReleaseMode ? Severity.high : Severity.low,
        ),
      );
    }

    // Rede
    if (res.networkRequests > 50) {
      out.add(
        Recommendation(
          title: 'Muitas requisições de rede',
          detail:
              'Foram feitas ${res.networkRequests} requisições.\n\n'
              '💡 Dica: use cache local, debounce ou agrupe requests simultâneos.',
          severity: Severity.low,
        ),
      );
    }

    // Se não houver alertas
    if (out.isEmpty) {
      out.add(
        Recommendation(
          title: 'Tudo OK',
          detail:
              'Nenhuma anomalia detectada.\n\n'
              'Modo atual: $modeLabel.\nContinue monitorando para identificar variações de performance.',
          severity: Severity.info,
        ),
      );
    }

    return out;
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
