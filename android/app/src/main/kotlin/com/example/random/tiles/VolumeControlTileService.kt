package com.example.random.tiles

import android.graphics.drawable.Icon
import android.media.AudioManager
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

class VolumeControlTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        qsTile?.apply {
            state = Tile.STATE_ACTIVE
            label = "Volume"
            icon = Icon.createWithResource(applicationContext, android.R.drawable.ic_lock_silent_mode_off)
            updateTile()
        }
    }

    override fun onClick() {
        super.onClick()
        val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
        audioManager.adjustStreamVolume(
            AudioManager.STREAM_MUSIC,
            AudioManager.ADJUST_SAME,
            AudioManager.FLAG_SHOW_UI
        )
    }
}
