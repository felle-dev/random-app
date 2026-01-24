package com.example.random

import android.app.admin.DevicePolicyManager
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
    private val DEVICE_ADMIN_REQUEST = 1001
    
    private lateinit var devicePolicyManager: DevicePolicyManager
    private lateinit var adminComponent: ComponentName

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize device admin components
        devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        adminComponent = ComponentName(this, DeviceAdminReceiver::class.java)
        
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
                "checkDeviceAdmin" -> {
                    val isActive = devicePolicyManager.isAdminActive(adminComponent)
                    result.success(isActive)
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
                "openDeviceAdminSettings" -> {
                    requestDeviceAdmin()
                    result.success(null)
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
            "lock_screen" to ".tiles.LockTileService",
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
            "lock_screen" to ".tiles.LockTileService",
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

    private fun requestDeviceAdmin() {
        val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
        intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, adminComponent)
        intent.putExtra(
            DevicePolicyManager.EXTRA_ADD_EXPLANATION,
            "This permission is required to lock your screen from the quick settings tile"
        )
        startActivityForResult(intent, DEVICE_ADMIN_REQUEST)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        when (requestCode) {
            DEVICE_ADMIN_REQUEST -> {
                // Device admin request completed
                // You can show a message or update UI if needed
            }
        }
    }
}