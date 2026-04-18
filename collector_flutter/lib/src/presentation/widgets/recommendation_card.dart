import 'package:flutter/material.dart';
import '../../core/recommender.dart';

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  const RecommendationCard({required this.recommendation, super.key});

  Color _colorFor(Severity s) {
    switch (s) {
      case Severity.high:
        return Colors.red.shade400;
      case Severity.medium:
        return Colors.orange.shade400;
      case Severity.low:
        return Colors.yellow.shade700;
      case Severity.info:
        return Colors.green.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _colorFor(recommendation.severity).withValues(alpha: 0.12),
      child: ListTile(
        leading: Icon(Icons.report_problem),
        title: Text(recommendation.title),
        subtitle: Text(recommendation.detail),
      ),
    );
  }
}
