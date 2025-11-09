import 'dart:async';
import '../../domain/domain.dart';
import 'collector_event.dart';
import 'collector_state.dart';

typedef StateCallback = void Function(CollectorState);

class CollectorBloc {
  final CollectMetricsUseCase collectUseCase;
  final AnalyzePerformanceUseCase analyzeUseCase;
  final GenerateRecommendationsUseCase recommendUseCase;

  CollectorState _state = CollectorIdle();
  final _controller = StreamController<CollectorState>.broadcast();

  CollectorBloc({
    required this.collectUseCase,
    required this.analyzeUseCase,
    required this.recommendUseCase,
  });

  Stream<CollectorState> get stream => _controller.stream;
  CollectorState get state => _state;

  void dispatch(CollectorEvent event) async {
    if (event is CollectorStart) return _start();
    if (event is CollectorStop) return _stop();
    if (event is CollectorCollectNow) return await _collectNow();
  }

  Timer? _periodic;

  void _start() {
    _setState(CollectorRunning());
    _periodic?.cancel();
    _periodic = Timer.periodic(Duration(seconds: 5), (_) => _collectNow());
    _collectNow();
  }

  void _stop() {
    _periodic?.cancel();
    _periodic = null;
    _setState(CollectorIdle());
  }

  Future<void> _collectNow() async {
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
