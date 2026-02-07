package com.felle.flipz

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.Uri
import android.os.BatteryManager
import android.os.Build
import android.provider.Settings
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL_TILES = "com.random.app/quick_tiles"
    private val CHANNEL_BATTERY = "com.random.app/battery_info"
    private val CHANNEL_MONET = "telegram_monet/colors"  // NEW CHANNEL

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
                "checkWriteSettings" -> {
                    val canWrite = Settings.System.canWrite(this)
                    result.success(canWrite)
                }
                "openWriteSettingsPermission" -> {
                    try {
                        val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
                        intent.data = Uri.parse("package:$packageName")
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Could not open settings", null)
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

        // Material You Colors Channel (NEW)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_MONET).setMethodCallHandler { call, result ->
            when (call.method) {
                "getMonetColors" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        try {
                            val colors = getSystemMonetColors()
                            result.success(colors)
                        } catch (e: Exception) {
                            result.error("ERROR", "Failed to get colors: ${e.message}", null)
                        }
                    } else {
                        result.error("UNSUPPORTED", "Material You requires Android 12+", null)
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
            "screen_timeout" to ".tiles.ScreenTimeoutTileService",
        )

        val packageManager = packageManager
        tileMap.forEach { (tileId, serviceName) ->
            val componentName = ComponentName(this, "${packageName}${serviceName}")
            val state = packageManager.getComponentEnabledSetting(componentName)
            // Only add if EXPLICITLY enabled (remove the DEFAULT check)
            if (state == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) {
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
            "screen_timeout" to ".tiles.ScreenTimeoutTileService",
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

    // Material You Colors Methods (NEW)
    @RequiresApi(Build.VERSION_CODES.S)
    private fun getSystemMonetColors(): Map<String, Int> {
        return mapOf(
            // Primary (a1)
            "a1_0" to getSystemColor(android.R.color.system_accent1_0),
            "a1_10" to getSystemColor(android.R.color.system_accent1_10),
            "a1_50" to getSystemColor(android.R.color.system_accent1_50),
            "a1_100" to getSystemColor(android.R.color.system_accent1_100),
            "a1_200" to getSystemColor(android.R.color.system_accent1_200),
            "a1_300" to getSystemColor(android.R.color.system_accent1_300),
            "a1_400" to getSystemColor(android.R.color.system_accent1_400),
            "a1_500" to getSystemColor(android.R.color.system_accent1_500),
            "a1_600" to getSystemColor(android.R.color.system_accent1_600),
            "a1_700" to getSystemColor(android.R.color.system_accent1_700),
            "a1_800" to getSystemColor(android.R.color.system_accent1_800),
            "a1_900" to getSystemColor(android.R.color.system_accent1_900),
            "a1_1000" to getSystemColor(android.R.color.system_accent1_1000),
            
            // Secondary (a2)
            "a2_0" to getSystemColor(android.R.color.system_accent2_0),
            "a2_10" to getSystemColor(android.R.color.system_accent2_10),
            "a2_50" to getSystemColor(android.R.color.system_accent2_50),
            "a2_100" to getSystemColor(android.R.color.system_accent2_100),
            "a2_200" to getSystemColor(android.R.color.system_accent2_200),
            "a2_300" to getSystemColor(android.R.color.system_accent2_300),
            "a2_400" to getSystemColor(android.R.color.system_accent2_400),
            "a2_500" to getSystemColor(android.R.color.system_accent2_500),
            "a2_600" to getSystemColor(android.R.color.system_accent2_600),
            "a2_700" to getSystemColor(android.R.color.system_accent2_700),
            "a2_800" to getSystemColor(android.R.color.system_accent2_800),
            "a2_900" to getSystemColor(android.R.color.system_accent2_900),
            "a2_1000" to getSystemColor(android.R.color.system_accent2_1000),
            
            // Tertiary (a3)
            "a3_0" to getSystemColor(android.R.color.system_accent3_0),
            "a3_10" to getSystemColor(android.R.color.system_accent3_10),
            "a3_50" to getSystemColor(android.R.color.system_accent3_50),
            "a3_100" to getSystemColor(android.R.color.system_accent3_100),
            "a3_200" to getSystemColor(android.R.color.system_accent3_200),
            "a3_300" to getSystemColor(android.R.color.system_accent3_300),
            "a3_400" to getSystemColor(android.R.color.system_accent3_400),
            "a3_500" to getSystemColor(android.R.color.system_accent3_500),
            "a3_600" to getSystemColor(android.R.color.system_accent3_600),
            "a3_700" to getSystemColor(android.R.color.system_accent3_700),
            "a3_800" to getSystemColor(android.R.color.system_accent3_800),
            "a3_900" to getSystemColor(android.R.color.system_accent3_900),
            "a3_1000" to getSystemColor(android.R.color.system_accent3_1000),
            
            // Neutral 1 (n1)
            "n1_0" to getSystemColor(android.R.color.system_neutral1_0),
            "n1_10" to getSystemColor(android.R.color.system_neutral1_10),
            "n1_50" to getSystemColor(android.R.color.system_neutral1_50),
            "n1_100" to getSystemColor(android.R.color.system_neutral1_100),
            "n1_200" to getSystemColor(android.R.color.system_neutral1_200),
            "n1_300" to getSystemColor(android.R.color.system_neutral1_300),
            "n1_400" to getSystemColor(android.R.color.system_neutral1_400),
            "n1_500" to getSystemColor(android.R.color.system_neutral1_500),
            "n1_600" to getSystemColor(android.R.color.system_neutral1_600),
            "n1_700" to getSystemColor(android.R.color.system_neutral1_700),
            "n1_800" to getSystemColor(android.R.color.system_neutral1_800),
            "n1_900" to getSystemColor(android.R.color.system_neutral1_900),
            "n1_1000" to getSystemColor(android.R.color.system_neutral1_1000),
            
            // Neutral 2 (n2)
            "n2_0" to getSystemColor(android.R.color.system_neutral2_0),
            "n2_10" to getSystemColor(android.R.color.system_neutral2_10),
            "n2_50" to getSystemColor(android.R.color.system_neutral2_50),
            "n2_100" to getSystemColor(android.R.color.system_neutral2_100),
            "n2_200" to getSystemColor(android.R.color.system_neutral2_200),
            "n2_300" to getSystemColor(android.R.color.system_neutral2_300),
            "n2_400" to getSystemColor(android.R.color.system_neutral2_400),
            "n2_500" to getSystemColor(android.R.color.system_neutral2_500),
            "n2_600" to getSystemColor(android.R.color.system_neutral2_600),
            "n2_700" to getSystemColor(android.R.color.system_neutral2_700),
            "n2_800" to getSystemColor(android.R.color.system_neutral2_800),
            "n2_900" to getSystemColor(android.R.color.system_neutral2_900),
            "n2_1000" to getSystemColor(android.R.color.system_neutral2_1000),
        )
    }

    private fun getSystemColor(resId: Int): Int {
        return ContextCompat.getColor(this, resId)
    }
}