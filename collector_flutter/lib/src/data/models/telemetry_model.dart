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

/// Telemetry agregada
class TelemetryModel {
  final List<FrameTiming> frameTimings;
  final MemoryInfo? memoryInfo;
  final List<NetworkEvent> networkEvents;
  final Map<String, dynamic> customEvents;

  TelemetryModel({
    this.frameTimings = const [],
    this.memoryInfo,
    this.networkEvents = const [],
    this.customEvents = const {},
  });

  TelemetryModel copyWith({
    List<FrameTiming>? frameTimings,
    MemoryInfo? memoryInfo,
    List<NetworkEvent>? networkEvents,
    Map<String, dynamic>? customEvents,
  }) {
    return TelemetryModel(
      frameTimings: frameTimings ?? this.frameTimings,
      memoryInfo: memoryInfo ?? this.memoryInfo,
      networkEvents: networkEvents ?? this.networkEvents,
      customEvents: customEvents ?? this.customEvents,
    );
  }
}
