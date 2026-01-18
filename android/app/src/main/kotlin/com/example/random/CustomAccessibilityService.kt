package com.example.random

import android.accessibilityservice.AccessibilityService
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.widget.Toast

class CustomAccessibilityService : AccessibilityService() {
    
    companion object {
        private const val TAG = "CustomAccessibility"
        const val ACTION_TAKE_SCREENSHOT = "com.example.random.TAKE_SCREENSHOT"
        
        @Volatile
        private var instance: CustomAccessibilityService? = null
        
        fun isRunning(): Boolean = instance != null
    }
    
    private val screenshotReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            Log.d(TAG, "Broadcast received: ${intent?.action}")
            if (intent?.action == ACTION_TAKE_SCREENSHOT) {
                takeScreenshot()
            }
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        Log.d(TAG, "Accessibility service connected")
        
        try {
            val filter = IntentFilter(ACTION_TAKE_SCREENSHOT)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(screenshotReceiver, filter, RECEIVER_NOT_EXPORTED)
            } else {
                registerReceiver(screenshotReceiver, filter)
            }
            Log.d(TAG, "Broadcast receiver registered")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to register receiver", e)
        }
    }
    
    private fun takeScreenshot() {
        try {
            Log.d(TAG, "Attempting to take screenshot...")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val result = performGlobalAction(GLOBAL_ACTION_TAKE_SCREENSHOT)
                Log.d(TAG, "Screenshot action result: $result")
                if (!result) {
                    Toast.makeText(this, "Failed to take screenshot", Toast.LENGTH_SHORT).show()
                }
            } else {
                Toast.makeText(this, "Screenshot not supported on Android 8 and below", Toast.LENGTH_SHORT).show()
                Log.e(TAG, "Screenshot not supported on this Android version")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error taking screenshot", e)
            Toast.makeText(this, "Error: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Not needed for screenshot functionality
    }

    override fun onInterrupt() {
        Log.d(TAG, "Accessibility service interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        try {
            unregisterReceiver(screenshotReceiver)
            Log.d(TAG, "Broadcast receiver unregistered")
        } catch (e: Exception) {
            Log.e(TAG, "Error unregistering receiver", e)
        }
    }
}