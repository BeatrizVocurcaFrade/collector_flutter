import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/telemetry_model.dart';
import '../../core/utils.dart';

typedef NetworkEventCallback = void Function(NetworkEvent event);

/// Wrapper simples para interceptar requisições http.
/// Use HttpClientWrapper.instance.client to fazer requests.
class HttpClientWrapper {
  HttpClientWrapper._internal();

  static final HttpClientWrapper instance = HttpClientWrapper._internal();

  final http.Client client = http.Client();

  final List<NetworkEvent> _events = [];
  final List<NetworkEventCallback> _listeners = [];

  void addListener(NetworkEventCallback cb) => _listeners.add(cb);
  void removeListener(NetworkEventCallback cb) => _listeners.remove(cb);

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) =>
      _intercept(
        () => client.get(uri, headers: headers),
        'GET',
        uri.toString(),
      );

  Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => _intercept(
    () => client.post(uri, headers: headers, body: body, encoding: encoding),
    'POST',
    uri.toString(),
  );

  Future<T> _intercept<T extends http.Response>(
    Future<T> Function() fn,
    String method,
    String url,
  ) async {
    final start = DateTime.now();
    try {
      final resp = await fn();
      final duration = DateTime.now().difference(start);
      final ev = NetworkEvent(
        url: url,
        method: method,
        statusCode: resp.statusCode,
        bytes: resp.contentLength ?? resp.bodyBytes.length,
        timestamp: start,
        duration: duration,
      );
      _events.add(ev);
      _notify(ev);
      if (_events.length > 1000) _events.removeRange(0, _events.length - 1000);
      return resp;
    } catch (e) {
      final duration = DateTime.now().difference(start);
      final ev = NetworkEvent(
        url: url,
        method: method,
        statusCode: 0,
        bytes: 0,
        timestamp: start,
        duration: duration,
      );
      _events.add(ev);
      _notify(ev);
      rethrow;
    }
  }

  void _notify(NetworkEvent ev) {
    for (final cb in _listeners) {
      try {
        cb(ev);
      } catch (_) {}
    }
    CollectorUtils.safeLog(
      'NetworkDataSource',
      'event ${ev.method} ${ev.url} ${ev.statusCode} ${ev.duration.inMilliseconds}ms',
    );
  }

  List<NetworkEvent> drainEvents() {
    final copy = List<NetworkEvent>.from(_events);
    _events.clear();
    return copy;
  }
}
