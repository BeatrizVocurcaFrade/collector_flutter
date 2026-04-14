import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/utils.dart';
import '../models/telemetry_model.dart';

typedef NetworkEventCallback = void Function(NetworkEvent event);

/// HTTP client that records every request made through it.
class TelemetryHttpClient extends http.BaseClient {
  final http.Client _inner;
  final void Function(NetworkEvent event) _onEvent;

  TelemetryHttpClient(this._onEvent, {http.Client? inner})
      : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final startedAt = DateTime.now();
    final stopwatch = Stopwatch()..start();
    final requestBytes = request.contentLength ?? 0;
    var responseBytes = 0;
    var recorded = false;

    void record({
      required int statusCode,
      String? error,
    }) {
      if (recorded) return;
      recorded = true;
      stopwatch.stop();
      _onEvent(
        NetworkEvent(
          url: request.url.toString(),
          method: request.method,
          statusCode: statusCode,
          requestBytes: requestBytes,
          responseBytes: responseBytes,
          timestamp: startedAt,
          duration: stopwatch.elapsed,
          error: error,
        ),
      );
    }

    try {
      final response = await _inner.send(request);
      final countingStream = response.stream.transform<List<int>>(
        StreamTransformer.fromHandlers(
          handleData: (chunk, sink) {
            responseBytes += chunk.length;
            sink.add(chunk);
          },
          handleError: (error, stackTrace, sink) {
            record(
              statusCode: response.statusCode,
              error: error.toString(),
            );
            sink.addError(error, stackTrace);
          },
          handleDone: (sink) {
            record(statusCode: response.statusCode);
            sink.close();
          },
        ),
      );

      return http.StreamedResponse(
        http.ByteStream(countingStream),
        response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (e) {
      record(statusCode: 0, error: e.toString());
      rethrow;
    }
  }

  @override
  void close() => _inner.close();
}

/// Wrapper para interceptar requests feitos pelo [client] ou pelos atalhos
/// [get], [post], [put], [patch], [delete] e [head].
class HttpClientWrapper {
  HttpClientWrapper({http.Client? inner}) {
    client = TelemetryHttpClient(_record, inner: inner);
  }

  HttpClientWrapper._internal() : this();

  static final HttpClientWrapper instance = HttpClientWrapper._internal();

  late final http.Client client;

  final List<NetworkEvent> _events = [];
  final List<NetworkEventCallback> _listeners = [];
  final int maxEvents = 1000;

  void addListener(NetworkEventCallback cb) {
    if (!_listeners.contains(cb)) _listeners.add(cb);
  }

  void removeListener(NetworkEventCallback cb) => _listeners.remove(cb);

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) =>
      client.get(uri, headers: headers);

  Future<http.Response> head(Uri uri, {Map<String, String>? headers}) =>
      client.head(uri, headers: headers);

  Future<http.Response> delete(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      client.delete(uri, headers: headers, body: body, encoding: encoding);

  Future<http.Response> patch(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      client.patch(uri, headers: headers, body: body, encoding: encoding);

  Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      client.post(uri, headers: headers, body: body, encoding: encoding);

  Future<http.Response> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      client.put(uri, headers: headers, body: body, encoding: encoding);

  void _record(NetworkEvent event) {
    _events.add(event);
    if (_events.length > maxEvents) {
      _events.removeRange(0, _events.length - maxEvents);
    }
    _notify(event);
  }

  void _notify(NetworkEvent ev) {
    for (final cb in List<NetworkEventCallback>.from(_listeners)) {
      try {
        cb(ev);
      } catch (e) {
        CollectorUtils.safeLog(
          'NetworkDataSource',
          'listener error: $e',
        );
      }
    }
    CollectorUtils.safeLog(
      'NetworkDataSource',
      'event ${ev.method} ${ev.url} ${ev.statusCode} '
          '${ev.responseBytes}B ${ev.duration.inMilliseconds}ms',
    );
  }

  List<NetworkEvent> drainEvents() {
    final copy = List<NetworkEvent>.from(_events);
    _events.clear();
    return copy;
  }

  void dispose() => client.close();
}
