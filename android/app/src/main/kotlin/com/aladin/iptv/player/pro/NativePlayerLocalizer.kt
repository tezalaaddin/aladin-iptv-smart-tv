package com.aladin.iptv.player.pro

import android.content.Intent

internal class NativePlayerLocalizer(private val intent: Intent) {
    fun text(key: String, fallback: String): String =
        intent.getStringExtra("i18n_$key")?.takeIf { it.isNotBlank() } ?: fallback
}
