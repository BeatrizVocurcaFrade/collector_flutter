import 'package:flutter/scheduler.dart';
import '../../core/utils.dart';

/// Collects frame timings using SchedulerBinding.addTimingsCallback
class FrameDataSource {
  final List<FrameTiming> _buffer = [];
  bool _listening = false;

  void start() {
    if (_listening) return;
    _listening = true;
    SchedulerBinding.instance.addTimingsCallback(_handleTimings);
    CollectorUtils.safeLog('FrameDataSource', 'started frame timings listener');
  }

  void stop() {
    if (!_listening) return;
    _listening = false;
    try {
      SchedulerBinding.instance.removeTimingsCallback(_handleTimings);
    } catch (e) {
      // removeTimingsCallback is not available on some Flutter versions; ignore
    }
    CollectorUtils.safeLog('FrameDataSource', 'stopped frame timings listener');
  }

  void _handleTimings(List<FrameTiming> timings) {
    _buffer.addAll(timings);
    // Keep buffer reasonable size
    if (_buffer.length > 500) {
      _buffer.removeRange(0, _buffer.length - 500);
    }
  }

  List<FrameTiming> drain() {
    final copy = List<FrameTiming>.from(_buffer);
    _buffer.clear();
    return copy;
  }
}
