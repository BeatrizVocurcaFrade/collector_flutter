import '../../data/models/telemetry_model.dart';

/// Domain entity wrapper (keeps parity with model)
class Telemetry {
  final TelemetryModel model;

  Telemetry(this.model);
  factory Telemetry.empty() {
    return Telemetry(TelemetryModel());
  }
}
