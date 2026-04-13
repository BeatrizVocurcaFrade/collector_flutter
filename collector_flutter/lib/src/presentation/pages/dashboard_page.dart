import 'dart:async';
import 'dart:ui' as ui show FrameTiming;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
    final fps = state.analysis.estimatedFps.toStringAsFixed(1);
    final memoryMB =
        (state.analysis.memoryBytes / (1024 * 1024)).toStringAsFixed(1);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricHeader(
            fps: fps,
            memory: memoryMB,
            jank: state.analysis.longFrames,
            networkCount: state.telemetry.networkEvents.length,
          ),
          const SizedBox(height: 12),
          _FrameChart(frames: state.telemetry.frameTimings),
          const SizedBox(height: 12),
          _NetworkPanel(events: state.telemetry.networkEvents),
          const SizedBox(height: 12),
          _RecommendationsPanel(recommendations: state.recommendations),
        ],
      ),
    );
  }
}

// ──────────────────────────── METRIC HEADER ────────────────────────────

class _MetricHeader extends StatelessWidget {
  final String fps;
  final String memory;
  final int jank;
  final int networkCount;

  const _MetricHeader({
    required this.fps,
    required this.memory,
    required this.jank,
    required this.networkCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.speed,
            title: 'FPS',
            value: fps,
            color: _fpsColor(double.tryParse(fps) ?? 0),
            info:
                'Quadros por segundo renderizados.\nIdeal: acima de 55 FPS.\n'
                'Abaixo de 30 indica lentidão grave.\n\n'
                '💡 Evite rebuilds desnecessários e use const em widgets estáticos.',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            icon: Icons.memory,
            title: 'Memória',
            value: '$memory MB',
            color: Colors.blueAccent.shade400,
            info:
                'Uso de memória RSS do processo.\n'
                'Acima de 200 MB pode indicar vazamentos.\n\n'
                '💡 Revise listas, caches e streams não cancelados.',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            icon: Icons.warning_amber_rounded,
            title: 'Jank',
            value: '$jank',
            color: jank > 5 ? Colors.orange.shade600 : Colors.green.shade600,
            info:
                'Número de frames acima do limiar de tempo.\n'
                'Em release: >16 ms. Em debug: >50 ms.\n\n'
                '💡 Use o Flutter DevTools timeline para inspecionar.',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            icon: Icons.wifi,
            title: 'Rede',
            value: '$networkCount',
            color: Colors.purpleAccent.shade400,
            info:
                'Requisições HTTP interceptadas nesta sessão.\n\n'
                '💡 Use cache, debounce e cancele requisições obsoletas.',
          ),
        ),
      ],
    );
  }

  Color _fpsColor(double fps) {
    if (fps >= 55) return Colors.greenAccent.shade400;
    if (fps >= 30) return Colors.orangeAccent.shade400;
    return Colors.redAccent;
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String info;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final darkColor = color.darken();
    return GestureDetector(
      onTap: () => _showInfo(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.09),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.22),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: darkColor),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
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
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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

// ──────────────────────────── FRAME CHART ────────────────────────────

class _FrameChart extends StatelessWidget {
  final List<ui.FrameTiming> frames;
  const _FrameChart({required this.frames});

  @override
  Widget build(BuildContext context) {
    final lastFrames = frames.takeLast(60);
    final data = lastFrames.asMap().entries.map((e) {
      return _FrameSample(
        e.key.toDouble(),
        e.value.totalSpan.inMilliseconds.toDouble(),
      );
    }).toList();

    final maxY = data.isEmpty
        ? 32.0
        : (data.map((d) => d.y).reduce((a, b) => a > b ? a : b) * 1.2)
            .clamp(17.0, 200.0);

    return SizedBox(
      height: 180,
      child: Card(
        elevation: 4,
        shadowColor: Colors.blueAccent.withOpacity(0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Text(
                  'Tempo de Frame (ms)',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              Expanded(
                child: SfCartesianChart(
                  margin: EdgeInsets.zero,
                  borderWidth: 0,
                  plotAreaBorderWidth: 0,
                  primaryXAxis: const NumericAxis(isVisible: false),
                  primaryYAxis: NumericAxis(
                    maximum: maxY,
                    minimum: 0,
                    interval: 16,
                    axisLine: const AxisLine(width: 0),
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                    plotBands: [
                      PlotBand(
                        start: 16.6,
                        end: 16.6,
                        borderColor: Colors.red.withOpacity(0.5),
                        borderWidth: 1,
                        dashArray: const <double>[4, 4],
                      ),
                    ],
                  ),
                  series: <CartesianSeries<_FrameSample, double>>[
                    SplineAreaSeries<_FrameSample, double>(
                      dataSource: data,
                      xValueMapper: (d, _) => d.x,
                      yValueMapper: (d, _) => d.y,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0.55),
                          Colors.blueAccent.withOpacity(0.04),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderColor: Colors.blueAccent,
                      borderWidth: 1.5,
                      splineType: SplineType.cardinal,
                      animationDuration: 300,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────── NETWORK PANEL ────────────────────────────

class _NetworkPanel extends StatelessWidget {
  final List<NetworkEvent> events;
  const _NetworkPanel({required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

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
                Text(
                  'Requisições de Rede  (${events.length} total)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
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

  @override
  Widget build(BuildContext context) {
    final isOk = event.statusCode < 400;
    final statusColor = isOk ? Colors.green.shade700 : Colors.red.shade700;
    final durationMs = event.duration.inMilliseconds;
    final uri = Uri.tryParse(event.url);
    final shortUrl =
        uri != null ? '${uri.host}${uri.path}'.truncate(40) : event.url.truncate(40);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.12),
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
              shortUrl,
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

// ──────────────────────────── RECOMMENDATIONS ────────────────────────────

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
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
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
              'Recomendações',
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
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
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
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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

// ──────────────────────────── HELPERS ────────────────────────────

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

class _FrameSample {
  final double x;
  final double y;
  const _FrameSample(this.x, this.y);
}
