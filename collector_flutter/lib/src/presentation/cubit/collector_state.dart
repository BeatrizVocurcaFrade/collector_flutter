import '../../core/core.dart';
import '../../data/data.dart';

abstract class CollectorState {}

class CollectorIdle extends CollectorState {}

class CollectorRunning extends CollectorState {}

class CollectorData extends CollectorState {
  final TelemetryModel telemetry;
  final AnalysisResult analysis;
  final List<Recommendation> recommendations;

  CollectorData({
    required this.telemetry,
    required this.analysis,
    required this.recommendations,
  });
}

class CollectorError extends CollectorState {
  final String message;
  CollectorError(this.message);
}
