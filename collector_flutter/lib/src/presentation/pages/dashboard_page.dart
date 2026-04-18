import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui show FrameTiming;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/analyzer.dart';
import '../../core/export_service.dart';
import '../../core/recommender.dart';
import '../../data/models/telemetry_model.dart';
import '../cubit/cubit.dart';
import '../resource_collector.dart';

class DashboardPage extends StatefulWidget {
  final ResourceCollector collector;
  const DashboardPage({super.key, required this.collector});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final ResourceCollector _collector;
  late final StreamSubscription<CollectorState> _sub;

  @override
  void initState() {
    super.initState();
    _collector = widget.collector;
    _sub = _collector.bloc.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _collector.bloc.state;

    if (state is CollectorData) {
      return _buildDashboard(context, state);
    } else if (state is CollectorError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Erro: ${state.message}',
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildDashboard(BuildContext context, CollectorData state) {
    final t = state.telemetry;
    final a = state.analysis;
    final fps = a.estimatedFps.toStringAsFixed(1);
    final memoryMB = a.memoryStats.currentRssMB.toStringAsFixed(1);
    final p95Ms = a.frameStats.p95Ms.toStringAsFixed(1);
    final trendMB = a.memoryStats.trendMBperMin;
    final chartFrames =
        t.recentFrameTimings.isNotEmpty ? t.recentFrameTimings : t.frameTimings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Session row ──────────────────────────────────────────
        _SessionInfoRow(
            telemetry: t, onExport: () => _exportToClipboard(context, state)),
        const SizedBox(height: 10),

        // ── Metric cards ─────────────────────────────────────────
        _MetricGrid(
          fps: fps,
          memory: memoryMB,
          jank: a.longFrames,
          networkCount: a.networkStats.requestCount,
          p95Ms: p95Ms,
          memoryTrendMBperMin: trendMB,
          targetFps: a.targetFps,
          frameBudgetMs: a.frameBudgetMs,
          confidence: a.confidence,
        ),
        const SizedBox(height: 12),

        // ── Frame timing chart ───────────────────────────────────
        _FrameChart(
          frames: chartFrames,
          stats: a.frameStats,
          frameBudgetMs: a.frameBudgetMs,
        ),
        const SizedBox(height: 12),

        // ── Network panel ────────────────────────────────────────
        _NetworkPanel(events: t.networkEvents),
        if (t.networkEvents.isNotEmpty) const SizedBox(height: 12),

        // ── Recommendations ──────────────────────────────────────
        _RecommendationsPanel(recommendations: state.recommendations),
      ],
    );
  }

