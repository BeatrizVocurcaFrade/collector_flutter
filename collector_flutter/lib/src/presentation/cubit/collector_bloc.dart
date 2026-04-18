import 'dart:async';
import '../../domain/domain.dart';
import 'collector_event.dart';
import 'collector_state.dart';

typedef StateCallback = void Function(CollectorState);

class CollectorBloc {
  final CollectMetricsUseCase collectUseCase;
  final AnalyzePerformanceUseCase analyzeUseCase;
  final GenerateRecommendationsUseCase recommendUseCase;
  final Duration collectInterval;

  CollectorState _state = CollectorIdle();
  final _controller = StreamController<CollectorState>.broadcast();

  CollectorBloc({
    required this.collectUseCase,
    required this.analyzeUseCase,
    required this.recommendUseCase,
    this.collectInterval = const Duration(seconds: 2),
  });

  Stream<CollectorState> get stream => _controller.stream;
  CollectorState get state => _state;

  Future<void> collectNow() => _collectNow();

  void dispatch(CollectorEvent event) {
    if (event is CollectorStart) {
      _start();
      return;
    }
    if (event is CollectorStop) {
      _stop();
      return;
    }
    if (event is CollectorCollectNow) {
      unawaited(_collectNow());
    }
  }

  Timer? _periodic;
  bool _collecting = false;
  bool _collectAgain = false;
  Completer<void>? _activeCollection;

  void _start() {
    _setState(CollectorRunning());
    _periodic?.cancel();
    _periodic = Timer.periodic(
      collectInterval,
      (_) => unawaited(collectNow()),
    );
    unawaited(collectNow());
  }

  void _stop() {
    _periodic?.cancel();
    _periodic = null;
    _setState(CollectorIdle());
  }

  Future<void> _collectNow() async {
    if (_collecting) {
      _collectAgain = true;
      return _activeCollection?.future ?? Future<void>.value();
    }

    _collecting = true;
    final completer = Completer<void>();
    _activeCollection = completer;
    try {
      do {
        _collectAgain = false;
        await _collectOnce();
      } while (_collectAgain);
    } finally {
      _collecting = false;
      _activeCollection = null;
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  Future<void> _collectOnce() async {
    try {
      final telemetry = await collectUseCase();
      final analysis = analyzeUseCase(telemetry);
      final recs = recommendUseCase(analysis);
      _setState(
        CollectorData(
          telemetry: telemetry.model,
          analysis: analysis,
          recommendations: recs,
        ),
      );
    } catch (e) {
      _setState(CollectorError(e.toString()));
    }
  }

  void _setState(CollectorState s) {
    _state = s;
    _controller.add(s);
  }

  void dispose() {
    _periodic?.cancel();
    _controller.close();
  }
}
