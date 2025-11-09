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
  VmService? _vmService;
  Timer? _timer;
  MemoryInfo? _last;

  Future<void> start({Duration interval = const Duration(seconds: 5)}) async {
    try {
      final uri = (await Service.getInfo()).serverUri;
      if (uri != null) {
        final wsUri = convertToWebSocketUrl(serviceProtocolUrl: uri).toString();
        _vmService = await vmServiceConnectUri(wsUri);
        CollectorUtils.safeLog(
          'MemoryDataSource',
          'Connected to vm_service at $wsUri',
        );
      }
    } catch (e) {
      CollectorUtils.safeLog(
        'MemoryDataSource',
        'Could not connect vm_service: $e',
      );
    }

    _timer = Timer.periodic(interval, (_) => _collect());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
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

      _last = MemoryInfo(currentRssInBytes: rss, heapUsageInBytes: heap);
    } catch (e) {
      CollectorUtils.safeLog('MemoryDataSource', 'collect error: $e');
    }
  }

  MemoryInfo? get last => _last;
}
