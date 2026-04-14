import '../../core/utils.dart';
import '../models/telemetry_model.dart';

typedef CustomEvent = MapEntry<String, dynamic>;

class EventDataSource {
  final Map<String, dynamic> _events = {};
  final List<CustomEventRecord> _records = [];

  void recordEvent(String name, dynamic value) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Event name cannot be empty');
    }
    _events[name] = value;
    _records.add(CustomEventRecord(name: name, value: value));
    if (_records.length > 1000) {
      _records.removeRange(0, _records.length - 1000);
    }
    CollectorUtils.safeLog('EventDataSource', 'recordEvent $name -> $value');
  }

  Map<String, dynamic> drainEvents() {
    final copy = Map<String, dynamic>.from(_events);
    _events.clear();
    return copy;
  }

  List<CustomEventRecord> drainRecords() {
    final copy = List<CustomEventRecord>.from(_records);
    _records.clear();
    return copy;
  }
}
