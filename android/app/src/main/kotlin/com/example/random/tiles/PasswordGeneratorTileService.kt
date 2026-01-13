package com.example.random.tiles

import android.content.Intent
import android.service.quicksettings.TileService
import com.example.random.MainActivity

class PasswordGeneratorTileService : TileService() {
    override fun onClick() {
        super.onClick()
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("route", "/password_generator")
        }
        startActivityAndCollapse(intent)
    }
}
