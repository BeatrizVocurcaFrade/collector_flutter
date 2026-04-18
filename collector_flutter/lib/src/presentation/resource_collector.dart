import '../core/core.dart';
import '../data/data.dart';
import '../domain/domain.dart';
import 'cubit/cubit.dart';

/// Main entry point for the collector_flutter package.
///
/// Coordinates all data sources (frame, memory, network, events) and
/// exposes the collection lifecycle ([start], [stop], [dispose]) and
/// the reactive state stream via [bloc].
///
/// ```dart
/// final collector = ResourceCollector();
/// await collector.start();
/// // ...
/// collector.dispose();
/// ```
class ResourceCollector {
  /// How often metrics are aggregated and emitted to listeners.
  final Duration collectionInterval;

  /// Performance thresholds used by the heuristic [Analyzer].
  /// Defaults to 60 FPS / 300 MB memory / 50 HTTP requests if `null`.
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

  /// Starts all data sources and the periodic collection cycle.
  ///
  /// Call this once, typically in `initState` or before pushing [DashboardPage].
  /// Safe to await — resolves after the VM Service connection is established.
  Future<void> start() async {
    _frame.start();
    // Sincroniza coleta de memória com coleta de métricas
    // Usa intervalo ligeiramente menor para garantir que há sempre dados frescos
    await _memory.start(interval: collectionInterval * 0.9);
    _bloc.dispatch(CollectorStart());
  }

  /// Stops all data sources and the collection cycle without releasing resources.
  ///
  /// Call [dispose] instead when the collector will no longer be used.
  void stop() {
    _bloc.dispatch(CollectorStop());
    _frame.stop();
    _memory.stop();
  }

  /// Stops collection and releases all resources (streams, VM Service, HTTP client).
  ///
  /// Call this in the `dispose` method of the widget that owns the collector.
  void dispose() {
    stop();
    _bloc.dispose();
    _network.dispose();
  }

  /// Records a named application event with an associated value.
  ///
  /// Events appear in the dashboard network panel and are included in JSON
  /// exports. [value] can be any JSON-serialisable object.
  void recordEvent(String name, dynamic value) =>
      _events.recordEvent(name, value);

  /// Registra um rebuild de widget para rastreamento de excessos.
  void trackRebuild() => _repo.incrementRebuild();

  /// Coleta imediatamente e emite um novo snapshot no dashboard.
  ///
  /// Use [forceMemory] quando uma ação acabou de alterar uso de memória e não
  /// deve esperar o próximo tick do coletor periódico.
  Future<void> collectNow({bool forceMemory = false}) async {
    if (forceMemory) {
      await _memory.collectNow();
    }
    await _bloc.collectNow();
  }

  HttpClientWrapper get network => _network;
  CollectorBloc get bloc => _bloc;
}
