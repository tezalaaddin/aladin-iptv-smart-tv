package com.aladin.iptv.player.pro

import androidx.media3.common.C
import androidx.media3.common.Tracks
import java.util.Locale

/** Pure presentation helpers; no player mutation and no per-frame allocations. */
internal object NativePlayerPresentation {
    fun selectedTrackLabel(tracks: Tracks, type: Int, off: String): String {
        tracks.groups.filter { it.type == type }.forEach { group ->
            for (index in 0 until group.length) {
                if (!group.isTrackSelected(index)) continue
                val format = group.getTrackFormat(index)
                return when (type) {
                    C.TRACK_TYPE_VIDEO -> when {
                        format.height >= 2160 -> "4K"
                        format.height >= 1080 -> "1080p"
                        format.height >= 720 -> "720p"
                        format.height > 0 -> "${format.height}p"
                        else -> format.label ?: "Auto"
                    }
                    else -> format.label?.takeIf { it.isNotBlank() }
                        ?: displayLanguage(format.language)
                        ?: off
                }
            }
        }
        return off
    }

    fun mediaSummary(tracks: Tracks, subtitles: String, off: String): String {
        val quality = selectedTrackLabel(tracks, C.TRACK_TYPE_VIDEO, "Auto")
        val audio = selectedTrackLabel(tracks, C.TRACK_TYPE_AUDIO, "Auto")
        val text = selectedTrackLabel(tracks, C.TRACK_TYPE_TEXT, off)
        return "$quality  •  $audio  •  $subtitles: $text"
    }

    fun healthLabel(
        loading: Boolean,
        latencyMs: Long?,
        rebufferCount: Int,
        droppedFrames: Int,
        lastError: String,
        checking: String,
        good: String,
        weak: String,
        problem: String
    ): String = when {
        loading -> checking
        lastError.isNotBlank() -> problem
        rebufferCount >= 3 || droppedFrames >= 30 || (latencyMs ?: 0L) >= 800L -> weak
        else -> good
    }

    private fun displayLanguage(code: String?): String? {
        if (code.isNullOrBlank() || code == "und") return null
        val value = Locale.forLanguageTag(code).getDisplayLanguage(Locale.getDefault())
        return value.takeIf { it.isNotBlank() }?.replaceFirstChar {
            if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString()
        }
    }
}
