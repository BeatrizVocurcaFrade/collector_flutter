import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MetricChartWidget extends StatelessWidget {
  final List<FrameTiming> frameTimings;

  const MetricChartWidget({required this.frameTimings, super.key});

  @override
  Widget build(BuildContext context) {
    // Simple compact visualization: show average frame time and sparkline-like bar row
    final avgMs =
        frameTimings.isEmpty
            ? 0.0
            : frameTimings
                    .map((f) => f.totalSpan.inMilliseconds)
                    .reduce((a, b) => a + b) /
                frameTimings.length;
    final last = frameTimings.reversed.take(30).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Average frame ${avgMs.toStringAsFixed(1)} ms'),
        SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children:
                last.map((f) {
                  final val = f.totalSpan.inMilliseconds.toDouble();
                  final height = (val / 50.0).clamp(2.0, 60.0);
                  final color = val > 16.6 ? Colors.redAccent : Colors.green;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 1),
                      height: height,
                      color: color,
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
