import '../../core/utils.dart';

typedef CustomEvent = MapEntry<String, dynamic>;

class EventDataSource {
  final Map<String, dynamic> _events = {};

  void recordEvent(String name, dynamic value) {
    _events[name] = value;
    CollectorUtils.safeLog('EventDataSource', 'recordEvent $name -> $value');
  }

  Map<String, dynamic> drainEvents() {
    final copy = Map<String, dynamic>.from(_events);
    _events.clear();
    return copy;
  }
}
