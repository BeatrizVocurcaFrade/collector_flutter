import 'dart:async';
import 'dart:developer' as developer;

class CollectorUtils {
  static String timestamp() => DateTime.now().toIso8601String();

  static void safeLog(String tag, String message) {
    developer.log(message, name: tag, time: DateTime.now());
  }

  /// Simple debounce helper
  static Function debounce(
    Function fn, [
    Duration delay = const Duration(milliseconds: 250),
  ]) {
    Timer? timer;
    return ([args]) {
      timer?.cancel();
      timer = Timer(delay, () {
        if (args == null) {
          fn();
        } else {
          fn(args);
        }
      });
    };
  }

  /// Simple running average
  static double runningAverage(double previousAvg, int count, double newVal) {
    return (previousAvg * count + newVal) / (count + 1);
  }
}
