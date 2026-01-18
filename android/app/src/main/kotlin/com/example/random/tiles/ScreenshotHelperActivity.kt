package com.example.random.tiles

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import android.view.WindowManager
import android.widget.Toast
import com.example.random.CustomAccessibilityService

class ScreenshotHelperActivity : Activity() {

    companion object {
        private const val TAG = "ScreenshotHelper"
        private const val SCREENSHOT_DELAY = 1000L
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        Log.d(TAG, "ScreenshotHelperActivity created at ${System.currentTimeMillis()}")
        
        // Make activity completely invisible - don't show any window at all
        window.addFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE)
        window.addFlags(WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE)
        
        // Move activity off-screen so it doesn't render anything
        val params = window.attributes
        params.x = -10000
        params.y = -10000
        params.height = 1
        params.width = 1
        window.attributes = params
        
        // Check if accessibility service is enabled
        if (isAccessibilityServiceEnabled()) {
            Log.d(TAG, "Accessibility service is enabled, will take screenshot in ${SCREENSHOT_DELAY}ms")
            
            // Wait for panel to fully collapse
            Handler(Looper.getMainLooper()).postDelayed({
                Log.d(TAG, "Now taking screenshot at ${System.currentTimeMillis()}")
                takeScreenshot()
                
                // Finish activity immediately after screenshot
                finish()
            }, SCREENSHOT_DELAY)
        } else {
            Log.d(TAG, "Accessibility service is NOT enabled")
            showAccessibilityPrompt()
        }
    }
    
    private fun isAccessibilityServiceEnabled(): Boolean {
        return try {
            val service = "${packageName}/${CustomAccessibilityService::class.java.canonicalName}"
            val enabledServices = Settings.Secure.getString(
                contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            )
            val isEnabled = enabledServices?.contains(service) == true
            Log.d(TAG, "Is service enabled: $isEnabled")
            isEnabled
        } catch (e: Exception) {
            Log.e(TAG, "Error checking accessibility service", e)
            false
        }
    }
    
    private fun showAccessibilityPrompt() {
        // Reset window params for this case so user can see the settings
        val params = window.attributes
        params.x = 0
        params.y = 0
        params.height = WindowManager.LayoutParams.MATCH_PARENT
        params.width = WindowManager.LayoutParams.MATCH_PARENT
        window.attributes = params
        
        Toast.makeText(
            this,
            "Please enable accessibility service for screenshots",
            Toast.LENGTH_LONG
        ).show()
        
        try {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open accessibility settings", e)
        }
        
        finish()
    }
    
    private fun takeScreenshot() {
        try {
            Log.d(TAG, "Sending screenshot broadcast")
            val intent = Intent(CustomAccessibilityService.ACTION_TAKE_SCREENSHOT)
            intent.setPackage(packageName)
            sendBroadcast(intent)
            Log.d(TAG, "Screenshot broadcast sent")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to send screenshot broadcast", e)
        }
    }
}