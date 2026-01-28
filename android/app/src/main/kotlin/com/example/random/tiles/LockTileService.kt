    package com.example.random.tiles

    import android.graphics.drawable.Icon
    import android.service.quicksettings.Tile
    import android.service.quicksettings.TileService
    import com.example.random.CustomAccessibilityService

    class LockTileService : TileService() {

        override fun onStartListening() {
            super.onStartListening()
            updateTileState()
        }

        private fun updateTileState() {
            qsTile?.apply {
                state = Tile.STATE_ACTIVE
                label = "Lock Screen"
                icon = Icon.createWithResource(applicationContext, android.R.drawable.ic_lock_lock)
                updateTile()
            }
        }

        override fun onClick() {
            super.onClick()
            
            // Directly lock the screen using accessibility service
            if (CustomAccessibilityService.getInstance() != null) {
                CustomAccessibilityService.lockScreen()
            }
        }
    }