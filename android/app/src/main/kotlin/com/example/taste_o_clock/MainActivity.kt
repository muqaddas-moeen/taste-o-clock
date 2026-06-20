package com.example.taste_o_clock

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "taste_o_clock_updates",
                "Order Updates",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Order status and delivery alerts"
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }

        super.onCreate(savedInstanceState)
    }
}
