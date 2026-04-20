import 'package:flutter/services.dart';

class BatteryDataSource {
  static const _channel = MethodChannel('collector_flutter/system');

  /// Returns battery level in % (0–100).
  /// Returns -1 when unavailable.
  Future<int> getBatteryLevel() async {
    try {
      final result = await _channel.invokeMethod<int>('getBatteryLevel');
      return result ?? -1;
    } on MissingPluginException {
      return -1;
    } on PlatformException {
      return -1;
    }
  }

  /// Returns true when device is charging or fully charged.
  Future<bool> isCharging() async {
    try {
      final result = await _channel.invokeMethod<bool>('isCharging');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
