package com.example.random

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.BatteryManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL_TILES = "com.random.app/quick_tiles"
    private val CHANNEL_BATTERY = "com.random.app/battery_info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Quick Tiles Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_TILES).setMethodCallHandler { call, result ->
            when (call.method) {
                "getActiveTiles" -> {
                    val activeTiles = getActiveTiles()
                    result.success(activeTiles)
                }
                "addTile" -> {
                    val tileId = call.argument<String>("tileId")
                    if (tileId != null) {
                        enableTile(tileId, true)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "tileId is required", null)
                    }
                }
                "removeTile" -> {
                    val tileId = call.argument<String>("tileId")
                    if (tileId != null) {
                        enableTile(tileId, false)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "tileId is required", null)
                    }
                }
                "checkAccessibility" -> {
                    val isEnabled = isAccessibilityServiceEnabled(this)
                    result.success(isEnabled)
                }
                "openAccessibilitySettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Battery Info Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_BATTERY).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryCycles" -> {
                    val cycles = getBatteryCycleCount()
                    if (cycles != -1) {
                        result.success(cycles)
                    } else {
                        result.error("UNAVAILABLE", "Battery cycle count not available", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // Quick Tiles Methods
    private fun getActiveTiles(): List<String> {
        val activeTiles = mutableListOf<String>()
        val tileMap = mapOf(
            "lock_screen" to ".tiles.LockTileService",
            "volume_control" to ".tiles.VolumeControlTileService",
            "screenshot" to ".tiles.ScreenshotTileService",
            "caffeine" to ".tiles.CaffeineTileService",
        )

        val packageManager = packageManager
        tileMap.forEach { (tileId, serviceName) ->
            val componentName = ComponentName(this, "${packageName}${serviceName}")
            val state = packageManager.getComponentEnabledSetting(componentName)
            if (state == PackageManager.COMPONENT_ENABLED_STATE_ENABLED ||
                state == PackageManager.COMPONENT_ENABLED_STATE_DEFAULT) {
                activeTiles.add(tileId)
            }
        }
        return activeTiles
    }

    private fun enableTile(tileId: String, enable: Boolean) {
        val serviceNameMap = mapOf(
            "lock_screen" to ".tiles.LockTileService",
            "volume_control" to ".tiles.VolumeControlTileService",
            "screenshot" to ".tiles.ScreenshotTileService",
            "caffeine" to ".tiles.CaffeineTileService",
        )

        val serviceName = serviceNameMap[tileId] ?: return
        val componentName = ComponentName(this, "${packageName}${serviceName}")
        val newState = if (enable) {
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED
        } else {
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED
        }

        packageManager.setComponentEnabledSetting(
            componentName,
            newState,
            PackageManager.DONT_KILL_APP
        )
    }

    private fun isAccessibilityServiceEnabled(context: Context): Boolean {
        val service = "${context.packageName}/${CustomAccessibilityService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        )
        return enabledServices?.contains(service) == true
    }

    // Battery Cycle Methods
    private fun getBatteryCycleCount(): Int {
        return try {
            // Method 1: Try to get it from broadcast intent
            val batteryStatus: Intent? = IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { filter ->
                applicationContext.registerReceiver(null, filter)
            }
            
            batteryStatus?.let {
                val cycles = it.getIntExtra(BatteryManager.EXTRA_CYCLE_COUNT, -1)
                if (cycles > 0) {
                    return cycles
                }
            }

            // Method 2: Try to read from system file (may require permissions on some devices)
            // This is the most reliable method but may not work on all devices
            val cycleCountFile = java.io.File("/sys/class/power_supply/battery/cycle_count")
            if (cycleCountFile.exists() && cycleCountFile.canRead()) {
                val content = cycleCountFile.readText().trim()
                return content.toIntOrNull() ?: -1
            }

            // Alternative paths that some manufacturers use
            val alternatePaths = listOf(
                "/sys/class/power_supply/battery/battery_cycle",
                "/sys/class/power_supply/bms/cycle_count",
                "/sys/class/power_supply/Battery/cycle_count",
                "/sys/devices/platform/battery/power_supply/battery/cycle_count"
            )

            for (path in alternatePaths) {
                val file = java.io.File(path)
                if (file.exists() && file.canRead()) {
                    val content = file.readText().trim()
                    val cycleCount = content.toIntOrNull()
                    if (cycleCount != null && cycleCount > 0) {
                        return cycleCount
                    }
                }
            }

            -1
        } catch (e: Exception) {
            e.printStackTrace()
            -1
        }
    }
}