import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../core/recommender.dart';
import '../cubit/cubit.dart';
import '../resource_collector.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final ResourceCollector collector;

  @override
  void initState() {
    super.initState();
    collector = ResourceCollector();
    collector.start();
    collector.bloc.dispatch(CollectorStart());
    collector.bloc.stream.listen((_) => mounted ? setState(() {}) : null);
  }

  @override
  Widget build(BuildContext context) {
    final state = collector.bloc.state;

    if (state is CollectorData) {
      final fps = state.analysis.estimatedFps.toStringAsFixed(1);
      final memoryMB = (state.analysis.memoryBytes / (1024 * 1024))
          .toStringAsFixed(1);
      final recs = state.recommendations;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, fps, memoryMB, state.analysis.longFrames),
            const SizedBox(height: 20),
            _buildChart(context, state.telemetry.frameTimings),
            const SizedBox(height: 20),
            _buildRecommendations(recs),
          ],
        ),
      );
    }

    if (state is CollectorError) {
      return Center(child: Text('Erro: ${state.message}'));
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildHeader(BuildContext context, String fps, String mem, int jank) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _metricCard('FPS', fps, 'Frames por segundo — ideal acima de 55.'),
        _metricCard('Memória', '$mem MB', 'Memória RSS do processo Flutter.'),
        _metricCard(
          'Jank',
          '$jank frames',
          'Frames longos acima do limite (travamentos visuais).',
        ),
      ],
    );
  }

  Widget _metricCard(String label, String value, String help) {
    return Tooltip(
      message: help,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 110,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, List<FrameTiming> frames) {
    final data =
        frames.takeLast(50).map((f) {
          return _FrameSample(
            DateTime.now().microsecondsSinceEpoch.toDouble(),
            f.totalSpan.inMilliseconds.toDouble(),
          );
        }).toList();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SfCartesianChart(
          primaryXAxis: NumericAxis(isVisible: false),
          primaryYAxis: NumericAxis(title: AxisTitle(text: 'ms por frame')),
          series: <CartesianSeries<_FrameSample, double>>[
            AreaSeries<_FrameSample, double>(
              dataSource: data,
              xValueMapper: (d, _) => d.x,
              yValueMapper: (d, _) => d.y,
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withValues(alpha: 0.6),
                  Colors.blueAccent.withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              name: 'Frame Time',
              animationDuration: 800,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(List<Recommendation> recs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recomendações', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        ...recs.map(
          (r) => Card(
            color: _colorFor(r.severity).withValues(alpha: 0.1),
            child: ListTile(
              leading: Icon(Icons.lightbulb, color: _colorFor(r.severity)),
              title: Text(r.title),
              subtitle: Text(r.detail),
            ),
          ),
        ),
      ],
    );
  }

  Color _colorFor(Severity s) {
    switch (s) {
      case Severity.high:
        return Colors.red;
      case Severity.medium:
        return Colors.orange;
      case Severity.low:
        return Colors.yellow.shade800;
      case Severity.info:
        return Colors.green;
    }
  }
}

class _FrameSample {
  final double x;
  final double y;
  _FrameSample(this.x, this.y);
}

extension TakeLastExtension<T> on List<T> {
  List<T> takeLast(int n) {
    if (length <= n) return List<T>.from(this);
    return sublist(length - n);
  }
}
