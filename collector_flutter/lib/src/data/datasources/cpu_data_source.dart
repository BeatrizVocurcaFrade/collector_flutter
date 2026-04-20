import 'package:flutter/services.dart';

class CpuDataSource {
  static const _channel = MethodChannel('collector_flutter/system');

  /// Returns CPU usage in % (0.0–100.0).
  /// Returns -1.0 when the platform channel is unavailable (e.g., iOS, web).
  Future<double> getCpuUsage() async {
    try {
      final result = await _channel.invokeMethod<double>('getCpuUsage');
      return result ?? -1.0;
    } on MissingPluginException {
      return -1.0;
    } on PlatformException {
      return -1.0;
    }
  }
}
