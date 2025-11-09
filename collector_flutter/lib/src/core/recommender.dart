import 'analyzer.dart';

/// Gera recomendações textuais e prioridade com base em análisis.
class Recommender {
  List<Recommendation> generate(AnalysisResult res) {
    final List<Recommendation> out = [];

    if (res.estimatedFps < 45) {
      out.add(
        Recommendation(
          title: 'Melhore a performance de frames',
          detail:
              'Média de frame ${res.avgFrameMs.toStringAsFixed(1)} ms. Verifique builds desnecessários e operações pesadas em main thread.',
          severity: Severity.high,
        ),
      );
    }

    if (res.longFrames > 3) {
      out.add(
        Recommendation(
          title: 'Investigue jank',
          detail:
              'Foram detectados ${res.longFrames} frames acima de ${res.avgFrameMs.toStringAsFixed(1)} ms.',
          severity: Severity.medium,
        ),
      );
    }

    if (res.memoryBytes > 200 * 1024 * 1024) {
      out.add(
        Recommendation(
          title: 'Uso de memória elevado',
          detail:
              'Memória atual ${(res.memoryBytes / (1024 * 1024)).toStringAsFixed(1)} MB. Verifique leaks ou caches sem limite.',
          severity: Severity.high,
        ),
      );
    }

    if (res.networkRequests > 50) {
      out.add(
        Recommendation(
          title: 'Muitas requisições de rede',
          detail:
              'Total de requisições: ${res.networkRequests}. Considere batch, debounce ou caching.',
          severity: Severity.low,
        ),
      );
    }

    if (out.isEmpty) {
      out.add(
        Recommendation(
          title: 'Tudo OK',
          detail: 'Nenhuma anomalia detectada nas métricas coletadas.',
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
