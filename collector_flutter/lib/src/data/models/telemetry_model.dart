import 'package:flutter/scheduler.dart';

class MemoryInfo {
  final int currentRssInBytes;
  final int heapUsageInBytes;

  MemoryInfo({required this.currentRssInBytes, required this.heapUsageInBytes});
}

class NetworkEvent {
  final String url;
  final String method;
  final int statusCode;
  final int bytes;
  final DateTime timestamp;
  final Duration duration;

  NetworkEvent({
    required this.url,
    required this.method,
    required this.statusCode,
    required this.bytes,
    required this.timestamp,
    required this.duration,
  });
}

/// Telemetria agregada por ciclo de coleta.
class TelemetryModel {
  final List<FrameTiming> frameTimings;
  final MemoryInfo? memoryInfo;
  final List<NetworkEvent> networkEvents;
  final Map<String, dynamic> customEvents;

  /// Momento em que a sessão de monitoramento foi iniciada.
  final DateTime sessionStart;

  /// Número acumulado de rebuilds rastreados manualmente via [ResourceCollector.trackRebuild].
  final int rebuildCount;

  TelemetryModel({
    this.frameTimings = const [],
    this.memoryInfo,
    this.networkEvents = const [],
    this.customEvents = const {},
    DateTime? sessionStart,
    this.rebuildCount = 0,
  }) : sessionStart = sessionStart ?? DateTime.now();

  /// Duração desde o início da sessão até agora.
  Duration get sessionDuration => DateTime.now().difference(sessionStart);

  TelemetryModel copyWith({
    List<FrameTiming>? frameTimings,
    MemoryInfo? memoryInfo,
    List<NetworkEvent>? networkEvents,
    Map<String, dynamic>? customEvents,
    DateTime? sessionStart,
    int? rebuildCount,
  }) {
    return TelemetryModel(
      frameTimings: frameTimings ?? this.frameTimings,
      memoryInfo: memoryInfo ?? this.memoryInfo,
      networkEvents: networkEvents ?? this.networkEvents,
      customEvents: customEvents ?? this.customEvents,
      sessionStart: sessionStart ?? this.sessionStart,
      rebuildCount: rebuildCount ?? this.rebuildCount,
    );
  }
}