  Future<void> _exportToClipboard(
      BuildContext context, CollectorData state) async {
    final service = ExportService();
    final json = service.toJson(
      model: state.telemetry,
      analysis: state.analysis,
      recommendations: state.recommendations,
    );
    await Clipboard.setData(ClipboardData(text: json));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Telemetria copiada para a area de transferencia (JSON)'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// ─── SESSION INFO ROW ────────────────────────────────────────────────────────

class _SessionInfoRow extends StatelessWidget {
  final TelemetryModel telemetry;
  final VoidCallback onExport;

  const _SessionInfoRow({required this.telemetry, required this.onExport});

  @override
  Widget build(BuildContext context) {
    final dur = telemetry.sessionDuration;
    final durStr = dur.inMinutes > 0
        ? '${dur.inMinutes}m ${dur.inSeconds % 60}s'
        : '${dur.inSeconds}s';

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _SessionInfoChip(
          icon: Icons.access_time,
          label: 'Sessao: $durStr',
        ),
        _SessionInfoChip(
          icon: Icons.refresh,
          label: '${telemetry.rebuildCount} rebuilds',
        ),
        TextButton.icon(
          onPressed: onExport,
          icon: const Icon(Icons.file_download_outlined, size: 16),
          label: const Text('Exportar', style: TextStyle(fontSize: 12)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}

class _SessionInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SessionInfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

// ─── METRIC GRID ─────────────────────────────────────────────────────────────

class _MetricGrid extends StatelessWidget {
  final String fps;
  final String memory;
  final int jank;
  final int networkCount;
  final String p95Ms;
  final double memoryTrendMBperMin;
  final double targetFps;
  final double frameBudgetMs;
  final MetricConfidence confidence;

  const _MetricGrid({
    required this.fps,
    required this.memory,
    required this.jank,
    required this.networkCount,
    required this.p95Ms,
    required this.memoryTrendMBperMin,
    required this.targetFps,
    required this.frameBudgetMs,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final fpsVal = double.tryParse(fps) ?? 0;
    final trendIcon = memoryTrendMBperMin > 10
        ? Icons.trending_up
        : memoryTrendMBperMin < -5
            ? Icons.trending_down
            : Icons.trending_flat;
    final trendColor = memoryTrendMBperMin > 50
        ? Colors.red
        : memoryTrendMBperMin > 10
            ? Colors.orange
            : Colors.green;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _metricCard(
          icon: Icons.speed,
          title: 'FPS',
          value: confidence == MetricConfidence.none ? '--' : fps,
          color: _fpsColor(fpsVal),
          info: 'Quadros por segundo renderizados.\n'
              'Alvo atual: ${targetFps.toStringAsFixed(0)} FPS.\n'
              'Abaixo de 30 indica lentidao grave.\n\n'
              'Evite rebuilds desnecessarios e use const em widgets estaticos.',
        ),
        _metricCard(
          icon: Icons.memory,
          title: 'Memoria',
          value: '$memory MB',
          color: Colors.blueAccent.shade400,
          info: 'Uso de memoria RSS do processo.\n'
              'Acima de 200 MB pode indicar vazamentos.\n\n'
              'Revise listas, caches e streams nao cancelados.',
          badge: Icon(trendIcon, size: 13, color: trendColor),
        ),
        _metricCard(
          icon: Icons.warning_amber_rounded,
          title: 'Jank',
          value: '$jank',
          color: jank > 5 ? Colors.orange.shade600 : Colors.green.shade600,
          info: 'Frames acima do limiar de tempo.\n'
              'Orcamento atual: ${frameBudgetMs.toStringAsFixed(1)} ms.\n\n'
              'Use o Flutter DevTools timeline para inspecionar.',
        ),
        _metricCard(
          icon: Icons.wifi,
          title: 'Rede',
          value: '$networkCount req',
          color: Colors.purpleAccent.shade400,
          info: 'Requisicoes HTTP interceptadas nesta sessao.\n\n'
              'Use cache, debounce e cancele requisicoes obsoletas.',
        ),
        _metricCard(
          icon: Icons.bar_chart_rounded,
          title: 'P95 Frame',
          value: '${p95Ms}ms',
          color: _p95Color(double.tryParse(p95Ms) ?? 0),
          info: 'Percentil 95 do tempo de frame.\n'
              'Reflete a experiencia dos usuarios mais lentos.\n\n'
              'Manter perto de ${frameBudgetMs.toStringAsFixed(1)} ms evita jank perceptivel.',
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String info,
    Widget? badge,
  }) {
    return _MetricCard(
      icon: icon,
      title: title,
      value: value,
      color: color,
      info: info,
      badge: badge,
    );
  }

  Color _fpsColor(double fps) {
    if (fps <= 0) return Colors.grey.shade500;
    if (fps >= targetFps * 0.9) return Colors.greenAccent.shade400;
    if (fps >= targetFps * 0.6) return Colors.orangeAccent.shade400;
    return Colors.redAccent;
  }

  Color _p95Color(double p95) {
    if (p95 <= 0) return Colors.grey.shade500;
    if (p95 <= frameBudgetMs * 1.2) return Colors.green.shade600;
    if (p95 <= frameBudgetMs * 2) return Colors.orange.shade600;
    return Colors.redAccent;
  }
}

// ─── METRIC CARD ─────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String info;
  final Color color;
  final IconData icon;
  final Widget? badge;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.info,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final darkColor = color.darken();
    // Each card is ~18% of screen width so 5 fit on a 360dp screen
    final cardWidth = (MediaQuery.of(context).size.width - 32 - 8 * 4) / 5;

    return GestureDetector(
      onTap: () => _showInfo(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: cardWidth.clamp(60.0, 100.0),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withValues(alpha: 0.09),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.22),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(icon, size: 20, color: darkColor),
                if (badge != null)
                  Positioned(right: -2, top: -2, child: badge!),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 10,
                color: darkColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: darkColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: color.darken(), size: 22),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(info, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}

// ─── FRAME CHART ─────────────────────────────────────────────────────────────

class _FrameChart extends StatelessWidget {
  final List<ui.FrameTiming> frames;
  final FrameStats stats;
  final double frameBudgetMs;

  const _FrameChart({
    required this.frames,
    required this.stats,
    required this.frameBudgetMs,
  });

  @override
  Widget build(BuildContext context) {
    final lastFrames = frames.takeLast(60);
    if (lastFrames.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = lastFrames.asMap().entries.map((e) {
      return FlSpot(
        e.key.toDouble(),
        e.value.totalSpan.inMicroseconds / 1000.0,
      );
    }).toList();

    final maxFrameMs = spots.isEmpty
        ? 32.0
        : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final maxY = (maxFrameMs * 1.2).clamp(17.0, 200.0);
    final yInterval = (maxY / 4).roundToDouble();

    return Card(
      elevation: 4,
      shadowColor: Colors.blueAccent.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 2, bottom: 8),
              child: _FrameChartHeader(stats: stats),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final chartWidth =
                    math.max(constraints.maxWidth, spots.length * 7.0);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartWidth,
                    height: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: (spots.length - 1)
                              .toDouble()
                              .clamp(1, double.infinity),
                          minY: 0,
                          maxY: maxY,
                          lineTouchData: const LineTouchData(enabled: false),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          extraLinesData: ExtraLinesData(
                            horizontalLines: [
                              HorizontalLine(
                                y: frameBudgetMs,
                                color: Colors.red.withValues(alpha: 0.6),
                                strokeWidth: 2,
                                dashArray: [5, 5],
                              ),
                            ],
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                interval: yInterval,
                                getTitlesWidget: (value, meta) =>
                                    SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    value.toStringAsFixed(0),
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 9),
                                  ),
                                ),
                              ),
                            ),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              curveSmoothness: 0.3,
                              color: Colors.blueAccent,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blueAccent.withValues(alpha: 0.55),
                                    Colors.blueAccent.withValues(alpha: 0.04),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FrameChartHeader extends StatelessWidget {
  final FrameStats stats;

  const _FrameChartHeader({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tempo de Frame (ms)',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
        ),
        if (stats.sampleCount > 0) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _statBadge('P50', stats.p50Ms, Colors.green.shade700),
              _statBadge('P95', stats.p95Ms, Colors.orange.shade700),
              _statBadge('σ', stats.stdDevMs, Colors.grey.shade600),
            ],
          ),
        ],
      ],
    );
  }

