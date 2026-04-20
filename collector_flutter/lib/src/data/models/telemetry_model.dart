import 'package:flutter/scheduler.dart';

class MemoryInfo {
  final int currentRssInBytes;
  final int heapUsageInBytes;
  final DateTime timestamp;

  MemoryInfo({
    required this.currentRssInBytes,
    required this.heapUsageInBytes,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  double get currentRssMB => currentRssInBytes / (1024 * 1024);
  double get heapUsageMB => heapUsageInBytes / (1024 * 1024);
}

class NetworkEvent {
  final String url;
  final String method;
  final int statusCode;

  /// Backwards-compatible response byte count.
  final int bytes;
  final int requestBytes;
  final int responseBytes;
  final DateTime timestamp;
  final Duration duration;
  final String? error;

  NetworkEvent({
    required this.url,
    required this.method,
    required this.statusCode,
    int? bytes,
    this.requestBytes = 0,
    int? responseBytes,
    required this.timestamp,
    required this.duration,
    this.error,
  })  : responseBytes = responseBytes ?? bytes ?? 0,
        bytes = bytes ?? responseBytes ?? 0;

  bool get failed => error != null || statusCode == 0 || statusCode >= 400;
}

class CustomEventRecord {
  final String name;
  final dynamic value;
  final DateTime timestamp;

  CustomEventRecord({
    required this.name,
    required this.value,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Snapshot de telemetria de uma sessao de monitoramento.
class TelemetryModel {
  /// Frames capturados desde a ultima coleta.
  final List<FrameTiming> frameTimings;

  /// Janela recente mantida para graficos e percentis mais estaveis.
  final List<FrameTiming> recentFrameTimings;
  final MemoryInfo? memoryInfo;
  final List<MemoryInfo> memoryHistory;
  final List<NetworkEvent> networkEvents;
  final List<NetworkEvent> networkEventsInWindow;
  final Map<String, dynamic> customEvents;
  final List<CustomEventRecord> customEventLog;

  /// Momento em que a sessão de monitoramento foi iniciada.
  final DateTime sessionStart;

  /// Momento de captura deste snapshot.
  final DateTime capturedAt;

  /// Inicio da janela desta coleta.
  final DateTime sampleStart;

  /// Duracao real entre a coleta anterior e este snapshot.
  final Duration sampleDuration;

  /// Total acumulado de frames observados na sessao.
  final int totalFrameCount;

  /// Total acumulado de requests HTTP interceptados na sessao.
  final int totalNetworkRequests;

  /// Número acumulado de rebuilds rastreados manualmente via [ResourceCollector.trackRebuild].
  final int rebuildCount;

  /// Uso de CPU do processo em % (0.0–100.0). -1.0 indica indisponível (iOS, web).
  final double cpuUsagePercent;

  /// Nível de bateria em % (0–100). -1 indica indisponível.
  final int batteryLevel;

  /// Indica se o dispositivo está carregando.
  final bool isCharging;

  TelemetryModel({
    this.frameTimings = const [],
    this.recentFrameTimings = const [],
    this.memoryInfo,
    this.memoryHistory = const [],
    this.networkEvents = const [],
    this.networkEventsInWindow = const [],
    this.customEvents = const {},
    this.customEventLog = const [],
    DateTime? sessionStart,
    DateTime? capturedAt,
    DateTime? sampleStart,
    Duration? sampleDuration,
    this.totalFrameCount = 0,
    this.totalNetworkRequests = 0,
    this.rebuildCount = 0,
    this.cpuUsagePercent = -1.0,
    this.batteryLevel = -1,
    this.isCharging = false,
  })  : sessionStart = sessionStart ?? DateTime.now(),
        capturedAt = capturedAt ?? DateTime.now(),
        sampleStart = sampleStart ?? sessionStart ?? DateTime.now(),
        sampleDuration = sampleDuration ?? Duration.zero;

  /// Duração desde o início da sessão até o momento deste snapshot.
  Duration get sessionDuration => capturedAt.difference(sessionStart);

  int get frameCountInWindow => frameTimings.length;
  int get customEventCount => customEventLog.length;

  TelemetryModel copyWith({
    List<FrameTiming>? frameTimings,
    List<FrameTiming>? recentFrameTimings,
    MemoryInfo? memoryInfo,
    List<MemoryInfo>? memoryHistory,
    List<NetworkEvent>? networkEvents,
    List<NetworkEvent>? networkEventsInWindow,
    Map<String, dynamic>? customEvents,
    List<CustomEventRecord>? customEventLog,
    DateTime? sessionStart,
    DateTime? capturedAt,
    DateTime? sampleStart,
    Duration? sampleDuration,
    int? totalFrameCount,
    int? totalNetworkRequests,
    int? rebuildCount,
    double? cpuUsagePercent,
    int? batteryLevel,
    bool? isCharging,
  }) {
    return TelemetryModel(
      frameTimings: frameTimings ?? this.frameTimings,
      recentFrameTimings: recentFrameTimings ?? this.recentFrameTimings,
      memoryInfo: memoryInfo ?? this.memoryInfo,
      memoryHistory: memoryHistory ?? this.memoryHistory,
      networkEvents: networkEvents ?? this.networkEvents,
      networkEventsInWindow:
          networkEventsInWindow ?? this.networkEventsInWindow,
      customEvents: customEvents ?? this.customEvents,
      customEventLog: customEventLog ?? this.customEventLog,
      sessionStart: sessionStart ?? this.sessionStart,
      capturedAt: capturedAt ?? this.capturedAt,
      sampleStart: sampleStart ?? this.sampleStart,
      sampleDuration: sampleDuration ?? this.sampleDuration,
      totalFrameCount: totalFrameCount ?? this.totalFrameCount,
      totalNetworkRequests: totalNetworkRequests ?? this.totalNetworkRequests,
      rebuildCount: rebuildCount ?? this.rebuildCount,
      cpuUsagePercent: cpuUsagePercent ?? this.cpuUsagePercent,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isCharging: isCharging ?? this.isCharging,
    );
  }
}
