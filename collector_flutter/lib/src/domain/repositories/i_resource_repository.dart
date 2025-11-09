import '../../data/models/telemetry_model.dart';

abstract class IResourceRepository {
  Future<TelemetryModel> collect();
}
