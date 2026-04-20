import Flutter
import UIKit

public class CollectorFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "collector_flutter/system",
            binaryMessenger: registrar.messenger()
        )
        let instance = CollectorFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getCpuUsage":
            // iOS: CPU per-process via Mach task_info is restricted in sandboxed apps.
            // Returning -1.0 signals "not available" to the Dart layer.
            result(-1.0)
        case "getBatteryLevel":
            UIDevice.current.isBatteryMonitoringEnabled = true
            let level = UIDevice.current.batteryLevel
            if level < 0 {
                result(-1)
            } else {
                result(Int(level * 100))
            }
        case "isCharging":
            UIDevice.current.isBatteryMonitoringEnabled = true
            let state = UIDevice.current.batteryState
            result(state == .charging || state == .full)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
