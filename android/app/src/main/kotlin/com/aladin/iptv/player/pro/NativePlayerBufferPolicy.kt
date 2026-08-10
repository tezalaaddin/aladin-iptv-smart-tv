package com.aladin.iptv.player.pro

import androidx.media3.exoplayer.DefaultLoadControl

internal object NativePlayerBufferPolicy {
    fun create(isLive: Boolean, isLowMemory: Boolean, isHighMemory: Boolean, profile: String): DefaultLoadControl {
        val lowBytes = 24 * 1024 * 1024
        val highBytes = 64 * 1024 * 1024
        val normalBytes = DefaultLoadControl.DEFAULT_TARGET_BUFFER_BYTES
        val values = when {
            profile == "low_latency" -> Triple(if (isLive) 2_000 else 8_000, if (isLive) 6_000 else 20_000, if (isLowMemory) lowBytes else normalBytes)
            profile == "balanced" -> Triple(if (isLive) 5_000 else 15_000, if (isLive) 15_000 else 45_000, if (isLowMemory) lowBytes else normalBytes)
            profile == "stable" -> Triple(if (isLive) 10_000 else 30_000, if (isLive) 30_000 else 90_000, if (isLowMemory) lowBytes else highBytes)
            isLive && isLowMemory -> Triple(5_000, 8_000, lowBytes)
            isLive && isHighMemory -> Triple(8_000, 25_000, highBytes)
            isLive -> Triple(5_000, 15_000, normalBytes)
            isLowMemory -> Triple(15_000, 40_000, lowBytes)
            isHighMemory -> Triple(25_000, 75_000, highBytes)
            else -> Triple(15_000, 50_000, normalBytes)
        }
        return DefaultLoadControl.Builder()
            .setBufferDurationsMs(values.first, values.second, 2_500, 5_000)
            .setTargetBufferBytes(values.third)
            .setPrioritizeTimeOverSizeThresholds(true)
            .build()
    }
}