  Widget _statBadge(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label ${value.toStringAsFixed(1)}ms',
        style:
            TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─── NETWORK PANEL ───────────────────────────────────────────────────────────

class _NetworkPanel extends StatelessWidget {
  final List<NetworkEvent> events;
  const _NetworkPanel({required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    final recent = events.reversed.take(5).toList();
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wifi, color: Colors.purple, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Requisicoes de Rede  (${events.length} total)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...recent.map((e) => _NetworkEventTile(event: e)),
          ],
        ),
      ),
    );
  }
}

class _NetworkEventTile extends StatelessWidget {
  final NetworkEvent event;
  const _NetworkEventTile({required this.event});

  /// Extrai hostname ou começo do caminho de forma informativa
  String _extractShortHost(String url) {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return url.truncate(35);

      // Extrai apenas o hostname e já remove o 'www.'
      String host = uri.host.replaceFirst('www.', '');

      // Pega tudo DEPOIS do primeiro '.' (se houver algum ponto)
      final firstDotIndex = host.indexOf('.');
      if (firstDotIndex != -1) {
        host = host.substring(firstDotIndex + 1);
      }

      // Adiciona a primeira parte do path (se houver)
      if (uri.path.isNotEmpty && uri.path != '/') {
        final pathParts =
            uri.path.split('/').where((p) => p.isNotEmpty).toList();
        if (pathParts.isNotEmpty) {
          host += '/${pathParts.first}';
        }
      }

      return host;
    } catch (_) {
      return url.truncate(35);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOk = !event.failed;
    final statusColor = isOk ? Colors.green.shade700 : Colors.red.shade700;
    final durationMs = event.duration.inMilliseconds;
    final shortUrl = _extractShortHost(event.url);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              event.method,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'https://$shortUrl',
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${event.statusCode}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${durationMs}ms',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ─── RECOMMENDATIONS ─────────────────────────────────────────────────────────

class _RecommendationsPanel extends StatelessWidget {
  final List<Recommendation> recommendations;
  const _RecommendationsPanel({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 22),
              SizedBox(width: 10),
              Text(
                'Nenhum problema detectado.',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.tips_and_updates_outlined, size: 20),
            const SizedBox(width: 8),
            Text(
              'Recomendacoes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recommendations.map((r) => _RecommendationTile(r: r)),
      ],
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  final Recommendation r;
  const _RecommendationTile({required this.r});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(r.severity);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showDetail(context, color),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_iconFor(r.severity), color: color, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color.darken(),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        r.detail,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: Colors.grey.shade400, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, Color color) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(_iconFor(r.severity), color: color, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(r.title, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        content: Text(r.detail, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Color _colorFor(Severity s) => switch (s) {
        Severity.high => Colors.redAccent,
        Severity.medium => Colors.orange.shade700,
        Severity.low => Colors.amber.shade700,
        Severity.info => Colors.green.shade600,
      };

  IconData _iconFor(Severity s) => switch (s) {
        Severity.high => Icons.warning_rounded,
        Severity.medium => Icons.report_problem_outlined,
        Severity.low => Icons.lightbulb_outline,
        Severity.info => Icons.check_circle_outline,
      };
}

// ─── HELPERS ─────────────────────────────────────────────────────────────────

extension _TakeLastExt<T> on List<T> {
  List<T> takeLast(int n) =>
      length <= n ? List<T>.from(this) : sublist(length - n);
}

extension _ColorShade on Color {
  Color darken([double amount = .18]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}

extension _StringTruncate on String {
  String truncate(int maxLen) =>
      length <= maxLen ? this : '${substring(0, maxLen - 1)}…';
}
