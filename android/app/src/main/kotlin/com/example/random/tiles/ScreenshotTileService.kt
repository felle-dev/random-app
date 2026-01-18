package com.example.random.tiles

import android.app.PendingIntent
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import com.example.random.R

class ScreenshotTileService : TileService() {

    override fun onStartListening() {  // Fixed: capital L in Listening
        super.onStartListening()
        qsTile?.apply {
            state = Tile.STATE_ACTIVE
            label = "Screenshot"
            icon = Icon.createWithResource(applicationContext, R.drawable.ic_screenshot)
            updateTile()
            
        }
    }

    override fun onClick() {
        super.onClick()
        
        // IMPORTANT: We need to unlock and run the activity first
        // This ensures the panel is collapsed before we do anything
        unlockAndRun {
            // Create intent for the helper activity
            val intent = Intent(this, ScreenshotHelperActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            
            // Use PendingIntent for Android 14+ (API 34+)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                val pendingIntent = PendingIntent.getActivity(
                    this,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                startActivityAndCollapse(pendingIntent)
            } else {
                startActivity(intent)
            }
        }
    }
}