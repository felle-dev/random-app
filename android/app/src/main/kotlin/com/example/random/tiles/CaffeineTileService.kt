package com.example.random.tiles

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import android.os.PowerManager
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import com.example.random.R

class CaffeineTileService : TileService() {
    
    companion object {
        private const val PREF_NAME = "caffeine_prefs"
        private const val KEY_CAFFEINE_ENABLED = "caffeine_enabled"
        const val ACTION_START_CAFFEINE = "com.example.random.START_CAFFEINE"
        const val ACTION_STOP_CAFFEINE = "com.example.random.STOP_CAFFEINE"
    }
    
    override fun onStartListening() {
        super.onStartListening()
        updateTileState()
    }
    
    private fun updateTileState() {
        val isEnabled = getCaffeineState()
        qsTile?.apply {
            state = if (isEnabled) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
            label = if (isEnabled) "Caffeine On" else "Caffeine Off"
            icon = Icon.createWithResource(
                applicationContext, 
                if (isEnabled) android.R.drawable.ic_lock_idle_alarm else android.R.drawable.ic_lock_idle_lock
            )
            updateTile()
        }
    }
    
    override fun onClick() {
        super.onClick()
        
        val currentState = getCaffeineState()
        val newState = !currentState
        
        setCaffeineState(newState)
        
        if (newState) {
            startCaffeineService()
        } else {
            stopCaffeineService()
        }
        
        updateTileState()
    }
    
    private fun startCaffeineService() {
        val intent = Intent(this, CaffeineService::class.java)
        intent.action = ACTION_START_CAFFEINE
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }
    
    private fun stopCaffeineService() {
        val intent = Intent(this, CaffeineService::class.java)
        intent.action = ACTION_STOP_CAFFEINE
        startService(intent)
    }
    
    private fun getCaffeineState(): Boolean {
        val prefs = getSharedPreferences(PREF_NAME, MODE_PRIVATE)
        return prefs.getBoolean(KEY_CAFFEINE_ENABLED, false)
    }
    
    private fun setCaffeineState(enabled: Boolean) {
        val prefs = getSharedPreferences(PREF_NAME, MODE_PRIVATE)
        prefs.edit().putBoolean(KEY_CAFFEINE_ENABLED, enabled).apply()
    }
}

class CaffeineService : Service() {
    
    companion object {
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "caffeine_channel"
        private const val WAKE_LOCK_TAG = "Random:CaffeineWakeLock"
    }
    
    private var wakeLock: PowerManager.WakeLock? = null
    
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            CaffeineTileService.ACTION_START_CAFFEINE -> {
                acquireWakeLock()
                startForeground(NOTIFICATION_ID, createNotification())
            }
            CaffeineTileService.ACTION_STOP_CAFFEINE -> {
                releaseWakeLock()
                stopForeground(true)
                stopSelf()
            }
        }
        
        return START_STICKY
    }
    
    private fun acquireWakeLock() {
        try {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            
            // Use PARTIAL_WAKE_LOCK to keep CPU running
            // Combined with ACQUIRE_CAUSES_WAKEUP and ON_AFTER_RELEASE for screen
            wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK or 
                PowerManager.ACQUIRE_CAUSES_WAKEUP or
                PowerManager.ON_AFTER_RELEASE,
                WAKE_LOCK_TAG
            )
            
            // Acquire indefinitely (will be released when service stops)
            wakeLock?.acquire()
            
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    private fun releaseWakeLock() {
        try {
            wakeLock?.let {
                if (it.isHeld) {
                    it.release()
                }
            }
            wakeLock = null
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Caffeine",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps screen awake"
                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun createNotification(): Notification {
        // Intent to turn off caffeine when notification is tapped
        val stopIntent = Intent(this, CaffeineService::class.java).apply {
            action = CaffeineTileService.ACTION_STOP_CAFFEINE
        }
        val stopPendingIntent = PendingIntent.getService(
            this,
            0,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        
        return builder
            .setContentTitle("Caffeine Active")
            .setContentText("Screen will stay awake")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentIntent(stopPendingIntent)
            .setOngoing(true)
            .build()
    }
    
    override fun onBind(intent: Intent?) = null
    
    override fun onDestroy() {
        super.onDestroy()
        releaseWakeLock()
    }
}