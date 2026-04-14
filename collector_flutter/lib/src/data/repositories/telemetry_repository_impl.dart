import 'package:flutter/scheduler.dart';

import '../../domain/repositories/i_resource_repository.dart';
import '../datasources/frame_data_source.dart';
import '../datasources/memory_data_source.dart';
import '../datasources/network_data_source.dart';
import '../datasources/event_data_source.dart';
import '../models/telemetry_model.dart';

class TelemetryRepositoryImpl implements IResourceRepository {
  final FrameDataSource frameSource;
  final MemoryDataSource memorySource;
  final HttpClientWrapper networkWrapper;
  final EventDataSource eventSource;
  final int maxRecentFrames;
  final int maxNetworkEvents;
  final int maxMemorySamples;
  final int maxCustomEvents;

  final DateTime _sessionStart = DateTime.now();
  late DateTime _lastCollectAt = _sessionStart;
  int _rebuildCount = 0;
  int _totalFrameCount = 0;
  int _totalNetworkRequests = 0;
  final List<FrameTiming> _recentFrames = [];
  final List<MemoryInfo> _memoryHistory = [];
  final List<NetworkEvent> _networkHistory = [];
  final Map<String, dynamic> _customEventLatest = {};
  final List<CustomEventRecord> _customEventLog = [];
  MemoryInfo? _lastMemorySnapshot;

  TelemetryRepositoryImpl({
    required this.frameSource,
    required this.memorySource,
    required this.networkWrapper,
    required this.eventSource,
    this.maxRecentFrames = 300,
    this.maxNetworkEvents = 1000,
    this.maxMemorySamples = 120,
    this.maxCustomEvents = 1000,
  });

  /// Incrementa o contador de rebuilds. Chamado via [ResourceCollector.trackRebuild].
  void incrementRebuild() => _rebuildCount++;

  @override
  Future<TelemetryModel> collect() async {
    final capturedAt = DateTime.now();
    final sampleStart = _lastCollectAt;
    final sampleDuration = capturedAt.difference(sampleStart);
    _lastCollectAt = capturedAt;

    // Coleta frames
    final frames = frameSource.drain();
    _totalFrameCount += frames.length;
    _recentFrames.addAll(frames);
    _trim(_recentFrames, maxRecentFrames);

    // Coleta memória: sempre tenta trazer amostra mais recente
    final memorySamples = memorySource.drainSamples();
    MemoryInfo? currentMemory;

    if (memorySamples.isNotEmpty) {
      _memoryHistory.addAll(memorySamples);
      _trim(_memoryHistory, maxMemorySamples);
      currentMemory = memorySamples.last;
      _lastMemorySnapshot = currentMemory;
    } else {
      // Se não há amostras drenadas, tenta take a última captura do memorySource
      final lastMemory = memorySource.last;
      if (lastMemory != null) {
        // Só adiciona se é diferente da anterior (evita duplicatas)
        if (_lastMemorySnapshot == null ||
            lastMemory.timestamp
                    .difference(_lastMemorySnapshot!.timestamp)
                    .inMilliseconds >
                100) {
          _memoryHistory.add(lastMemory);
          _trim(_memoryHistory, maxMemorySamples);
          _lastMemorySnapshot = lastMemory;
          currentMemory = lastMemory;
        } else {
          currentMemory = _lastMemorySnapshot;
        }
      }
    }

    // Coleta rede
    final networkInWindow = networkWrapper.drainEvents();
    _totalNetworkRequests += networkInWindow.length;
    _networkHistory.addAll(networkInWindow);
    _trim(_networkHistory, maxNetworkEvents);

    // Coleta eventos customizados
    final events = eventSource.drainEvents();
    final eventRecords = eventSource.drainRecords();
    _customEventLatest.addAll(events);
    _customEventLog.addAll(eventRecords);
    _trim(_customEventLog, maxCustomEvents);

    return TelemetryModel(
      frameTimings: frames,
      recentFrameTimings: List<FrameTiming>.unmodifiable(_recentFrames),
      memoryInfo: currentMemory ?? _lastMemorySnapshot,
      memoryHistory: List<MemoryInfo>.unmodifiable(_memoryHistory),
      networkEvents: List<NetworkEvent>.unmodifiable(_networkHistory),
      networkEventsInWindow: List<NetworkEvent>.unmodifiable(networkInWindow),
      customEvents: Map<String, dynamic>.unmodifiable(_customEventLatest),
      customEventLog: List<CustomEventRecord>.unmodifiable(_customEventLog),
      sessionStart: _sessionStart,
      capturedAt: capturedAt,
      sampleStart: sampleStart,
      sampleDuration: sampleDuration,
      totalFrameCount: _totalFrameCount,
      totalNetworkRequests: _totalNetworkRequests,
      rebuildCount: _rebuildCount,
    );
  }

  void _trim<T>(List<T> values, int maxLength) {
    if (values.length > maxLength) {
      values.removeRange(0, values.length - maxLength);
    }
  }
}
