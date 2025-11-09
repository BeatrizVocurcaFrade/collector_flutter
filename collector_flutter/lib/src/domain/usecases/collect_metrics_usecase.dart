import '../entities/telemetry.dart';
import '../repositories/i_resource_repository.dart';
import '../../data/models/telemetry_model.dart';

class CollectMetricsUseCase {
  final IResourceRepository repo;
  CollectMetricsUseCase(this.repo);

  Future<Telemetry> call() async {
    final TelemetryModel model = await repo.collect();
    return Telemetry(model);
  }
}
