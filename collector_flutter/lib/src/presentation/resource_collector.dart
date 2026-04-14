import '../core/core.dart';
import '../data/data.dart';
import '../domain/domain.dart';
import 'cubit/cubit.dart';

class ResourceCollector {
  final Duration collectionInterval;
  final PerformanceBudget? budget;

  late final FrameDataSource _frame;
  late final MemoryDataSource _memory;
  late final HttpClientWrapper _network;
  late final EventDataSource _events;
  late final TelemetryRepositoryImpl _repo;
  late final CollectorBloc _bloc;

  ResourceCollector({
    this.collectionInterval = const Duration(seconds: 2),
    this.budget,
  }) {
    _frame = FrameDataSource();
    _memory = MemoryDataSource();
    _network = HttpClientWrapper();
    _events = EventDataSource();

    _repo = TelemetryRepositoryImpl(
      frameSource: _frame,
      memorySource: _memory,
      networkWrapper: _network,
      eventSource: _events,
    );

    _bloc = CollectorBloc(
      collectUseCase: CollectMetricsUseCase(_repo),
      analyzeUseCase: AnalyzePerformanceUseCase(Analyzer(budget: budget)),
      recommendUseCase: GenerateRecommendationsUseCase(Recommender()),
      collectInterval: collectionInterval,
    );
  }

  Future<void> start() async {
    _frame.start();
    // Sincroniza coleta de memória com coleta de métricas
    // Usa intervalo ligeiramente menor para garantir que há sempre dados frescos
    await _memory.start(interval: collectionInterval * 0.9);
    _bloc.dispatch(CollectorStart());
  }

  void stop() {
    _bloc.dispatch(CollectorStop());
    _frame.stop();
    _memory.stop();
  }

  void dispose() {
    stop();
    _bloc.dispose();
    _network.dispose();
  }

  void recordEvent(String name, dynamic value) =>
      _events.recordEvent(name, value);

  /// Registra um rebuild de widget para rastreamento de excessos.
  void trackRebuild() => _repo.incrementRebuild();

  HttpClientWrapper get network => _network;
  CollectorBloc get bloc => _bloc;
}
