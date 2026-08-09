package com.aladin.iptv.player.pro

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

class ProgramReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "epg_reminders"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(NotificationChannel(
                channelId, "Program hatırlatıcıları", NotificationManager.IMPORTANCE_HIGH))
        }
        val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val pending = PendingIntent.getActivity(context, 0, launch,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        manager.notify(intent.getIntExtra("id", 1), NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.drawable.tv_launcher_icon)
            .setContentTitle(intent.getStringExtra("channel") ?: "aladin IPTV")
            .setContentText(intent.getStringExtra("title") ?: "Program başlıyor")
            .setContentIntent(pending).setAutoCancel(true).build())
    }
}
