import '../../domain/repositories/i_resource_repository.dart';
import '../datasources/frame_data_source.dart';
import '../datasources/memory_data_source.dart';
import '../datasources/network_data_source.dart';
import '../datasources/event_data_source.dart';
import '../models/telemetry_model.dart';

class TelemetryRepositoryImpl implements IResourceRepository {
  final FrameDataSource frameSource;
  final MemoryDataSource memorySource;
  final HttpClientWrapper networkWrapper;
  final EventDataSource eventSource;

  TelemetryRepositoryImpl({
    required this.frameSource,
    required this.memorySource,
    required this.networkWrapper,
    required this.eventSource,
  });

  @override
  Future<TelemetryModel> collect() async {
    final frames = frameSource.drain();
    final mem = memorySource.last;
    final network = networkWrapper.drainEvents();
    final events = eventSource.drainEvents();

    return TelemetryModel(
      frameTimings: frames,
      memoryInfo: mem,
      networkEvents: network,
      customEvents: events,
    );
  }
}
