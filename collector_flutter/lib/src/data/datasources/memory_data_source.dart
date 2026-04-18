import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';
import '../../data/models/telemetry_model.dart';
import '../../core/utils.dart';

/// Coleta informações de memória usando vm_service em modo profile/debug.
/// Fallback para ProcessInfo se não conectado.
class MemoryDataSource {
  final int maxSamples;

  VmService? _vmService;
  Timer? _timer;
  MemoryInfo? _last;
  final List<MemoryInfo> _samples = [];
  bool _starting = false;
  Future<void>? _activeCollect;

  MemoryDataSource({this.maxSamples = 120});

  Future<void> start({Duration interval = const Duration(seconds: 5)}) async {
    if (_timer != null || _starting) return;
    _starting = true;
    try {
      await _connectVmService();
      await collectNow();
      _timer = Timer.periodic(interval, (_) => unawaited(collectNow()));
    } finally {
      _starting = false;
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    final service = _vmService;
    _vmService = null;
    if (service != null) {
      unawaited(service.dispose());
    }
  }

  /// Forces a memory sample immediately.
  ///
  /// This is useful for demos and user-triggered diagnostics, where waiting for
  /// the periodic timer makes the UI feel out of sync with the action.
  Future<MemoryInfo?> collectNow() async {
    final activeCollect = _activeCollect;
    if (activeCollect != null) {
      await activeCollect;
      return _last;
    }

    final collect = _collect();
    _activeCollect = collect;
    try {
      await collect;
    } finally {
      if (identical(_activeCollect, collect)) {
        _activeCollect = null;
      }
    }
    return _last;
  }

  Future<void> _connectVmService() async {
    if (_vmService != null) return;
    try {
      final uri = (await Service.getInfo()).serverUri;
      if (uri == null) return;

      final wsUri = convertToWebSocketUrl(serviceProtocolUrl: uri).toString();
      _vmService = await vmServiceConnectUri(wsUri);
      CollectorUtils.safeLog(
        'MemoryDataSource',
        'Connected to vm_service at $wsUri',
      );
    } catch (e) {
      CollectorUtils.safeLog(
        'MemoryDataSource',
        'Could not connect vm_service: $e',
      );
    }
  }

  Future<void> _collect() async {
    try {
      int rss = ProcessInfo.currentRss;
      int heap = 0;

      if (_vmService != null) {
        final heapStats = await _vmService!.getVM();
        if (heapStats.isolates?.isNotEmpty ?? false) {
          final isolateId = heapStats.isolates!.first.id!;
          final mem = await _vmService!.getAllocationProfile(isolateId);
          heap = mem.memoryUsage?.heapUsage ?? 0;
        }
      }

      final sample = MemoryInfo(
        currentRssInBytes: rss,
        heapUsageInBytes: heap,
      );
      _last = sample;
      _samples.add(sample);
      if (_samples.length > maxSamples) {
        _samples.removeRange(0, _samples.length - maxSamples);
      }
    } catch (e) {
      CollectorUtils.safeLog('MemoryDataSource', 'collect error: $e');
    }
  }

  MemoryInfo? get last => _last;

  List<MemoryInfo> drainSamples() {
    final copy = List<MemoryInfo>.from(_samples);
    _samples.clear();
    return copy;
  }
}
