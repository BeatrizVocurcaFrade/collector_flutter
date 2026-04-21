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
            "getCpuUsage" -> {
                try {
                    result.success(getCpuUsage())
                } catch (e: Exception) {
                    result.success(-1.0)
                }
            }
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

    // Cached values for delta-based CPU measurement (no sleep needed).
    private var prevCpuTicks: Long = -1L
    private var prevWallMs: Long = -1L

    private fun readProcessCpuTicks(): Long {
        // /proc/self/stat is always readable by the own process on all Android versions.
        // Format: pid (name) state ... utime stime ...
        // Skip the name field (may contain spaces) by finding the closing ')'.
        val text = File("/proc/self/stat").readText()
        val afterParen = text.indexOf(')') + 2
        val fields = text.substring(afterParen).trim().split("\\s+".toRegex())
        // After ')': state ppid pgrp session tty tpgid flags minflt cminflt majflt cmajflt utime stime
        // utime = index 11, stime = index 12
        return fields[11].toLong() + fields[12].toLong()
    }

    private fun getCpuUsage(): Double {
        val nowTicks = readProcessCpuTicks()
        val nowMs = System.currentTimeMillis()
        val result = if (prevCpuTicks >= 0L && prevWallMs >= 0L) {
            val ticksDelta = nowTicks - prevCpuTicks
            val wallDelta = nowMs - prevWallMs
            if (wallDelta <= 0L || ticksDelta < 0L) 0.0
            else (ticksDelta * 1000.0 / 100.0 / wallDelta * 100.0).coerceAtMost(100.0)
        } else 0.0
        prevCpuTicks = nowTicks
        prevWallMs = nowMs
        return result
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
