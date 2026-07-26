package com.aladin.iptv.player.pro

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.Build
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList
import android.media.tv.TvContract
import android.content.ContentValues
import android.net.Uri
import android.content.ContentUris

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "aladin/exoplayer"
    private var methodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        intent?.data?.let { uri ->
            if (uri.scheme == "aladin" && uri.host == "play") {
                val channelId = uri.getQueryParameter("id")?.toIntOrNull()
                if (channelId != null) {
                    // Flutter'a bu URL'yi oynatması için sinyal gönder
                    mainHandler.postDelayed({
                        methodChannel?.invokeMethod("playChannelId", mapOf("id" to channelId))
                    }, 1000)
                }
            }
        }
    }

    private val mainHandler = Handler(Looper.getMainLooper())

    private val playerReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                "com.aladin.iptv.player.pro.FAVORITE_TOGGLED" -> {
                    val url = intent.getStringExtra("url")
                    val isFavorite = intent.getBooleanExtra("isFavorite", false)
                    methodChannel?.invokeMethod("onFavoriteToggled", mapOf(
                        "url" to url,
                        "isFavorite" to isFavorite
                    ))
                }
                "com.aladin.iptv.player.pro.PROGRESS_UPDATE" -> {
                    val url = intent.getStringExtra("url")
                    val position = intent.getLongExtra("position", 0L)
                    val duration = intent.getLongExtra("duration", 0L)
                    methodChannel?.invokeMethod("onProgressUpdate", mapOf(
                        "url" to url,
                        "position" to position,
                        "duration" to duration
                    ))
                }
                "com.aladin.iptv.player.pro.OPEN_SETTINGS" -> {
                    methodChannel?.invokeMethod("openSettings", null)
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel = channel
        
        channel.setMethodCallHandler { call, result ->
            if (call.method == "playNative") {
                val urls = call.argument<List<String>>("urls")
                val names = call.argument<List<String>>("names")
                val descriptions = call.argument<List<String>>("descriptions")
                val posters = call.argument<List<String>>("posters")
                val ratings = call.argument<List<String>>("ratings")
                val years = call.argument<List<String>>("years")
                val types = call.argument<List<String>>("types")
                val headers = call.argument<List<String>>("headers")
                val favs = call.argument<List<Boolean>>("favs")
                val positions = call.argument<List<Int>>("positions")
                val index = call.argument<Int>("index") ?: 0
                val i18n = call.argument<Map<String, String>>("i18n")
                val decoderMode = call.argument<String>("decoderMode") ?: "auto"
                val videoLimit = call.argument<Int>("videoLimit") ?: 0
                val matchFrameRate = call.argument<Boolean>("matchFrameRate") ?: false
                
                val intent = Intent(this, NativePlayerActivity::class.java).apply {
                    putStringArrayListExtra("URL_LIST", if (urls != null) ArrayList(urls) else ArrayList())
                    putStringArrayListExtra("NAME_LIST", if (names != null) ArrayList(names) else ArrayList())
                    putStringArrayListExtra("DESC_LIST", if (descriptions != null) ArrayList(descriptions) else ArrayList())
                    putStringArrayListExtra("POSTER_LIST", if (posters != null) ArrayList(posters) else ArrayList())
                    putStringArrayListExtra("RATING_LIST", if (ratings != null) ArrayList(ratings) else ArrayList())
                    putStringArrayListExtra("YEAR_LIST", if (years != null) ArrayList(years) else ArrayList())
                    putStringArrayListExtra("TYPE_LIST", if (types != null) ArrayList(types) else ArrayList())
                    putStringArrayListExtra("HEADERS_LIST", if (headers != null) ArrayList(headers) else ArrayList())
                    putExtra("FAV_LIST", if (favs != null) ArrayList(favs) else ArrayList<Boolean>())
                    putExtra("POS_LIST", if (positions != null) ArrayList(positions) else ArrayList<Int>())
                    putExtra("CURRENT_INDEX", index)
                    putExtra("DECODER_MODE", decoderMode)
                    putExtra("VIDEO_LIMIT", videoLimit)
                    putExtra("MATCH_FRAME_RATE", matchFrameRate)
                    if (i18n != null) {
                        for ((key, value) in i18n) {
                            putExtra("i18n_$key", value)
                        }
                    }
                }
                startActivity(intent)
                result.success(true)
            } else if (call.method == "addToWatchNext") {
                val tvPrefs = getSharedPreferences("AladinTvIntegration", Context.MODE_PRIVATE)
                if (tvPrefs.getBoolean("watch_next_unsupported", false)) {
                    result.success(false)
                    return@setMethodCallHandler
                }
                val title = call.argument<String>("title")
                val description = call.argument<String>("description")
                val poster = call.argument<String>("poster")
                val channelId = call.argument<String>("channelId")
                val contentType = call.argument<String>("contentType") ?: "movie"
                val positionMs = call.argument<Int>("positionMs") ?: 0
                val durationMs = call.argument<Int>("durationMs") ?: 0
                if (channelId.isNullOrBlank()) {
                    result.success(false)
                    return@setMethodCallHandler
                }
                
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    try {
                        val type = if (contentType == "series") TvContract.WatchNextPrograms.TYPE_TV_EPISODE else TvContract.WatchNextPrograms.TYPE_MOVIE
                        val values = ContentValues().apply {
                            put(TvContract.WatchNextPrograms.COLUMN_TYPE, type)
                            put(TvContract.WatchNextPrograms.COLUMN_WATCH_NEXT_TYPE, TvContract.WatchNextPrograms.WATCH_NEXT_TYPE_CONTINUE)
                            put(TvContract.WatchNextPrograms.COLUMN_TITLE, title)
                            put(TvContract.WatchNextPrograms.COLUMN_LONG_DESCRIPTION, description)
                            put(TvContract.WatchNextPrograms.COLUMN_POSTER_ART_URI, poster)
                            put(TvContract.WatchNextPrograms.COLUMN_INTERNAL_PROVIDER_ID, channelId)
                            if (positionMs > 0) put(TvContract.WatchNextPrograms.COLUMN_LAST_PLAYBACK_POSITION_MILLIS, positionMs)
                            if (durationMs > 0) put(TvContract.WatchNextPrograms.COLUMN_DURATION_MILLIS, durationMs)
                            // Bu program tıklandığında uygulamayı açması için gereken Intent URI'si
                            put(TvContract.WatchNextPrograms.COLUMN_INTENT_URI, "aladin://play?id=$channelId")
                        }
                        var existingId: Long? = null
                        contentResolver.query(
                            TvContract.WatchNextPrograms.CONTENT_URI,
                            arrayOf(
                                TvContract.WatchNextPrograms._ID,
                                TvContract.WatchNextPrograms.COLUMN_INTERNAL_PROVIDER_ID,
                                TvContract.WatchNextPrograms.COLUMN_INTENT_URI
                            ),
                            null,
                            null,
                            null
                        )?.use { cursor ->
                            while (cursor.moveToNext()) {
                                val providerId = cursor.getString(1)
                                val intentUri = cursor.getString(2) ?: ""
                                if (providerId == channelId && intentUri.startsWith("aladin://")) {
                                    existingId = cursor.getLong(0)
                                    break
                                }
                            }
                        }
                        val changed = if (existingId != null) {
                            val existingUri = ContentUris.withAppendedId(
                                TvContract.WatchNextPrograms.CONTENT_URI,
                                existingId!!
                            )
                            contentResolver.update(existingUri, values, null, null) > 0
                        } else {
                            contentResolver.insert(
                                TvContract.WatchNextPrograms.CONTENT_URI,
                                values
                            ) != null
                        }
                        result.success(changed)
                    } catch (e: Exception) {
                        if (e is SecurityException) {
                            tvPrefs.edit().putBoolean("watch_next_unsupported", true).apply()
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        result.error("WATCH_NEXT_ERROR", e.message, null)
                    }
                } else {
                    result.success(false)
                }
            } else if (call.method == "syncSearchData") {
                val items = call.argument<List<Map<String, String>>>("items")
                val blockedIds = call.argument<List<String>>("blockedIds") ?: emptyList()
                if (items != null) {
                    val db = AladinSearchProvider.DatabaseHelper(this).writableDatabase
                    db.beginTransaction()
                    try {
                        db.delete("search_items", null, null)
                        for (item in items) {
                            val values = ContentValues().apply {
                                put("id", item["id"]?.toInt() ?: 0)
                                put("name", item["name"])
                                put("category", item["category"])
                                put("logo", item["logo"])
                            }
                            db.insert("search_items", null, values)
                        }
                        db.setTransactionSuccessful()
                        val tvPrefs = getSharedPreferences("AladinTvIntegration", Context.MODE_PRIVATE)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                            !tvPrefs.getBoolean("watch_next_unsupported", false)) {
                            val blocked = blockedIds.toHashSet()
                            contentResolver.query(
                                TvContract.WatchNextPrograms.CONTENT_URI,
                                arrayOf(
                                    TvContract.WatchNextPrograms._ID,
                                    TvContract.WatchNextPrograms.COLUMN_INTERNAL_PROVIDER_ID,
                                    TvContract.WatchNextPrograms.COLUMN_INTENT_URI
                                ),
                                null,
                                null,
                                null
                            )?.use { cursor ->
                                while (cursor.moveToNext()) {
                                    val providerId = cursor.getString(1)
                                    val intentUri = cursor.getString(2) ?: ""
                                    if (providerId in blocked && intentUri.startsWith("aladin://")) {
                                        val uri = ContentUris.withAppendedId(
                                            TvContract.WatchNextPrograms.CONTENT_URI,
                                            cursor.getLong(0)
                                        )
                                        try {
                                            contentResolver.delete(uri, null, null)
                                        } catch (error: SecurityException) {
                                            tvPrefs.edit().putBoolean("watch_next_unsupported", true).apply()
                                            break
                                        }
                                    }
                                }
                            }
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SYNC_ERROR", e.message, null)
                    } finally {
                        db.endTransaction()
                    }
                } else {
                    result.success(false)
                }
            } else {
                result.notImplemented()
            }
        }
        
        val filter = IntentFilter().apply {
            addAction("com.aladin.iptv.player.pro.FAVORITE_TOGGLED")
            addAction("com.aladin.iptv.player.pro.PROGRESS_UPDATE")
            addAction("com.aladin.iptv.player.pro.OPEN_SETTINGS")
        }
        
        if (android.os.Build.VERSION.SDK_INT >= 33) { // TIRAMISU (Android 13) and above
            registerReceiver(playerReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(playerReceiver, filter)
        }
    }

    override fun onDestroy() {
        unregisterReceiver(playerReceiver)
        super.onDestroy()
    }
}
