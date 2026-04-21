import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:collector_flutter/src/data/datasources/cpu_data_source.dart';
import 'package:collector_flutter/src/data/datasources/battery_data_source.dart';
import 'package:collector_flutter/src/core/analyzer.dart';
import 'package:collector_flutter/src/data/models/telemetry_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CpuDataSource', () {
    late CpuDataSource cpuSource;

    setUp(() {
      cpuSource = CpuDataSource();
    });

    test('retorna -1.0 quando MissingPluginException é lançada', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('collector_flutter/system'),
        (call) async {
          if (call.method == 'getCpuUsage') {
            throw MissingPluginException();
          }
          return null;
        },
      );

      final result = await cpuSource.getCpuUsage();
      expect(result, equals(-1.0));
    });

    test('retorna valor do platform channel quando disponível', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('collector_flutter/system'),
        (call) async {
          if (call.method == 'getCpuUsage') return 45.5;
          return null;
        },
      );

      final result = await cpuSource.getCpuUsage();
      expect(result, equals(45.5));
    });

    test('retorna -1.0 quando PlatformException é lançada', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('collector_flutter/system'),
        (call) async {
          if (call.method == 'getCpuUsage') {
            throw PlatformException(code: 'ERROR');
          }
          return null;
        },
      );

      final result = await cpuSource.getCpuUsage();
      expect(result, equals(-1.0));
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('collector_flutter/system'), null);
    });
  });

  group('BatteryDataSource', () {
    late BatteryDataSource batterySource;

    setUp(() {
      batterySource = BatteryDataSource();
    });

    test('getBatteryLevel retorna -1 quando plugin indisponível', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('collector_flutter/system'),
        (call) async {
          if (call.method == 'getBatteryLevel') {
            throw MissingPluginException();
          }
          return null;
        },
      );

      final result = await batterySource.getBatteryLevel();
      expect(result, equals(-1));
    });

    test('getBatteryLevel retorna nível correto do platform channel', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('collector_flutter/system'),
        (call) async {
          if (call.method == 'getBatteryLevel') return 78;
          return null;
        },
      );

      final result = await batterySource.getBatteryLevel();
      expect(result, equals(78));
    });

    test('isCharging retorna false quando plugin indisponível', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('collector_flutter/system'),
        (call) async {
          if (call.method == 'isCharging') throw MissingPluginException();
          return null;
        },
      );

      final result = await batterySource.isCharging();
      expect(result, isFalse);
    });

    test('isCharging retorna true quando carregando', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('collector_flutter/system'),
        (call) async {
          if (call.method == 'isCharging') return true;
          return null;
        },
      );

      final result = await batterySource.isCharging();
      expect(result, isTrue);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('collector_flutter/system'), null);
    });
  });

  group('Analyzer — CPU e bateria', () {
    late Analyzer analyzer;

    setUp(() => analyzer = Analyzer());

    TelemetryModel makeModel({
      double cpu = -1.0,
      int battery = -1,
      bool charging = false,
      bool warmup = false,
    }) {
      final start = DateTime(2024, 1, 1, 12);
      return TelemetryModel(
        cpuUsagePercent: cpu,
        batteryLevel: battery,
        isCharging: charging,
        sessionStart: start,
        capturedAt: warmup
            ? start.add(const Duration(seconds: 2))
            : start.add(const Duration(seconds: 12)),
      );
    }

    test('CPU elevada (>80%) gera issue', () {
      final result = analyzer.analyzeTelemetry(makeModel(cpu: 85.0));
      expect(result.issues.any((i) => i.contains('CPU elevada')), isTrue);
    });

    test('CPU elevada no início da sessão não gera issue', () {
      final result =
          analyzer.analyzeTelemetry(makeModel(cpu: 100.0, warmup: true));
      expect(result.issues.any((i) => i.contains('CPU')), isFalse);
    });

    test('CPU moderada (60–80%) gera issue', () {
      final result = analyzer.analyzeTelemetry(makeModel(cpu: 65.0));
      expect(result.issues.any((i) => i.contains('CPU moderada')), isTrue);
    });

    test('CPU abaixo de 60% não gera issue', () {
      final result = analyzer.analyzeTelemetry(makeModel(cpu: 40.0));
      expect(result.issues.any((i) => i.contains('CPU')), isFalse);
    });

    test('CPU indisponível (-1) não gera issue', () {
      final result = analyzer.analyzeTelemetry(makeModel(cpu: -1.0));
      expect(result.issues.any((i) => i.contains('CPU')), isFalse);
    });

    test('bateria baixa sem carregamento gera issue', () {
      final result = analyzer.analyzeTelemetry(makeModel(battery: 15));
      expect(result.issues.any((i) => i.contains('Bateria baixa')), isTrue);
    });

    test('bateria baixa com carregamento não gera issue', () {
      final result =
          analyzer.analyzeTelemetry(makeModel(battery: 15, charging: true));
      expect(result.issues.any((i) => i.contains('Bateria')), isFalse);
    });

    test('bateria acima de 20% não gera issue', () {
      final result = analyzer.analyzeTelemetry(makeModel(battery: 50));
      expect(result.issues.any((i) => i.contains('Bateria')), isFalse);
    });

    test('hasCpuData é true quando cpuUsagePercent >= 0', () {
      final result = analyzer.analyzeTelemetry(makeModel(cpu: 30.0));
      expect(result.hasCpuData, isTrue);
    });

    test('hasBatteryData é true quando batteryLevel >= 0', () {
      final result = analyzer.analyzeTelemetry(makeModel(battery: 80));
      expect(result.hasBatteryData, isTrue);
    });
  });
}
