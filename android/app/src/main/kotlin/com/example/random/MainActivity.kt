package com.example.random

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.random.app/quick_tiles"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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
    }

    private fun getActiveTiles(): List<String> {
        val activeTiles = mutableListOf<String>()
        val tileMap = mapOf(
            "volume_control" to ".tiles.VolumeControlTileService",
            "screenshot" to ".tiles.ScreenshotTileService",
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
            "volume_control" to ".tiles.VolumeControlTileService",
            "screenshot" to ".tiles.ScreenshotTileService",
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
}