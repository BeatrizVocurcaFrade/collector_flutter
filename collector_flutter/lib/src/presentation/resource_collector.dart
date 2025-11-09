import '../core/core.dart';
import '../data/data.dart';
import '../domain/domain.dart';
import 'cubit/cubit.dart';

class ResourceCollector {
  late final FrameDataSource _frame;
  late final MemoryDataSource _memory;
  late final HttpClientWrapper _network;
  late final EventDataSource _events;
  late final CollectorBloc _bloc;

  ResourceCollector() {
    _frame = FrameDataSource();
    _memory = MemoryDataSource();
    _network = HttpClientWrapper.instance;
    _events = EventDataSource();

    final repo = TelemetryRepositoryImpl(
      frameSource: _frame,
      memorySource: _memory,
      networkWrapper: _network,
      eventSource: _events,
    );

    _bloc = CollectorBloc(
      collectUseCase: CollectMetricsUseCase(repo),
      analyzeUseCase: AnalyzePerformanceUseCase(Analyzer()),
      recommendUseCase: GenerateRecommendationsUseCase(Recommender()),
    );
  }

  void start() {
    _frame.start();
    _memory.start();
    _bloc.dispatch(CollectorStart());
  }

  void stop() {
    _bloc.dispatch(CollectorStop());
    _frame.stop();
    _memory.stop();
  }

  void recordEvent(String name, dynamic value) =>
      _events.recordEvent(name, value);

  HttpClientWrapper get network => _network;
  CollectorBloc get bloc => _bloc;
}
