package com.aladin.iptv.player.pro

import android.app.Activity
import android.content.Context
import android.content.pm.ActivityInfo
import android.content.pm.PackageManager
import android.os.Build
import java.util.Locale

/** Device-specific behavior for fixed landscape automotive head units. */
object CarHeadUnitPolicy {
    fun isCarHeadUnit(context: Context): Boolean {
        val model = Build.MODEL.orEmpty().lowercase(Locale.ROOT)
        val manufacturer = Build.MANUFACTURER.orEmpty().lowercase(Locale.ROOT)
        val isTv = context.packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK) ||
            context.packageManager.hasSystemFeature(PackageManager.FEATURE_TELEVISION)

        return context.packageManager.hasSystemFeature(PackageManager.FEATURE_AUTOMOTIVE) ||
            model.contains("k2401") ||
            (manufacturer.contains("allwinner") && !isTv)
    }

    fun enforceLandscape(activity: Activity) {
        if (isCarHeadUnit(activity)) {
            activity.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
        }
    }
}
