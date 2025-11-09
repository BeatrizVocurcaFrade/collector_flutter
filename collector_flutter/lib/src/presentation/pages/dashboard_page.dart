import 'package:flutter/material.dart';
import 'dart:ui' as ui show FrameTiming;

import 'package:syncfusion_flutter_charts/charts.dart';
import '../../core/recommender.dart';
import '../cubit/cubit.dart';
import '../resource_collector.dart';

class DashboardPage extends StatefulWidget {
  final ResourceCollector collector;
  const DashboardPage({super.key, required this.collector});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final ResourceCollector collector;

  @override
  void initState() {
    super.initState();
    collector = widget.collector;
    collector.bloc.stream.listen((state) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = collector.bloc.state;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Builder(
        builder: (_) {
          if (state is CollectorData) {
            return _buildDashboard(context, state);
          } else if (state is CollectorError) {
            return Center(
              child: Text(
                '⚠️ Erro: ${state.message}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, CollectorData state) {
    final fps = state.analysis.estimatedFps.toStringAsFixed(1);
    final memoryMB = (state.analysis.memoryBytes / (1024 * 1024))
        .toStringAsFixed(1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          MetricHeader(
            fps: fps,
            memory: memoryMB,
            jank: state.analysis.longFrames,
          ),
          const SizedBox(height: 10),
          FrameChart(frames: state.telemetry.frameTimings),
          const SizedBox(height: 10),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tips_and_updates_outlined),
                    const SizedBox(width: 10),
                    Text(
                      'Recomendações',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                ...state.recommendations.map(
                  (r) => RecommendationCardTile(r: r),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
// ──────────────────────────────── METRICS ────────────────────────────────
//

class MetricHeader extends StatelessWidget {
  final String fps;
  final String memory;
  final int jank;

  const MetricHeader({
    super.key,
    required this.fps,
    required this.memory,
    required this.jank,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        MetricCard(
          icon: Icons.speed,
          title: 'FPS',
          value: fps,
          color: Colors.greenAccent.shade400,
          info:
              'Indica fluidez da interface.\nIdeal acima de 55 FPS.\n💡 Evite rebuilds desnecessários.',
        ),
        SizedBox(width: 10),
        MetricCard(
          icon: Icons.memory,
          title: 'Memória',
          value: '$memory MB',
          color: Colors.blueAccent.shade400,
          info:
              'Mostra o uso de memória (RSS).\nAcima de 200MB pode indicar leaks.\n💡 Revise listas, streams e caches.',
        ),
        SizedBox(width: 10),
        MetricCard(
          icon: Icons.warning_amber,
          title: 'Jank',
          value: '$jank frames',
          color: Colors.orange.shade400,
          info:
              'Frames lentos (>16ms).\n💡 Use profiling e minimize trabalho dentro de setState().',
        ),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String info;
  final Color color;
  final IconData icon;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showInfo(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 95,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: color.withValues(alpha: 0.08),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: color.darken()),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color.darken(),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color.darken(),
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
            title: Text(title),
            content: Text(info, style: const TextStyle(fontSize: 15)),
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

//
// ──────────────────────────────── FRAME CHART ────────────────────────────────
//

class FrameChart extends StatelessWidget {
  final List<ui.FrameTiming> frames;
  const FrameChart({super.key, required this.frames});

  @override
  Widget build(BuildContext context) {
    final data =
        frames.takeLast(50).map((f) {
          return _FrameSample(
            DateTime.now().microsecondsSinceEpoch.toDouble(),
            f.totalSpan.inMilliseconds.toDouble(),
          );
        }).toList();

    return SizedBox(
      height: 200,
      child: Card(
        elevation: 5,
        shadowColor: Colors.blueAccent.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SfCartesianChart(
            borderWidth: 0,
            plotAreaBorderWidth: 0,
            primaryXAxis: NumericAxis(isVisible: false),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: 'ms por frame'),
              axisLine: const AxisLine(width: 0),
              labelStyle: const TextStyle(color: Colors.grey),
            ),
            series: <CartesianSeries<_FrameSample, double>>[
              SplineAreaSeries<_FrameSample, double>(
                dataSource: data,
                xValueMapper: (d, _) => d.x,
                yValueMapper: (d, _) => d.y,
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent.withValues(alpha: 0.6),
                    Colors.blueAccent.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                splineType: SplineType.cardinal,
                name: 'Frame Time',
                animationDuration: 800,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// ──────────────────────────────── RECOMMENDATIONS ────────────────────────────────
//

class RecommendationCardTile extends StatelessWidget {
  final Recommendation r;
  const RecommendationCardTile({super.key, required this.r});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(r.severity);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: Icon(_iconFor(r.severity), color: color, size: 30),
          title: Text(
            r.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color.darken(),
            ),
          ),
          subtitle: Text(r.detail, maxLines: 2, softWrap: true),
          onTap: () => _showSnack(context, color),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color.withValues(alpha: 0.9),
        content: Text(
          '${r.title}\n${r.detail}',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Color _colorFor(Severity s) => switch (s) {
    Severity.high => Colors.redAccent,
    Severity.medium => Colors.orangeAccent,
    Severity.low => Colors.amber.shade700,
    Severity.info => Colors.greenAccent.shade700,
  };

  IconData _iconFor(Severity s) => switch (s) {
    Severity.high => Icons.warning,
    Severity.medium => Icons.report_problem,
    Severity.low => Icons.lightbulb,
    Severity.info => Icons.check_circle,
  };
}

//
// ──────────────────────────────── HELPERS ────────────────────────────────
//

extension TakeLastExtension<T> on List<T> {
  List<T> takeLast(int n) =>
      length <= n ? List<T>.from(this) : sublist(length - n);
}

extension ColorShade on Color {
  Color darken([double amount = .2]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}

class _FrameSample {
  final double x;
  final double y;
  _FrameSample(this.x, this.y);
}
