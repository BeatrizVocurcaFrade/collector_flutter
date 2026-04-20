package br.ufmg.collector_flutter

import android.content.Context
import android.os.BatteryManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

class CollectorFlutterPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "collector_flutter/system")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getCpuUsage" -> Thread {
                try {
                    result.success(getCpuUsage())
                } catch (e: Exception) {
                    result.success(-1.0)
                }
            }.start()
            "getBatteryLevel" -> {
                try {
                    result.success(getBatteryLevel())
                } catch (e: Exception) {
                    result.success(-1)
                }
            }
            "isCharging" -> {
                try {
                    result.success(getIsCharging())
                } catch (e: Exception) {
                    result.success(false)
                }
            }
            else -> result.notImplemented()
        }
    }

    private data class CpuStat(val total: Long, val idle: Long)

    private fun parseProcStat(): CpuStat {
        val line = File("/proc/stat").useLines { lines ->
            lines.first { it.startsWith("cpu ") }
        }
        val parts = line.trim().split("\\s+".toRegex()).drop(1).map { it.toLong() }
        // Fields: user, nice, system, idle, iowait, irq, softirq, steal
        val idle = parts[3] + if (parts.size > 4) parts[4] else 0L
        val total = parts.sum()
        return CpuStat(total, idle)
    }

    private fun getCpuUsage(): Double {
        val stat1 = parseProcStat()
        Thread.sleep(200)
        val stat2 = parseProcStat()
        val deltaTotal = stat2.total - stat1.total
        val deltaIdle = stat2.idle - stat1.idle
        if (deltaTotal <= 0) return 0.0
        return (1.0 - deltaIdle.toDouble() / deltaTotal.toDouble()) * 100.0
    }

    private fun getBatteryLevel(): Int {
        val bm = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    private fun getIsCharging(): Boolean {
        val bm = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val status = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_STATUS)
        return status == BatteryManager.BATTERY_STATUS_CHARGING ||
               status == BatteryManager.BATTERY_STATUS_FULL
    }
}
