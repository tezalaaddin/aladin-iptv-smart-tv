package com.aladin.iptv.player.pro

import android.app.PictureInPictureParams
import androidx.appcompat.app.AlertDialog
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.media.AudioManager
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import android.util.Rational
import android.util.TypedValue
import android.view.GestureDetector
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.View
import android.view.Surface
import android.view.SurfaceView
import android.view.WindowManager
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.SeekBar
import android.widget.TextView
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.MimeTypes
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.TrackSelectionOverride
import androidx.media3.common.Tracks
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.DefaultLoadControl
import androidx.media3.exoplayer.DefaultRenderersFactory
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.analytics.AnalyticsListener
import androidx.media3.exoplayer.drm.DefaultDrmSessionManagerProvider
import androidx.media3.datasource.DefaultDataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector
import androidx.media3.exoplayer.upstream.DefaultBandwidthMeter
import androidx.media3.session.MediaSession
import androidx.media3.ui.AspectRatioFrameLayout
import androidx.media3.ui.PlayerView
import java.util.ArrayList
import java.util.Locale
import java.util.UUID
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors

import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.load.engine.DiskCacheStrategy

// ─────────────────────────────────────────────────────────────────────────────
//  NativePlayerActivity — AladinMedia Player Pro
//  Optimized for low-end Android TV (Amlogic / RealTek / MediaTek, 1–2 GB RAM)
//
//  Improvements over previous build:
//   1.  Dynamic LoadControl  — live vs VOD, low vs normal memory
//   2.  BandwidthMeter       — conservative 1 Mbps seed, prevents aggressive ABR
//   3.  WifiLock             — prevents WiFi sleep during playback
//   4.  WakeMode             — keeps CPU + network alive without a screen lock
//   5.  MIME-type hints      — ExoPlayer skips format detection; zapping ~200ms faster
//   6.  NetworkCallback      — pauses on disconnection, resumes on reconnection
//   7.  onResume guard       — won't auto-play if user explicitly paused
//   8.  Live stream config   — ExoPlayer uses live latency target instead of VoD rules
//   9.  DASH support         — media3-exoplayer-dash dependency added (see build.gradle)
//  10.  setWakeMode          — proper wake lock delegation to ExoPlayer internals
//  11.  Decoder fallback     — improved: tries hardware first, falls to FFmpeg on fail
//  12.  Buffer bytes cap     — low-mem devices capped at 8 MB to prevent OOM
// ─────────────────────────────────────────────────────────────────────────────
@UnstableApi
class NativePlayerActivity : AppCompatActivity(),
    GestureDetector.OnGestureListener,
    GestureDetector.OnDoubleTapListener {

    // ── Companion ─────────────────────────────────────────────────────────────
    companion object {
        private const val TAG = "ALADIN_PLAYER"

        // Buffer constants (ms) — tuned for low-end TV devices
        private const val LIVE_MIN_BUFFER_MS   = 5_000   // 5 s  — slightly higher for stability
        private const val LIVE_MAX_BUFFER_MS   = 15_000  // 15 s
        private const val VOD_MIN_BUFFER_MS    = 15_000  // 15 s
        private const val VOD_MAX_BUFFER_MS    = 50_000  // 50 s
        private const val PLAYBACK_START_MS    = 2_500   // Increased to 2.5s to prevent initial freeze
        private const val REBUFFER_START_MS    = 5_000   // rebuffer after 5 s drained

        // Low-memory caps (1GB-2GB RAM Devices)
        private const val LOW_MEM_MIN_MS       = 15_000  // 15 s
        private const val LOW_MEM_MAX_MS       = 40_000  // 40 s
        private const val LOW_MEM_BUFFER_BYTES = 24 * 1024 * 1024  // 24 MB cap (Safe for 1-2GB RAM)
        private const val NORMAL_BUFFER_BYTES  = DefaultLoadControl.DEFAULT_TARGET_BUFFER_BYTES

        // High-memory profile (roughly 4 GB+ RAM devices)
        private const val HIGH_MEM_LIVE_MIN_MS  = 8_000
        private const val HIGH_MEM_LIVE_MAX_MS  = 25_000
        private const val HIGH_MEM_VOD_MIN_MS   = 25_000
        private const val HIGH_MEM_VOD_MAX_MS   = 75_000
        private const val HIGH_MEM_BUFFER_BYTES = 64 * 1024 * 1024

        // OSD / UI timings
        private const val OSD_HIDE_DELAY_MS    = 5_000L
        private const val STATUS_HIDE_DELAY_MS = 5_000L
        private const val BUFFERING_WARN_MS    = 15_000L
        // Initial attempt + two retries = at most about 45 seconds.
        private const val BUFFERING_TIMEOUT_MS = 15_000L
        private const val MAX_BUFFERING_RETRIES = 2
        private const val ZAPPING_DEBOUNCE_MS  = 500L
        private const val SEEK_COMMIT_MS       = 800L

        init {
            try {
                System.loadLibrary("ffmpeg")
                Log.d(TAG, "FFmpeg library loaded")
            } catch (t: Throwable) {
                Log.e(TAG, "FFmpeg not available: ${t.message}")
            }
        }
    }

    // ── Player & UI ──────────────────────────────────────────────────────────
    private var player: ExoPlayer? = null
    private var mediaSession: MediaSession? = null
    private lateinit var playerView: PlayerView
    private lateinit var audioManager: AudioManager
    private lateinit var trackSelector: DefaultTrackSelector
    private lateinit var prefs: SharedPreferences
    private lateinit var localizer: NativePlayerLocalizer
    private lateinit var gestureDetector: GestureDetector
    private var lastWatchReportRealtime = 0L

    // UI refs
    private lateinit var channelInfoLayout: LinearLayout
    private lateinit var seekbarContainer: LinearLayout
    private lateinit var tvChannelName: TextView
    private lateinit var tvTimeInfo: TextView
    private lateinit var ivFavorite: ImageView
    private lateinit var seekBar: SeekBar
    private lateinit var keyGuideLayout: LinearLayout
    private lateinit var volumeLayout: LinearLayout
    private lateinit var tvStatusOverlay: TextView
    private lateinit var btnLoadingBack: TextView
    private lateinit var tvVolumeLevel: TextView
    private lateinit var pbLoading: android.widget.ProgressBar
    private lateinit var quickListLayout: LinearLayout
    private lateinit var lvQuickList: android.widget.ListView
    private lateinit var btnSubtitles: TextView
    private lateinit var btnAudio: TextView
    private lateinit var btnQuality: TextView
    private lateinit var btnAspect: TextView
    private lateinit var btnFavorite: TextView
    private lateinit var tvGuideNav: TextView
    private lateinit var tvGuideSeek: TextView
    private lateinit var ivCenterPlayPause: ImageView
    private lateinit var pauseInfoLayout: LinearLayout
    private lateinit var ivPausePoster: ImageView
    private lateinit var tvPauseTitle: TextView
    private lateinit var tvPauseYear: TextView
    private lateinit var tvPauseRating: TextView
    private lateinit var tvPauseDescription: TextView
    private lateinit var errorLayout: LinearLayout
    private lateinit var tvErrorMessage: TextView
    private lateinit var tvErrorSuggestion: TextView
    private lateinit var btnGoToSettings: View
    private lateinit var btnBackToList: View

    // Diagnostics UI (NEW)
    private lateinit var diagnosticsLayout: LinearLayout
    private lateinit var tvDiagTitle: TextView
    private lateinit var tvDiagInternet: TextView
    private lateinit var tvDiagServer: TextView
    private lateinit var tvDiagResolution: TextView
    private lateinit var tvDiagBuffer: TextView
    private lateinit var tvDiagError: TextView
    private val diagnosticsExecutor = Executors.newSingleThreadExecutor()
    @Volatile private var latencyProbeRunning = false
    @Volatile private var serverLatencyMs: Long? = null
    private var latencyHost = ""
    private var lastLatencyProbeAt = 0L
    private var diagnosticsIndex = -1
    private var playbackWasReady = false
    private var activeRebufferStartedAt = 0L
    private var rebufferEventCount = 0
    private var totalRebufferDurationMs = 0L
    private var lastPlaybackError = ""
    private var droppedVideoFrames = 0

    // NEW: Auto-play Next Episode Overlay
    private lateinit var autoPlayOverlay: LinearLayout
    private lateinit var tvAutoPlayTitle: TextView
    private lateinit var tvAutoPlayCountdown: TextView
    private lateinit var btnCancelAutoPlay: View
    private var autoPlayCountdownSeconds = 5
    private val autoPlayHandler = Handler(Looper.getMainLooper())
    private val autoPlayRunnable = object : Runnable {
        override fun run() {
            if (autoPlayCountdownSeconds > 0) {
                tvAutoPlayCountdown.text = "$autoPlayCountdownSeconds..."
                autoPlayCountdownSeconds--
                autoPlayHandler.postDelayed(this, 1000)
            } else {
                autoPlayOverlay.visibility = View.GONE
                currentIndex++
                prepareAndPlay()
            }
        }
    }

    // ── Channel Data ─────────────────────────────────────────────────────────
    private var channelUrls: ArrayList<String>? = null
    private var channelNames: ArrayList<String>? = null
    private var channelDescs: ArrayList<String>? = null
    private var channelPosters: ArrayList<String>? = null
    private var channelRatings: ArrayList<String>? = null
    private var channelYears: ArrayList<String>? = null
    private var channelTypes: ArrayList<String>? = null
    private var channelHeaders: ArrayList<String>? = null
    private var channelFavs: ArrayList<Boolean> = ArrayList()
    private var channelPositions: ArrayList<Int> = ArrayList()
    private var currentIndex: Int = 0
    private var previousIndex: Int = -1

    // ── State ─────────────────────────────────────────────────────────────────
    private var retryCount = 0
    private val MAX_RETRIES = 3
    private var bufferingRetryCount = 0
    private var isPersistentError = false
    private var sleepTimerMinutes = 0
    private var bufferingStartTime = 0L

    // NEW: tracks whether user explicitly paused (prevents onResume auto-play)
    private var userPaused = false

    // NEW: device profile — computed once at init
    private var isLowMem = false
    private var isHighMem = false
    private var preferSoftwareDecoder = false
    private var decoderFallbackAttempted = false
    private var bufferProfile = "auto"
    private var autoPlayNextEpisode = true
    private val isTvDevice: Boolean by lazy {
        packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK) ||
            packageManager.hasSystemFeature(PackageManager.FEATURE_TELEVISION)
    }

    private val primaryControls: List<TextView>
        get() = listOf(btnSubtitles, btnAudio, btnQuality, btnAspect, btnFavorite)

    private val diagnosticsAnalyticsListener = object : AnalyticsListener {
        override fun onDroppedVideoFrames(
            eventTime: AnalyticsListener.EventTime,
            droppedFrames: Int,
            elapsedMs: Long
        ) {
            droppedVideoFrames += droppedFrames
            if (diagnosticsLayout.visibility == View.VISIBLE) {
                mainHandler.post { updateDiagnostics(false) }
            }
        }
    }

    // ── WiFi Lock (NEW) ───────────────────────────────────────────────────────
    // Prevents WiFi chipset from entering doze during playback on cheap TV boxes.
    private var wifiLock: WifiManager.WifiLock? = null

    // ── Network Callback (NEW) ────────────────────────────────────────────────
    private var connectivityManager: ConnectivityManager? = null
    private val networkCallback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) {
            mainHandler.post {
                if (isPersistentError) {
                    Log.d(TAG, "Network restored — auto-retrying")
                    bufferingRetryCount = 0
                    isPersistentError = false
                    prepareAndPlay()
                } else if (player?.playbackState == Player.STATE_IDLE) {
                    prepareAndPlay()
                }
            }
        }
        override fun onLost(network: Network) {
            mainHandler.post {
                if (player?.isPlaying == true) {
                    showStatus(t("no_network", "İnternet bağlantısı kesildi. Bekleniyor..."), true)
                }
            }
        }
    }

    private lateinit var bandwidthMeter: DefaultBandwidthMeter

    // ── Handlers & Runnables ─────────────────────────────────────────────────
    private val mainHandler = Handler(Looper.getMainLooper())
    private var pendingSeekAmount: Long = 0
    private val seekHandler = Handler(Looper.getMainLooper())

    private val hideRunnable = Runnable {
        keyGuideLayout.clearFocus()
        channelInfoLayout.visibility = View.GONE
        seekbarContainer.visibility  = View.GONE
        volumeLayout.visibility = View.GONE
        keyGuideLayout.visibility = View.GONE
        ivCenterPlayPause.visibility = View.GONE
        pbLoading.visibility = View.GONE
        quickListLayout.visibility = View.GONE
        diagnosticsLayout.visibility = View.GONE
    }

    private val hideStatusOverlayRunnable = Runnable {
        tvStatusOverlay.visibility = View.GONE
    }

    private val bufferingStatusRunnable: Runnable = object : Runnable {
        override fun run() {
            if (player?.playbackState == Player.STATE_BUFFERING && player?.playWhenReady == true) {
                val elapsed = (System.currentTimeMillis() - bufferingStartTime) / 1000
                val msg = t("checking_connection", "Bağlantı kontrol ediliyor...")
                val attempt = if (bufferingRetryCount > 0) " (${t("attempt", "Deneme")} $bufferingRetryCount)" else ""
                showStatus("$msg (${elapsed}s)$attempt", true)
                btnLoadingBack.visibility = View.VISIBLE
                pbLoading.visibility = View.VISIBLE
                updateDiagnostics(true)
                mainHandler.postDelayed(this, 1000)
            }
        }
    }

    private val bufferingTimeoutRunnable = Runnable {
        if (bufferingRetryCount < MAX_BUFFERING_RETRIES) {
            bufferingRetryCount++
            Log.d(TAG, "Buffering timeout. Auto-retry #$bufferingRetryCount")
            prepareAndPlay()
        } else {
            isPersistentError = true
            btnLoadingBack.visibility = View.GONE
            pbLoading.visibility = View.GONE
            mainHandler.removeCallbacks(hideRunnable)
            channelInfoLayout.visibility = View.VISIBLE
            showStatus(
                "${t("error_detailed", "Bu içerik şu an açılamıyor. İnternet bağlantınızı kontrol edin.")}\n\n${t("retry_ok", "Yeniden denemek için OK basın")}",
                true
            )
        }
    }

    private val performSeekRunnable = Runnable {
        player?.let { p ->
            val target = max(0L, min(p.currentPosition + pendingSeekAmount, p.duration))
            p.seekTo(target)
            pendingSeekAmount = 0
            hideStatusDelayed()
        }
    }

    private val sleepTimerRunnable = Runnable {
        showSleepShutdownDialog()
    }

    private var sleepShutdownCountdown = 30
    private val sleepShutdownHandler = Handler(Looper.getMainLooper())
    private val sleepShutdownRunnable = object : Runnable {
        override fun run() {
            if (sleepShutdownCountdown > 0) {
                showStatus("${t("shutdown_warning", "Uygulama kapatılıyor...")} ($sleepShutdownCountdown)", true)
                sleepShutdownCountdown--
                sleepShutdownHandler.postDelayed(this, 1000)
            } else {
                saveCurrentPosition()
                finish()
            }
        }
    }

    private fun showSleepShutdownDialog() {
        sleepShutdownCountdown = 30
        sleepShutdownHandler.post(sleepShutdownRunnable)
    }

    private val prepareRunnable = Runnable {
        if (isFinishing || isDestroyed) return@Runnable
        initializePlayer()
        playCurrentChannel()
    }

    private val updateProgressAction = object : Runnable {
        override fun run() {
            if (isFinishing || isDestroyed) return
            player?.let { p ->
                val duration = p.duration
                if (duration != C.TIME_UNSET && duration > 0) {
                    val current = p.currentPosition
                    seekBar.progress = min(current, Int.MAX_VALUE.toLong()).toInt()
                    tvTimeInfo.text = String.format(
                        Locale.getDefault(), "%s / %s",
                        formatTime(current), formatTime(duration)
                    )
                    if (p.isPlaying && current % 60_000 < 1_000) {
                        saveCurrentPosition()
                    }
                }
                
                // Update diagnostics if visible OR if loading
                if (diagnosticsLayout.visibility == View.VISIBLE || pbLoading.visibility == View.VISIBLE) {
                    updateDiagnostics(pbLoading.visibility == View.VISIBLE)
                }
            }
            mainHandler.postDelayed(this, 1_000)
        }
    }

    // ── Lifecycle ─────────────────────────────────────────────────────────────
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        setContentView(R.layout.activity_player)

        WindowCompat.setDecorFitsSystemWindows(window, false)
        val controller = WindowInsetsControllerCompat(window, window.decorView)
        controller.hide(WindowInsetsCompat.Type.systemBars())
        controller.systemBarsBehavior =
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE

        prefs = getSharedPreferences("AladinPlayerPrefs", Context.MODE_PRIVATE)
        localizer = NativePlayerLocalizer(intent)

        // Compute device profile once
        isLowMem = isLowMemoryDevice()
        isHighMem = isHighMemoryDevice()
        preferSoftwareDecoder = shouldPreferSoftwareDecoder()

        // Read intent data
        channelUrls = intent.getStringArrayListExtra("URL_LIST")
        channelNames = intent.getStringArrayListExtra("NAME_LIST")
        channelDescs = intent.getStringArrayListExtra("DESC_LIST")
        channelPosters = intent.getStringArrayListExtra("POSTER_LIST")
        channelRatings = intent.getStringArrayListExtra("RATING_LIST")
        channelYears = intent.getStringArrayListExtra("YEAR_LIST")
        channelTypes = intent.getStringArrayListExtra("TYPE_LIST")
        channelHeaders = intent.getStringArrayListExtra("HEADERS_LIST")
        channelFavs = readSerializableList("FAV_LIST") ?: ArrayList()
        channelPositions = readSerializableList("POS_LIST") ?: ArrayList()
        currentIndex = intent.getIntExtra("CURRENT_INDEX", 0)
        bufferProfile = intent.getStringExtra("BUFFER_PROFILE") ?: "auto"
        autoPlayNextEpisode = intent.getBooleanExtra("AUTO_PLAY_NEXT_EPISODE", true)

        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        gestureDetector = GestureDetector(this, this)
        gestureDetector.setOnDoubleTapListener(this)

        bindViews()
        setupSeekBar()
        setupLabels()
        acquireWifiLock()
        registerNetworkCallback()
        prepareAndPlay()
    }

    override fun onResume() {
        super.onResume()
        mainHandler.post(updateProgressAction)
        // NEW: only auto-play if the user did NOT explicitly pause
        if (!userPaused) {
            player?.play()
        }
    }

    override fun onPause() {
        super.onPause()
        mainHandler.removeCallbacks(updateProgressAction)
        // Do not allow delayed preparation to recreate a session in background.
        mainHandler.removeCallbacks(prepareRunnable)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && isInPictureInPictureMode) {
            // In PiP — keep playing
        } else {
            saveCurrentPosition()
            player?.pause()
            releasePlayer()
        }
    }

    override fun onDestroy() {
        mainHandler.removeCallbacksAndMessages(null)
        releasePlayer()
        diagnosticsExecutor.shutdownNow()
        releaseWifiLock()
        unregisterNetworkCallback()
        super.onDestroy()
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        applyResponsivePlayerLayout()
    }

    // ── PiP ──────────────────────────────────────────────────────────────────
    override fun onUserLeaveHint() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            enterPictureInPictureMode(
                PictureInPictureParams.Builder().setAspectRatio(Rational(16, 9)).build()
            )
        }
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: android.content.res.Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        if (isInPictureInPictureMode) {
            channelInfoLayout.visibility = View.GONE
            keyGuideLayout.visibility = View.GONE
            volumeLayout.visibility = View.GONE
            seekBar.visibility = View.GONE
            pauseInfoLayout.visibility = View.GONE
        }
    }

    // ── Player Init ───────────────────────────────────────────────────────────
    private fun initializePlayer() {
        if (player != null) return

        val requestedDecoderMode = intent.getStringExtra("DECODER_MODE") ?: "auto"
        val channelScope = intent.getStringExtra("CHANNEL_SCOPE") ?: ""
        val learnedMode = if (channelScope.isNotBlank())
            prefs.getString("decoder_override_$channelScope", null) else null
        val decoderMode = if (requestedDecoderMode == "auto" && learnedMode != null)
            learnedMode else requestedDecoderMode
        val isLive = channelTypes?.getOrNull(currentIndex) == "tv"

        // 1. RenderersFactory — Optimized for low-end TVs
        var extensionMode = when (decoderMode) {
            // Hardware: platform MediaCodec only. FFmpeg remains disabled.
            "hw" -> DefaultRenderersFactory.EXTENSION_RENDERER_MODE_OFF
            // Software: prefer the bundled FFmpeg extension, retaining codec fallback.
            "sw", "software" -> DefaultRenderersFactory.EXTENSION_RENDERER_MODE_PREFER
            else -> if (preferSoftwareDecoder) {
                DefaultRenderersFactory.EXTENSION_RENDERER_MODE_PREFER
            } else {
                DefaultRenderersFactory.EXTENSION_RENDERER_MODE_ON
            }
        }

        // 🎬 TV PERFORMANCE FIX:
        // On 1GB RAM devices, software video decoding is too heavy and causes freezing/stuttering.
        // If the device is low-mem, we override "Software" mode to "Hardware-first" (ON) 
        // to ensure smooth playback. Most "No Sound" issues are fixed by the float output flag below.
        if (isLowMem && extensionMode == DefaultRenderersFactory.EXTENSION_RENDERER_MODE_PREFER) {
            extensionMode = DefaultRenderersFactory.EXTENSION_RENDERER_MODE_ON
            if (decoderMode == "sw" || decoderMode == "software") {
                Toast.makeText(
                    this,
                    t("software_low_memory", "Düşük bellek nedeniyle donanım kod çözücü kullanılıyor"),
                    Toast.LENGTH_LONG
                ).show()
            }
        }

        val renderersFactory = DefaultRenderersFactory(this)
            .setExtensionRendererMode(extensionMode)
            .setEnableDecoderFallback(true)         // auto-fallback on decoder crash
            // 🎬 TV AUDIO FIX: Disable float output.
            // Many cheap Android TV boxes (Amlogic/Rockchip) return silence when 32-bit float audio 
            // is requested. Disabling this ensures compatibility with older internal DACs.
            .setEnableAudioFloatOutput(false)

        // 2. BandwidthMeter — NEW: seed with 1 Mbps to prevent aggressive ABR on start
        // On low-end devices, starting at full bitrate causes initial stutter.
        bandwidthMeter = DefaultBandwidthMeter.Builder(this)
            .setInitialBitrateEstimate(
                if (isLowMem) 800_000L else 1_500_000L  // 0.8 or 1.5 Mbps seed
            )
            .build()

        // 3. LoadControl — Tuned for stability on variable networks
        val loadControl = buildLoadControl(isLive)

        // 4. TrackSelector — Smart quality management
        trackSelector = DefaultTrackSelector(this).apply {
            var builder = buildUponParameters()
                .setAllowVideoMixedMimeTypeAdaptiveness(true)
                .setAllowAudioMixedMimeTypeAdaptiveness(true)
            
            if (isLowMem || preferSoftwareDecoder) {
                // 🎬 PERFORMANCE & BUFFER FIX:
                // 2GB ve altı cihazlarda hızı korumak için Full HD'yi sınırlayıp 720p'yi tercih et.
                // Bu, 1.9 Mbps gibi hızlarda donmayı azaltacaktır.
                builder = builder.setMaxVideoSize(1280, 720)
                builder = builder.setMaxAudioChannelCount(2)
            }
            parameters = builder.build()
        }

        // 5. Audio Attributes
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(C.USAGE_MEDIA)
            .setContentType(C.AUDIO_CONTENT_TYPE_MOVIE)
            .build()

        // 6. Build player
        player = ExoPlayer.Builder(this, renderersFactory)
            .setTrackSelector(trackSelector)
            .setLoadControl(loadControl)
            .setBandwidthMeter(bandwidthMeter)
            .setHandleAudioBecomingNoisy(true)
            .setAudioAttributes(audioAttributes, true)
            // NEW: WakeMode — keeps CPU + network alive, no need for manual WakeLock
            .setWakeMode(C.WAKE_MODE_NETWORK)
            .build()

        // NEW: MediaSession — Makes the app "Pro" by integrating with Android OS
        mediaSession = MediaSession.Builder(this, player!!)
            .setId("aladin-player-${UUID.randomUUID()}")
            .build()

        player?.setVideoScalingMode(C.VIDEO_SCALING_MODE_SCALE_TO_FIT) // FIT not CROPPING
        playerView.player = player
        playerView.useController = false

        player?.addListener(playerListener)
        player?.addAnalyticsListener(diagnosticsAnalyticsListener)
    }

    /**
     * Builds a LoadControl tuned for the content type and device capability.
     *
     * Live TV:  Small buffer (3–12 s). Live streams are realtime; buffering more
     *           wastes RAM and increases end-to-end latency for the viewer.
     * VOD:      Larger buffer (15–50 s). Allows smooth playback over variable networks.
     * Low-mem:  Halves the max buffer and enforces an 8 MB byte cap to avoid OOM.
     */
    private fun buildLoadControl(isLive: Boolean): DefaultLoadControl =
        NativePlayerBufferPolicy.create(
            isLive = isLive,
            isLowMemory = isLowMem,
            isHighMemory = isHighMem,
            profile = bufferProfile,
        )

    // ── Player Listener ───────────────────────────────────────────────────────
    private val playerListener = object : Player.Listener {

        override fun onPlayerError(error: PlaybackException) {
            Log.e(TAG, "Playback Error [${error.errorCode}]: ${error.message}", error)
            lastPlaybackError = "${error.errorCodeName}: ${error.message ?: t("error", "Playback error")}".take(180)
            if (diagnosticsLayout.visibility == View.VISIBLE) updateDiagnostics(false)

            val isDecoderError = error.errorCode in listOf(
                PlaybackException.ERROR_CODE_DECODER_INIT_FAILED,
                PlaybackException.ERROR_CODE_DECODING_FAILED,
                PlaybackException.ERROR_CODE_DECODER_QUERY_FAILED
            ) || error.message?.contains("decoder", ignoreCase = true) == true

            val isNetworkError = error.errorCode in listOf(
                PlaybackException.ERROR_CODE_IO_NETWORK_CONNECTION_FAILED,
                PlaybackException.ERROR_CODE_IO_NETWORK_CONNECTION_TIMEOUT,
                PlaybackException.ERROR_CODE_IO_BAD_HTTP_STATUS
            )

            when {
                isDecoderError &&
                    (intent.getStringExtra("DECODER_MODE") ?: "auto") == "auto" &&
                    !decoderFallbackAttempted && !isLowMem -> {
                    decoderFallbackAttempted = true
                    preferSoftwareDecoder = true
                    val scope = intent.getStringExtra("CHANNEL_SCOPE") ?: ""
                    if (scope.isNotBlank()) {
                        prefs.edit().putString("decoder_override_$scope", "sw").apply()
                    }
                    showStatus(t("decoder_fallback", "YazÄ±lÄ±msal kod Ã§Ã¶zÃ¼cÃ¼ deneniyor..."), true)
                    mainHandler.postDelayed({ prepareAndPlay() }, 750L)
                }
                isDecoderError -> showDecoderErrorUI(error.message ?: "")
                isNetworkError && retryCount < MAX_RETRIES -> {
                    retryCount++
                    // Back-off: wait longer on each retry (2s, 4s, 6s)
                    mainHandler.postDelayed({ prepareAndPlay() }, retryCount * 2_000L)
                    showStatus("${t("retry", "Yeniden bağlanılıyor")} ($retryCount/$MAX_RETRIES)...")
                }
                retryCount >= MAX_RETRIES -> {
                    retryCount = 0
                    showStatus(t("error", "Yayın Açılamadı"))
                    nextChannelOnError()
                }
                else -> {
                    retryCount++
                    mainHandler.postDelayed({ prepareAndPlay() }, 2_000)
                }
            }
        }

        override fun onTracksChanged(tracks: Tracks) {
            for (group in tracks.groups) {
                if (group.type == C.TRACK_TYPE_AUDIO) {
                    for (i in 0 until group.length) {
                        val fmt = group.getTrackFormat(i)
                        Log.d(TAG, "Audio: ${fmt.sampleMimeType} | lang=${fmt.language} | supported=${group.isTrackSupported(i)}")
                        if (!group.isTrackSupported(i)) {
                            showStatus("${t("audio_not_supported", "Ses formatı desteklenmiyor")}: ${fmt.sampleMimeType?.substringAfter("/")}", false)
                        }
                    }
                }
            }
            restoreTrackPreference(tracks, C.TRACK_TYPE_AUDIO)
            restoreTrackPreference(tracks, C.TRACK_TYPE_TEXT)
        }

        override fun onPlaybackStateChanged(state: Int) {
            when (state) {
                Player.STATE_BUFFERING -> {
                    if (bufferingStartTime == 0L) bufferingStartTime = System.currentTimeMillis()
                    if (playbackWasReady && activeRebufferStartedAt == 0L) {
                        activeRebufferStartedAt = SystemClock.elapsedRealtime()
                        rebufferEventCount++
                    }
                    mainHandler.removeCallbacks(bufferingStatusRunnable)
                    mainHandler.post(bufferingStatusRunnable)
                    mainHandler.removeCallbacks(bufferingTimeoutRunnable)
                    mainHandler.postDelayed(bufferingTimeoutRunnable, BUFFERING_TIMEOUT_MS)
                }
                Player.STATE_READY -> {
                    if (activeRebufferStartedAt > 0L) {
                        totalRebufferDurationMs +=
                            SystemClock.elapsedRealtime() - activeRebufferStartedAt
                        activeRebufferStartedAt = 0L
                    }
                    playbackWasReady = true
                    decoderFallbackAttempted = false
                    applyContentFrameRate()
                    retryCount = 0
                    bufferingRetryCount = 0
                    bufferingStartTime = 0L
                    isPersistentError = false
                    mainHandler.removeCallbacks(bufferingStatusRunnable)
                    mainHandler.removeCallbacks(bufferingTimeoutRunnable)
                    tvStatusOverlay.visibility = View.GONE
                    btnLoadingBack.visibility = View.GONE
                    pbLoading.visibility = View.GONE
                    player?.let { p ->
                        if (p.duration != C.TIME_UNSET) {
                            seekBar.max = min(p.duration, Int.MAX_VALUE.toLong()).toInt()
                        }
                    }
                    showOSD()
                    if (diagnosticsLayout.visibility == View.VISIBLE) updateDiagnostics(false)
                }
                Player.STATE_ENDED -> {
                    mainHandler.removeCallbacks(bufferingTimeoutRunnable)
                    val size = channelUrls?.size ?: 0
                    val type = channelTypes?.getOrNull(currentIndex) ?: ""
                    if (autoPlayNextEpisode && type == "series" && currentIndex < size - 1) {
                        showAutoPlayOverlay()
                    }
                }
                Player.STATE_IDLE -> { /* no-op */ }
            }
        }

        override fun onIsPlayingChanged(isPlaying: Boolean) {
            configurePrimaryControls()
            if (!isPlaying) {
                updatePauseInfo()
                // Pause panelini gösterirken alt kanal bilgisini gizle
                channelInfoLayout.visibility =
                    if (player?.playbackState == Player.STATE_BUFFERING) View.VISIBLE else View.GONE
            } else {
                pauseInfoLayout.visibility = View.GONE
                // Video oynamaya başladığında OSD açıksa alt bilgiyi geri getir
                if (channelInfoLayout.visibility == View.GONE && keyGuideLayout.visibility == View.VISIBLE) {
                    channelInfoLayout.visibility = View.VISIBLE
                }
            }
        }
    }

    private fun showAutoPlayOverlay() {
        val nextName = channelNames?.getOrNull(currentIndex + 1) ?: return
        tvAutoPlayTitle.text = nextName
        autoPlayCountdownSeconds = 5
        autoPlayOverlay.visibility = View.VISIBLE
        autoPlayHandler.post(autoPlayRunnable)
        btnCancelAutoPlay.requestFocus()
    }

    private fun cancelAutoPlay() {
        autoPlayHandler.removeCallbacks(autoPlayRunnable)
        autoPlayOverlay.visibility = View.GONE
    }

    // ── Playback Control ──────────────────────────────────────────────────────
    private fun prepareAndPlay() {
        if (diagnosticsIndex != currentIndex) {
            diagnosticsIndex = currentIndex
            playbackWasReady = false
            activeRebufferStartedAt = 0L
            rebufferEventCount = 0
            totalRebufferDurationMs = 0L
            lastPlaybackError = ""
            droppedVideoFrames = 0
            serverLatencyMs = null
            latencyHost = ""
            lastLatencyProbeAt = 0L
        }
        mainHandler.removeCallbacks(prepareRunnable)
        autoPlayHandler.removeCallbacks(autoPlayRunnable)
        autoPlayOverlay.visibility = View.GONE
        releasePlayer()
        tvChannelName.text = channelNames?.getOrNull(currentIndex) ?: t("channel_fallback", "Kanal")
        updateFavoriteIcon()
        channelInfoLayout.visibility = View.VISIBLE
        updatePauseInfo()
        showStatus(t("loading", "Yükleniyor..."), true)
        mainHandler.postDelayed(prepareRunnable, ZAPPING_DEBOUNCE_MS)
    }

    private fun playCurrentChannel() {
        val url = channelUrls?.getOrNull(currentIndex) ?: return
        val name = channelNames?.getOrNull(currentIndex) ?: t("channel_fallback", "Kanal")
        val poster = channelPosters?.getOrNull(currentIndex) ?: ""
        val type = channelTypes?.getOrNull(currentIndex) ?: "tv"
        playerView.resizeMode = prefs.getInt(
            "aspect_${url.hashCode()}",
            AspectRatioFrameLayout.RESIZE_MODE_FIT
        )
        val videoLimit = intent.getIntExtra("VIDEO_LIMIT", 0)

        // Apply quality limit if set (ABR control)
        if (videoLimit > 0) {
            trackSelector.parameters = trackSelector.buildUponParameters()
                .setMaxVideoSize(Int.MAX_VALUE, videoLimit)
                .build()
        }

        tvChannelName.text = name
        updateFavoriteIcon()

        // NEW: MediaMetadata — System-wide awareness (Lock screen, Android TV Home)
        val metadata = MediaMetadata.Builder()
            .setTitle(name)
            .setArtist("aladin IPTV Player Pro TV")
            .setArtworkUri(if (poster.isNotEmpty()) android.net.Uri.parse(poster) else null)
            .setMediaType(if (type == "tv") MediaMetadata.MEDIA_TYPE_TV_CHANNEL else MediaMetadata.MEDIA_TYPE_MOVIE)
            .build()

        // NEW: DRM Support (Widevine)
        // Auto-detect if it's a DASH stream which often requires Widevine
        val mediaItemBuilder = MediaItem.Builder()
            .setUri(url)
            .setMimeType(detectMimeType(url))
            .setMediaMetadata(metadata)

        // NEW: External Subtitle Support Infrastructure
        val subtitleUrl = intent.getStringExtra("EXTERNAL_SUBTITLE_URL")
        if (subtitleUrl != null) {
            val subtitleConfig = MediaItem.SubtitleConfiguration.Builder(android.net.Uri.parse(subtitleUrl))
                .setMimeType(MimeTypes.APPLICATION_SUBRIP) // Default to SRT
                .setLanguage("und")
                .setSelectionFlags(C.SELECTION_FLAG_DEFAULT)
                .build()
            mediaItemBuilder.setSubtitleConfigurations(listOf(subtitleConfig))
        }

        // ── Custom Headers Support (PRO) ─────────────────────────────────────
        val headerStr = channelHeaders?.getOrNull(currentIndex)
        val headersMap = parseHeaders(headerStr)
        
        val httpDataSourceFactory = DefaultHttpDataSource.Factory()
            .setAllowCrossProtocolRedirects(true)
            .setConnectTimeoutMs(15_000)
            .setReadTimeoutMs(15_000)
        
        if (headersMap.isNotEmpty()) {
            httpDataSourceFactory.setDefaultRequestProperties(headersMap)
        } else {
            // Default UA for generic IPTV
            httpDataSourceFactory.setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
        }

        val dataSourceFactory = DefaultDataSource.Factory(this, httpDataSourceFactory)
        val mediaSourceFactory = DefaultMediaSourceFactory(this).setDataSourceFactory(dataSourceFactory)
        
        val mediaItem = mediaItemBuilder.build()
        val mediaSource = mediaSourceFactory.createMediaSource(mediaItem)

        player?.setMediaSource(mediaSource, true)
        player?.prepare()

        val persistedMs = prefs.getLong("pos_$url", -1L)
        val savedMs = if (persistedMs >= 0L) persistedMs
            else (channelPositions.getOrNull(currentIndex)?.toLong() ?: 0L) * 1_000L
        if (savedMs > 0) player?.seekTo(savedMs)

        userPaused = false
        player?.play()
        showOSD()
    }

    private fun releasePlayer() {
        mediaSession?.release()
        mediaSession = null
        player?.let { p ->
            p.removeListener(playerListener)
            p.stop()
            p.clearMediaItems()
            p.release()
        }
        player = null
        playerView.player = null
    }

    private fun togglePlayPause() {
        player?.let { p ->
            if (p.isPlaying) {
                userPaused = true
                p.pause()
            } else {
                userPaused = false
                p.play()
            }
            showOSD()
            configurePrimaryControls()
        }
    }

    /** Opens the visible control dock and restores deterministic D-pad focus. */
    private fun showControlMenu() {
        showOSD()
        configurePrimaryControls()
        val preferred = if (isCurrentLive()) btnSubtitles else btnAudio
        preferred.requestFocus()
        mainHandler.removeCallbacks(hideRunnable)
    }

    // Media3 reports TIME_UNSET while every stream is still preparing. Using duration
    // here made movies and episodes temporarily look like live TV and exposed the
    // wrong primary controls. Playlist metadata is stable before player creation.
    private fun isCurrentLive(): Boolean =
        channelTypes?.getOrNull(currentIndex)?.lowercase(Locale.ROOT) == "tv"

    private fun configurePrimaryControls() {
        if (!::btnSubtitles.isInitialized) return
        val live = isCurrentLive()
        if (live) {
            btnSubtitles.text = "☰\n${t("channel_list", "Kanal listesi")}"
            btnAudio.text = "CC\n${t("subtitles", "Altyazı")}"
            btnQuality.text = "♫\n${t("audio", "Ses")}"
            btnAspect.text = "HD\n${t("quality", "Kalite")}"
            btnFavorite.text = "•••\n${t("more", "Diğer")}"
            btnSubtitles.setOnClickListener { showQuickList() }
            btnAudio.setOnClickListener { cycleTracks(C.TRACK_TYPE_TEXT) }
            btnQuality.setOnClickListener { cycleTracks(C.TRACK_TYPE_AUDIO) }
            btnAspect.setOnClickListener { cycleTracks(C.TRACK_TYPE_VIDEO) }
            btnFavorite.setOnClickListener { showMoreControls() }
        } else {
            btnSubtitles.text = "−10\n${t("rewind", "10 sn geri")}"
            btnAudio.text = if (player?.isPlaying == true) {
                "Ⅱ\n${t("pause", "Duraklat")}"
            } else {
                "▶\n${t("play", "Oynat")}"
            }
            btnQuality.text = "+30\n${t("forward", "30 sn ileri")}"
            btnAspect.text = "▤\n${t("episodes", "Bölümler")}"
            btnFavorite.text = "•••\n${t("more", "Diğer")}"
            btnSubtitles.setOnClickListener { accumulateSeek(-10_000L) }
            btnAudio.setOnClickListener { togglePlayPause() }
            btnQuality.setOnClickListener { accumulateSeek(30_000L) }
            btnAspect.setOnClickListener { showQuickList() }
            btnFavorite.setOnClickListener { showMoreControls() }
        }
    }

    /** Secondary actions stay reachable without crowding the main dock. */
    private fun showMoreControls() {
        val labels = arrayOf(
            if (player?.isPlaying == true) t("pause", "Duraklat") else t("play", "Oynat"),
            t("subtitles", "Altyazı"),
            t("audio", "Ses"),
            t("quality", "Kalite"),
            t("aspect", "Ekran oranı"),
            t("favorites_short", "Favori"),
            t("sleep_timer", "Uyku zamanlayıcısı"),
            t("diag_title", "Tanılama")
        )
        AlertDialog.Builder(this)
            .setTitle(channelNames?.getOrNull(currentIndex) ?: t("player_title", "Oynatıcı"))
            .setItems(labels) { dialog, which ->
                dialog.dismiss()
                when (which) {
                    0 -> togglePlayPause()
                    1 -> cycleTracks(C.TRACK_TYPE_TEXT)
                    2 -> cycleTracks(C.TRACK_TYPE_AUDIO)
                    3 -> cycleTracks(C.TRACK_TYPE_VIDEO)
                    4 -> cycleAspectRatio()
                    5 -> toggleFavorite()
                    6 -> cycleSleepTimer()
                    7 -> toggleDiagnostics()
                }
            }
            .setNegativeButton(android.R.string.cancel, null)
            .setOnDismissListener {
                if (isTvDevice && keyGuideLayout.visibility == View.VISIBLE) {
                    btnFavorite.requestFocus()
                }
            }
            .show()
    }

    // ── Key Handling ──────────────────────────────────────────────────────────
    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyGuideLayout.visibility == View.VISIBLE && keyGuideLayout.hasFocus()) {
            when (keyCode) {
                KeyEvent.KEYCODE_BACK, KeyEvent.KEYCODE_ESCAPE -> {
                    keyGuideLayout.clearFocus()
                    keyGuideLayout.visibility = View.GONE
                    resetHideTimer()
                    return true
                }
                KeyEvent.KEYCODE_DPAD_UP -> {
                    keyGuideLayout.clearFocus()
                    resetHideTimer()
                    return true
                }
                KeyEvent.KEYCODE_DPAD_DOWN -> return true
                KeyEvent.KEYCODE_DPAD_LEFT,
                KeyEvent.KEYCODE_DPAD_RIGHT,
                KeyEvent.KEYCODE_DPAD_CENTER,
                KeyEvent.KEYCODE_ENTER -> return super.onKeyDown(keyCode, event)
            }
        }
        val size = channelUrls?.size ?: 1
        when (keyCode) {
            KeyEvent.KEYCODE_DPAD_UP -> {
                if (currentIndex > 0) { previousIndex = currentIndex; currentIndex--; prepareAndPlay() }
                return true
            }
            KeyEvent.KEYCODE_DPAD_DOWN -> {
                if (currentIndex < size - 1) { previousIndex = currentIndex; currentIndex++; prepareAndPlay() }
                return true
            }
            KeyEvent.KEYCODE_DPAD_RIGHT -> {
                player?.let { p ->
                    if (p.duration == C.TIME_UNSET) {
                        audioManager.adjustStreamVolume(AudioManager.STREAM_MUSIC, AudioManager.ADJUST_RAISE, 0); showVolume()
                    } else accumulateSeek(30_000L)
                }; return true
            }
            KeyEvent.KEYCODE_DPAD_LEFT -> {
                player?.let { p ->
                    if (p.duration == C.TIME_UNSET) {
                        audioManager.adjustStreamVolume(AudioManager.STREAM_MUSIC, AudioManager.ADJUST_LOWER, 0); showVolume()
                    } else accumulateSeek(-10_000L)
                }; return true
            }
            KeyEvent.KEYCODE_DPAD_CENTER, KeyEvent.KEYCODE_ENTER -> {
                if (isPersistentError) {
                    bufferingRetryCount = 0; isPersistentError = false; prepareAndPlay()
                } else showControlMenu()
                return true
            }
            KeyEvent.KEYCODE_PROG_RED, KeyEvent.KEYCODE_F1,
            KeyEvent.KEYCODE_1, KeyEvent.KEYCODE_NUMPAD_1 -> { cycleTracks(C.TRACK_TYPE_TEXT); return true }
            KeyEvent.KEYCODE_PROG_GREEN, KeyEvent.KEYCODE_F2,
            KeyEvent.KEYCODE_2, KeyEvent.KEYCODE_NUMPAD_2 -> { cycleTracks(C.TRACK_TYPE_AUDIO); return true }
            KeyEvent.KEYCODE_PROG_YELLOW, KeyEvent.KEYCODE_F3,
            KeyEvent.KEYCODE_3, KeyEvent.KEYCODE_NUMPAD_3 -> { cycleTracks(C.TRACK_TYPE_VIDEO); return true }
            KeyEvent.KEYCODE_PROG_BLUE, KeyEvent.KEYCODE_F4,
            KeyEvent.KEYCODE_4, KeyEvent.KEYCODE_NUMPAD_4 -> { cycleAspectRatio(); return true }
            KeyEvent.KEYCODE_5, KeyEvent.KEYCODE_NUMPAD_5 -> { toggleDiagnostics(); return true }
            KeyEvent.KEYCODE_6, KeyEvent.KEYCODE_NUMPAD_6 -> { showQuickList(); return true }
            KeyEvent.KEYCODE_7, KeyEvent.KEYCODE_NUMPAD_7 -> {
                player?.let { if (it.duration != C.TIME_UNSET) accumulateSeek(-600_000L) }; return true
            }
            KeyEvent.KEYCODE_8, KeyEvent.KEYCODE_NUMPAD_8 -> { cycleSleepTimer(); return true }
            KeyEvent.KEYCODE_9, KeyEvent.KEYCODE_NUMPAD_9 -> {
                player?.let { if (it.duration != C.TIME_UNSET) accumulateSeek(600_000L) }; return true
            }
            KeyEvent.KEYCODE_0, KeyEvent.KEYCODE_NUMPAD_0 -> { toggleFavorite(); return true }
            KeyEvent.KEYCODE_MEDIA_PREVIOUS, KeyEvent.KEYCODE_LAST_CHANNEL -> {
                if (previousIndex in 0 until size) {
                    val target = previousIndex
                    previousIndex = currentIndex
                    currentIndex = target
                    prepareAndPlay()
                }
                return true
            }
            KeyEvent.KEYCODE_BACK, KeyEvent.KEYCODE_ESCAPE -> {
                if (autoPlayOverlay.visibility == View.VISIBLE) {
                    cancelAutoPlay(); return true
                }
                if (quickListLayout.visibility == View.VISIBLE) {
                    quickListLayout.visibility = View.GONE; return true
                }
                if (diagnosticsLayout.visibility == View.VISIBLE) {
                    diagnosticsLayout.visibility = View.GONE; return true
                }
                saveCurrentPosition(); finish(); return true
            }
        }
        return super.onKeyDown(keyCode, event)
    }

    // ── Gesture Handling ──────────────────────────────────────────────────────
    override fun onSingleTapConfirmed(e: MotionEvent): Boolean { showOSD(); return true }
    override fun onDoubleTap(e: MotionEvent): Boolean = false
    override fun onDoubleTapEvent(e: MotionEvent): Boolean = false
    override fun onDown(e: MotionEvent): Boolean = true
    override fun onShowPress(e: MotionEvent) {}
    override fun onSingleTapUp(e: MotionEvent): Boolean = false
    override fun onScroll(e1: MotionEvent?, e2: MotionEvent, dX: Float, dY: Float): Boolean = false
    override fun onLongPress(e: MotionEvent) { toggleFavorite() }

    override fun onFling(e1: MotionEvent?, e2: MotionEvent, vX: Float, vY: Float): Boolean {
        if (e1 == null) return false
        val dX = e2.x - e1.x; val dY = e2.y - e1.y
        val size = channelUrls?.size ?: 1
        if (abs(dX) > abs(dY)) {
            if (abs(dX) > 100 && abs(vX) > 100) {
                player?.let { p ->
                    if (p.duration != C.TIME_UNSET && p.duration > 0) {
                        accumulateSeek(if (dX > 0) 30_000L else -10_000L)
                    } else {
                        audioManager.adjustStreamVolume(AudioManager.STREAM_MUSIC,
                            if (dX > 0) AudioManager.ADJUST_RAISE else AudioManager.ADJUST_LOWER, 0)
                        showVolume()
                    }
                }
            }
        } else {
            if (abs(dY) > 100 && abs(vY) > 100) {
                if (dY > 0 && currentIndex < size - 1) { currentIndex++; prepareAndPlay() }
                else if (dY < 0 && currentIndex > 0) { currentIndex--; prepareAndPlay() }
            }
        }
        return true
    }

    // ── Seek ──────────────────────────────────────────────────────────────────
    private fun accumulateSeek(amount: Long) {
        seekHandler.removeCallbacks(performSeekRunnable)
        pendingSeekAmount += amount
        player?.let { p ->
            val target = max(0L, min(p.currentPosition + pendingSeekAmount, p.duration))
            val sign = if (pendingSeekAmount > 0) "+" else ""
            showStatus("${formatTime(target)} ($sign${pendingSeekAmount / 1000}s)")
            seekBar.progress = min(target, Int.MAX_VALUE.toLong()).toInt()
        }
        channelInfoLayout.visibility = View.VISIBLE
        seekBar.visibility = View.VISIBLE
        seekHandler.postDelayed(performSeekRunnable, SEEK_COMMIT_MS)
    }

    private fun setupSeekBar() {
        seekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(sb: SeekBar?, progress: Int, fromUser: Boolean) {
                if (fromUser) tvTimeInfo.text = formatTime(progress.toLong())
            }
            override fun onStartTrackingTouch(sb: SeekBar?) {
                mainHandler.removeCallbacks(hideRunnable)
            }
            override fun onStopTrackingTouch(sb: SeekBar?) {
                player?.seekTo(seekBar.progress.toLong())
                resetHideTimer()
            }
        })
    }

    // ── Track / Aspect / Sleep ────────────────────────────────────────────────
    private fun cycleTracks(trackType: Int) {
        val p = player ?: return
        val groups = p.currentTracks.groups.filter { it.type == trackType }
        if (groups.isEmpty()) return

        val available = mutableListOf<Triple<Int, Int, String>>()
        groups.forEachIndexed { gi, grp ->
            for (ti in 0 until grp.length) {
                if (!grp.isTrackSupported(ti)) continue
                val fmt = grp.getTrackFormat(ti)
                val label = when (trackType) {
                    C.TRACK_TYPE_TEXT  -> fmt.label ?: fmt.language ?: "${t("subtitles", "Altyazı")} ${available.size + 1}"
                    C.TRACK_TYPE_AUDIO -> fmt.label ?: fmt.language ?: "${t("audio", "Ses")} ${available.size + 1}"
                    else               -> "${fmt.width}x${fmt.height}"
                }
                available.add(Triple(gi, ti, label))
            }
        }
        if (available.isEmpty()) return

        var currentSel = -1
        available.forEachIndexed { i, (gi, ti, _) -> if (groups[gi].isTrackSelected(ti)) currentSel = i }

        val canDisable = trackType != C.TRACK_TYPE_VIDEO
        val cycleSize  = available.size + (if (canDisable) 1 else 0)
        val nextIdx    = (currentSel + 1) % cycleSize

        if (canDisable && nextIdx == available.size) {
            p.trackSelectionParameters = p.trackSelectionParameters.buildUpon()
                .setTrackTypeDisabled(trackType, true).clearOverridesOfType(trackType).build()
            val label = if (trackType == C.TRACK_TYPE_TEXT) t("subtitles", "Altyazı") else t("audio", "Ses")
            showStatus("$label: ${t("off", "Kapalı")}")
        } else {
            val (gi, ti, label) = available[nextIdx]
            p.trackSelectionParameters = p.trackSelectionParameters.buildUpon()
                .setTrackTypeDisabled(trackType, false)
                .setOverrideForType(TrackSelectionOverride(groups[gi].mediaTrackGroup, ti))
                .build()
            val format = groups[gi].getTrackFormat(ti)
            val preference = format.language ?: format.label ?: label
            prefs.edit().putString(
                "track_${trackType}_${channelUrls?.getOrNull(currentIndex)?.hashCode() ?: 0}",
                preference
            ).apply()
            val prefix = when (trackType) {
                C.TRACK_TYPE_TEXT  -> "${t("subtitles", "Altyazı")}: "
                C.TRACK_TYPE_AUDIO -> "${t("audio", "Ses")}: "
                else               -> "${t("quality", "Kalite")}: "
            }
            showStatus("$prefix$label")
        }
    }

    private fun restoreTrackPreference(tracks: Tracks, trackType: Int) {
        val urlHash = channelUrls?.getOrNull(currentIndex)?.hashCode() ?: 0
        val preferred = prefs.getString("track_${trackType}_$urlHash", null) ?: return
        val p = player ?: return
        for (group in tracks.groups) {
            if (group.type != trackType) continue
            for (index in 0 until group.length) {
                val format = group.getTrackFormat(index)
                val value = format.language ?: format.label ?: continue
                if (value == preferred && !group.isTrackSelected(index)) {
                    p.trackSelectionParameters = p.trackSelectionParameters.buildUpon()
                        .setTrackTypeDisabled(trackType, false)
                        .setOverrideForType(TrackSelectionOverride(group.mediaTrackGroup, index))
                        .build()
                    return
                }
            }
        }
    }

    private fun cycleAspectRatio() {
        val modes = intArrayOf(
            AspectRatioFrameLayout.RESIZE_MODE_FIT,
            AspectRatioFrameLayout.RESIZE_MODE_FILL,
            AspectRatioFrameLayout.RESIZE_MODE_ZOOM
        )
        val names = arrayOf(t("aspect_fit", "Sığdır"), t("aspect_fill", "Doldur"), t("aspect_zoom", "Zoom"))
        val next  = (modes.indexOf(playerView.resizeMode) + 1) % modes.size
        playerView.resizeMode = modes[next]
        prefs.edit().putInt("aspect_${channelUrls?.getOrNull(currentIndex)?.hashCode() ?: 0}", modes[next]).apply()
        showStatus("${t("aspect", "Ekran Oranı")}: ${names[next]}")
    }

    private fun applyContentFrameRate() {
        if (!intent.getBooleanExtra("MATCH_FRAME_RATE", false) || Build.VERSION.SDK_INT < 30) return
        val rate = player?.videoFormat?.frameRate ?: return
        if (rate <= 0f) return
        val surface = (playerView.videoSurfaceView as? SurfaceView)?.holder?.surface ?: return
        try {
            surface.setFrameRate(rate, Surface.FRAME_RATE_COMPATIBILITY_FIXED_SOURCE)
        } catch (error: Exception) {
            Log.w(TAG, "Frame-rate matching unavailable", error)
        }
    }

    private fun cycleSleepTimer() {
        val options = listOf(0, 15, 30, 60, 90, 120)
        sleepTimerMinutes = options[(options.indexOf(sleepTimerMinutes) + 1) % options.size]
        mainHandler.removeCallbacks(sleepTimerRunnable)
        if (sleepTimerMinutes > 0) {
            mainHandler.postDelayed(sleepTimerRunnable, sleepTimerMinutes * 60_000L)
            showStatus("${t("sleep_timer", "Uyku Zamanlayıcı")}: $sleepTimerMinutes min", false)
        } else {
            showStatus("${t("sleep_timer", "Uyku Zamanlayıcı")}: ${t("off", "Kapalı")}", false)
        }
    }

    // ── OSD / UI ──────────────────────────────────────────────────────────────
    private fun showOSD() {
        val isPlaying = player?.isPlaying ?: false
        val isBuffering = player?.playbackState == Player.STATE_BUFFERING
        val isVod = player?.duration != C.TIME_UNSET && (player?.duration ?: 0) > 0
        
        // Eğer video duraklatılmışsa (PAUSE), alt kanal bilgisini gizle
        channelInfoLayout.visibility = if (isPlaying || isBuffering) View.VISIBLE else View.GONE
        
        // Seekbar sadece VOD içeriklerde ve OSD açıkken görünür
        seekbarContainer.visibility = if (isVod) View.VISIBLE else View.GONE
        if (isVod) {
            seekBar.visibility = View.VISIBLE
            tvTimeInfo.visibility = View.VISIBLE
        }

        keyGuideLayout.visibility    = View.VISIBLE
        configurePrimaryControls()
        player?.let { p ->
            ivCenterPlayPause.setImageResource(
                if (p.isPlaying) android.R.drawable.ic_media_pause
                else android.R.drawable.ic_media_play
            )
            ivCenterPlayPause.visibility = View.VISIBLE
        }
        resetHideTimer()
    }

    private fun resetHideTimer() {
        mainHandler.removeCallbacks(hideRunnable)
        if (player?.isPlaying == true && !keyGuideLayout.hasFocus()) {
            mainHandler.postDelayed(hideRunnable, OSD_HIDE_DELAY_MS)
        }
    }

    private fun showStatus(msg: String, persistent: Boolean = false) {
        tvStatusOverlay.text = msg
        tvStatusOverlay.visibility = View.VISIBLE
        mainHandler.removeCallbacks(hideStatusOverlayRunnable)
        if (!persistent) mainHandler.postDelayed(hideStatusOverlayRunnable, STATUS_HIDE_DELAY_MS)
    }

    private fun hideStatusDelayed() {
        mainHandler.removeCallbacks(hideRunnable)
        mainHandler.postDelayed(hideRunnable, 2_000)
    }

    private fun showVolume() {
        val cur = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
        val max = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        tvVolumeLevel.text = "%${cur * 100 / max}"
        volumeLayout.visibility = View.VISIBLE
        resetHideTimer()
    }

    private fun showPlayerInfo() {
        player?.let { p ->
            val fmt = p.videoFormat ?: return@let
            val res   = "${fmt.width}x${fmt.height}"
            val fps   = if (fmt.frameRate > 0) "${fmt.frameRate.toInt()} FPS" else ""
            val codec = fmt.sampleMimeType?.substringAfterLast("/")?.uppercase() ?: ""
            val url   = channelUrls?.getOrNull(currentIndex) ?: ""
            val bw    = "${(p.totalBufferedDuration / 1_000)} s buffered"
            showStatus("$res $fps | $codec | $bw\n$url", false)
        }
    }

    private fun showQuickList() {
        if (channelNames == null) return
        findViewById<TextView>(R.id.tv_quick_list_title).text =
            if (isCurrentLive()) t("channel_list", "Kanal listesi")
            else t("episodes", "Bölümler")
        
        val adapter: android.widget.BaseAdapter = object : android.widget.BaseAdapter() {
            override fun getCount(): Int = channelNames?.size ?: 0
            override fun getItem(position: Int): Any = channelNames!![position]
            override fun getItemId(position: Int): Long = position.toLong()
            override fun getView(position: Int, convertView: View?, parent: android.view.ViewGroup?): View {
                val view = convertView ?: layoutInflater.inflate(R.layout.item_quick_list, parent, false)
                val tvName = view.findViewById<TextView>(R.id.tv_item_name)
                val ivLogo = view.findViewById<ImageView>(R.id.iv_item_logo)
                val tvEpg  = view.findViewById<TextView>(R.id.tv_item_epg)

                tvName.text = channelNames!![position]
                val logoUrl = channelPosters?.getOrNull(position) ?: ""
                
                if (logoUrl.isNotEmpty()) {
                    Glide.with(this@NativePlayerActivity)
                        .load(logoUrl)
                        .override(100, 100)
                        .format(DecodeFormat.PREFER_RGB_565)
                        .diskCacheStrategy(DiskCacheStrategy.AUTOMATIC)
                        .into(ivLogo)
                } else {
                    ivLogo.setImageResource(android.R.color.transparent)
                }
                
                tvEpg.text = channelTypes?.getOrNull(position)?.uppercase() ?: ""
                return view
            }
        }

        lvQuickList.adapter = adapter
        lvQuickList.setSelection(currentIndex)
        lvQuickList.setOnItemClickListener { _, _, pos, _ ->
            previousIndex = currentIndex; currentIndex = pos; quickListLayout.visibility = View.GONE; prepareAndPlay()
        }
        quickListLayout.visibility = View.VISIBLE
        lvQuickList.requestFocus()
        resetHideTimer()
    }

    private fun toggleDiagnostics() {
        if (diagnosticsLayout.visibility == View.VISIBLE) {
            diagnosticsLayout.visibility = View.GONE
        } else {
            updateDiagnostics(false)
            diagnosticsLayout.visibility = View.VISIBLE
            resetHideTimer()
        }
    }

    private fun updateDiagnostics(@Suppress("UNUSED_PARAMETER") isLoading: Boolean) {
        player?.let { p ->
            val estimatedMbps = bandwidthMeter.bitrateEstimate / 1_000_000.0
            val connection = currentConnectionLabel()
            tvDiagTitle.text = t("diag_title", "STREAM DIAGNOSTICS")
            tvDiagInternet.text = String.format(
                Locale.getDefault(), "%s: %s • %s: %.1f Mbps",
                t("diag_connection", "Connection"), connection,
                t("diag_bandwidth", "Estimated bandwidth"), estimatedMbps
            )

            probeServerLatency()
            val latency = serverLatencyMs
            val latencyValue = if (latency != null) "${latency} ms" else t("diag_unavailable", "Unavailable")
            tvDiagServer.text = "${t("diag_latency", "Server latency")}: $latencyValue" +
                if (latencyHost.isNotEmpty()) " • $latencyHost" else ""

            val fmt = p.videoFormat
            if (fmt != null) {
                val fps = if (fmt.frameRate > 0) "${fmt.frameRate.toInt()} FPS" else ""
                val codec = fmt.sampleMimeType?.substringAfterLast("/")?.uppercase() ?: ""
                val mediaBitrate = if (fmt.bitrate > 0) String.format(
                    Locale.getDefault(), "%.1f Mbps", fmt.bitrate / 1_000_000.0
                ) else t("diag_unavailable", "Unavailable")
                tvDiagResolution.text = String.format(
                    Locale.getDefault(), "Video: %dx%d • %s: %s • %s %s",
                    fmt.width, fmt.height, t("diag_video_bitrate", "Video bitrate"),
                    mediaBitrate, codec, fps
                ).trim()
            }

            val activeBufferMs = if (activeRebufferStartedAt > 0L) {
                SystemClock.elapsedRealtime() - activeRebufferStartedAt
            } else 0L
            val totalBufferSeconds = (totalRebufferDurationMs + activeBufferMs) / 1_000.0
            val bufferedAheadSeconds = p.totalBufferedDuration / 1_000.0
            tvDiagBuffer.text = String.format(
                Locale.getDefault(), "%s: %d • %s: %.1f s • %s: %.1f s • %s: %d",
                t("diag_buffer_events", "Buffer events"), rebufferEventCount,
                t("diag_buffer_duration", "Total buffer time"), totalBufferSeconds,
                t("diag_buffered_ahead", "Buffered ahead"), bufferedAheadSeconds,
                t("diag_dropped_frames", "Dropped frames"), droppedVideoFrames
            )
            tvDiagError.text = "${t("diag_last_error", "Last playback error")}: " +
                if (lastPlaybackError.isBlank()) t("diag_none", "None") else lastPlaybackError

            // Loading uses the compact status row. Detailed diagnostics are
            // shown only when the user explicitly opens them.
        }
    }

    private fun currentConnectionLabel(): String {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val caps = cm.getNetworkCapabilities(cm.activeNetwork) ?: return "—"
        return when {
            caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> "Ethernet"
            caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "Wi-Fi"
            caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "Mobile"
            else -> "—"
        }
    }

    private fun probeServerLatency() {
        val now = SystemClock.elapsedRealtime()
        if (latencyProbeRunning || now - lastLatencyProbeAt < 15_000L) return
        val streamUrl = channelUrls?.getOrNull(currentIndex) ?: return
        if (!streamUrl.startsWith("http://") && !streamUrl.startsWith("https://")) return
        latencyProbeRunning = true
        lastLatencyProbeAt = now
        diagnosticsExecutor.execute {
            var connection: HttpURLConnection? = null
            try {
                val url = URL(streamUrl)
                latencyHost = url.host
                connection = (url.openConnection() as HttpURLConnection).apply {
                    requestMethod = "HEAD"
                    connectTimeout = 3_000
                    readTimeout = 3_000
                    instanceFollowRedirects = true
                    parseHeaders(channelHeaders?.getOrNull(currentIndex)).forEach { (key, value) ->
                        setRequestProperty(key, value)
                    }
                }
                val started = SystemClock.elapsedRealtime()
                connection.responseCode
                serverLatencyMs = SystemClock.elapsedRealtime() - started
            } catch (_: Throwable) {
                serverLatencyMs = null
            } finally {
                connection?.disconnect()
                latencyProbeRunning = false
                if (!isFinishing && !isDestroyed) mainHandler.post { updateDiagnostics(false) }
            }
        }
    }

    // ── Pause Info / Poster ───────────────────────────────────────────────────
    private fun updatePauseInfo() {
        val type = channelTypes?.getOrNull(currentIndex) ?: "tv"
        if (type == "tv") { pauseInfoLayout.visibility = View.GONE; return }

        tvPauseTitle.text       = channelNames?.getOrNull(currentIndex) ?: ""
        tvPauseDescription.text = channelDescs?.getOrNull(currentIndex) ?: ""
        val rating = channelRatings?.getOrNull(currentIndex) ?: ""
        tvPauseRating.text = if (rating.isNotEmpty()) "⭐ $rating/10" else ""
        tvPauseYear.text   = channelYears?.getOrNull(currentIndex) ?: ""

        val poster = channelPosters?.getOrNull(currentIndex) ?: ""
        if (poster.isNotEmpty()) {
            ivPausePoster.setImageResource(android.R.color.darker_gray) // placeholder
            ivPausePoster.visibility = View.VISIBLE
            loadPoster(poster)
        } else {
            ivPausePoster.visibility = View.GONE
        }
        pauseInfoLayout.visibility = View.VISIBLE
    }

    private fun loadPoster(posterUrl: String) {
        Glide.with(this)
            .load(posterUrl)
            .placeholder(android.R.color.darker_gray)   // gri placeholder, hemen görünür
            .error(android.R.color.darker_gray)          // hata durumunda da gri kal
            .override(320, 180)                          // TV için yeterli, RAM dostu
            .format(DecodeFormat.PREFER_RGB_565)          // 32-bit yerine 16-bit: yaklaşık yarı RAM
            .diskCacheStrategy(DiskCacheStrategy.ALL)    // disk cache: aynı poster tekrar indirilmez
            .into(ivPausePoster)
    }

    // ── Error UI ──────────────────────────────────────────────────────────────
    private fun showDecoderErrorUI(message: String) {
        mainHandler.removeCallbacksAndMessages(null)
        releasePlayer()
        tvErrorMessage.text = t("playback_error", "Oynatma Hatası")
        tvErrorSuggestion.text =
            "${t("decoder_suggestion", "Ayarlardan Yazılımsal Kod Çözücü'yü deneyin.")}\n\n(Error: $message)"
        (btnGoToSettings as? TextView)?.text = t("go_to_settings", "AYARLARA GİT")
        errorLayout.visibility = View.VISIBLE
        errorLayout.requestFocus()
        hideRunnable.run()
    }

    private fun nextChannelOnError() {
        val size = channelUrls?.size ?: return
        if (currentIndex < size - 1) { currentIndex++; prepareAndPlay() }
        else showStatus(t("error", "Yayın Açılamadı"))
    }

    // ── Favorite / Position ───────────────────────────────────────────────────
    private fun toggleFavorite() {
        val url = channelUrls?.getOrNull(currentIndex) ?: return
        val newFav = !(channelFavs.getOrNull(currentIndex) ?: false)
        if (currentIndex < channelFavs.size) channelFavs[currentIndex] = newFav
        updateFavoriteIcon()
        showStatus(if (newFav) t("added", "Favorilere Eklendi") else t("removed", "Favorilerden Çıkarıldı"))
        val i = Intent("com.aladin.iptv.player.pro.FAVORITE_TOGGLED").apply {
            setPackage(packageName); putExtra("url", url); putExtra("isFavorite", newFav)
        }
        sendBroadcast(i)
    }

    private fun updateFavoriteIcon() {
        val isFav = channelFavs.getOrNull(currentIndex) ?: false
        ivFavorite.setImageResource(if (isFav) android.R.drawable.btn_star_big_on else android.R.drawable.btn_star_big_off)
    }

    private fun saveCurrentPosition() {
        val url = channelUrls?.getOrNull(currentIndex) ?: return
        player?.let { p ->
            if (p.duration != C.TIME_UNSET && p.duration > 0) {
                val pos = p.currentPosition
                val nowRealtime = SystemClock.elapsedRealtime()
                val watchedDelta = if (p.isPlaying && lastWatchReportRealtime > 0L)
                    ((nowRealtime - lastWatchReportRealtime) / 1000L).coerceIn(0L, 300L)
                else 0L
                lastWatchReportRealtime = nowRealtime
                prefs.edit().putLong("pos_$url", pos).apply()
                val i = Intent("com.aladin.iptv.player.pro.PROGRESS_UPDATE").apply {
                    setPackage(packageName)
                    putExtra("url", url); putExtra("position", pos); putExtra("duration", p.duration)
                    putExtra("watchedDelta", watchedDelta)
                }
                sendBroadcast(i)
            }
        }
    }

    // ── WiFi Lock ─────────────────────────────────────────────────────────────
    /**
     * Acquires a WiFi lock to prevent the WiFi chipset from sleeping during playback.
     * Many cheap Android TV boxes aggressively power-gate the WiFi radio, causing
     * micro-dropouts every 20–30 seconds. This lock keeps the radio active.
     */
    private fun acquireWifiLock() {
        try {
            val wm = applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager
            wifiLock = wm?.createWifiLock(WifiManager.WIFI_MODE_FULL_HIGH_PERF, "AladinIPTV:WifiLock")
            wifiLock?.acquire()
        } catch (e: Exception) {
            Log.w(TAG, "Could not acquire WifiLock: ${e.message}")
        }
    }

    private fun releaseWifiLock() {
        try {
            if (wifiLock?.isHeld == true) wifiLock?.release()
        } catch (e: Exception) {
            Log.w(TAG, "WifiLock release error: ${e.message}")
        }
    }

    // ── Network Callback ──────────────────────────────────────────────────────
    private fun registerNetworkCallback() {
        try {
            connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val req = NetworkRequest.Builder()
                .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                .build()
            connectivityManager?.registerNetworkCallback(req, networkCallback)
        } catch (e: Exception) {
            Log.w(TAG, "NetworkCallback registration failed: ${e.message}")
        }
    }

    private fun unregisterNetworkCallback() {
        try { connectivityManager?.unregisterNetworkCallback(networkCallback) }
        catch (e: Exception) { Log.w(TAG, "NetworkCallback unregister error: ${e.message}") }
    }

    // ── Device Detection ──────────────────────────────────────────────────────
    private fun isLowMemoryDevice(): Boolean = try {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
        val info = android.app.ActivityManager.MemoryInfo()
        am.getMemoryInfo(info)
        // 2GB RAM ve altındaki cihazları "Low-end" olarak kabul et (TV'ler için kritik eşik)
        info.totalMem < 2_100L * 1024 * 1024  // < ~2.1 GB
    } catch (e: Exception) { false }

    private fun isHighMemoryDevice(): Boolean = try {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
        val info = android.app.ActivityManager.MemoryInfo()
        am.getMemoryInfo(info)
        !am.isLowRamDevice && info.totalMem >= 3_500L * 1024 * 1024
    } catch (e: Exception) { false }

    private fun shouldPreferSoftwareDecoder(): Boolean {
        val model = Build.MODEL ?: ""
        val mfr   = Build.MANUFACTURER ?: ""
        return model.contains("TB-7305", ignoreCase = true) ||
               (mfr.contains("Lenovo", ignoreCase = true) && model.contains("7305"))
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    /**
     * Provides a MIME type hint so ExoPlayer skips format detection entirely.
     * This reduces channel switching latency by ~150–300 ms on slow devices.
     */
    private fun detectMimeType(url: String): String? {
        val lower = url.lowercase()
        return when {
            lower.contains(".m3u8") || lower.contains("/hls/") -> MimeTypes.APPLICATION_M3U8
            lower.contains(".mpd")  || lower.contains("/dash/") -> MimeTypes.APPLICATION_MPD
            lower.contains(".ts")   || lower.contains("/mpegts") || lower.contains("output=ts") -> MimeTypes.VIDEO_MP2T
            lower.contains("rtsp://") -> MimeTypes.APPLICATION_RTSP
            lower.contains(".mp4")  -> MimeTypes.VIDEO_MP4
            lower.contains(".mkv")  -> MimeTypes.VIDEO_MATROSKA
            else                    -> null // Let ExoPlayer detect automatically (prevents "Input does not start with #EXTM3U" error)
        }
    }

    private fun t(key: String, default: String) = localizer.text(key, default)

    @Suppress("DEPRECATION", "UNCHECKED_CAST")
    private fun <T : java.io.Serializable> readSerializableList(key: String): ArrayList<T>? {
        return try {
            intent.getSerializableExtra(key) as? ArrayList<T>
        } catch (e: Exception) {
            null
        }
    }

    private fun formatTime(ms: Long): String {
        val s = ms / 1000; val h = s / 3600; val m = (s % 3600) / 60; val sec = s % 60
        return if (h > 0) String.format(Locale.getDefault(), "%02d:%02d:%02d", h, m, sec)
        else String.format(Locale.getDefault(), "%02d:%02d", m, sec)
    }

    private fun parseHeaders(headerStr: String?): Map<String, String> {
        if (headerStr.isNullOrEmpty()) return emptyMap()
        val map = mutableMapOf<String, String>()
        headerStr.split("\n").forEach { line ->
            val parts = line.split(":", limit = 2)
            if (parts.size == 2) {
                map[parts[0].trim()] = parts[1].trim()
            }
        }
        return map
    }

    private fun setupLabels() {
        applyResponsivePlayerLayout()

        findViewById<TextView>(R.id.tv_quick_list_title).text = t("quick_list", "Hızlı liste")
        findViewById<TextView>(R.id.tv_autoplay_heading).text =
            t("next_episode_starting", "Sonraki bölüm başlıyor")
        (btnGoToSettings as? TextView)?.text = t("go_to_settings", "Ayarlara git")
        (btnBackToList as? TextView)?.text = t("back_to_list", "Listeye dön")
        (btnCancelAutoPlay as? TextView)?.text = t("cancel", "İptal")
        btnLoadingBack.contentDescription = t("back_to_list", "Listeye dön")
        tvErrorMessage.text = t("playback_error", "Oynatma hatası")
        tvErrorSuggestion.text = t("decoder_suggestion", "Yazılımsal kod çözücüyü deneyin.")

        primaryControls.forEach {
            it.isClickable = true
            it.isFocusable = isTvDevice
            it.isFocusableInTouchMode = false
            it.setOnFocusChangeListener { _, focused ->
                if (focused) mainHandler.removeCallbacks(hideRunnable)
            }
        }
        configurePrimaryControls()
    }

    private fun applyResponsivePlayerLayout() {
        val portrait = resources.configuration.orientation == Configuration.ORIENTATION_PORTRAIT
        tvGuideNav.visibility = View.GONE
        tvGuideSeek.visibility = View.GONE
        val textSize = if (portrait) 10f else 13f
        primaryControls.forEach {
            it.setTextSize(TypedValue.COMPLEX_UNIT_SP, textSize)
        }
    }

    private val Int.dp: Int get() = (this * resources.displayMetrics.density).toInt()

    private fun bindViews() {
        playerView         = findViewById(R.id.native_player_view)
        channelInfoLayout  = findViewById(R.id.channel_info_layout)
        seekbarContainer   = findViewById(R.id.seekbar_container)
        tvChannelName      = findViewById(R.id.tv_channel_name)
        tvTimeInfo         = findViewById(R.id.tv_time_info)
        ivFavorite         = findViewById(R.id.iv_favorite)
        seekBar            = findViewById(R.id.player_seekbar)
        keyGuideLayout     = findViewById(R.id.key_guide_layout)
        volumeLayout       = findViewById(R.id.volume_layout)
        tvVolumeLevel      = findViewById(R.id.tv_volume_level)
        tvStatusOverlay    = findViewById(R.id.tv_status_overlay)
        btnLoadingBack     = findViewById(R.id.btn_loading_back)
        pbLoading          = findViewById(R.id.pb_loading)
        quickListLayout    = findViewById(R.id.quick_list_layout)
        lvQuickList        = findViewById(R.id.lv_quick_list)
        pauseInfoLayout    = findViewById(R.id.pause_info_layout)
        ivPausePoster      = findViewById(R.id.iv_pause_poster)
        tvPauseTitle       = findViewById(R.id.tv_pause_title)
        tvPauseYear        = findViewById(R.id.tv_pause_year)
        tvPauseRating      = findViewById(R.id.tv_pause_rating)
        tvPauseDescription = findViewById(R.id.tv_pause_description)
        btnSubtitles       = findViewById(R.id.btn_subtitles)
        btnAudio           = findViewById(R.id.btn_audio)
        btnQuality         = findViewById(R.id.btn_quality)
        btnAspect          = findViewById(R.id.btn_aspect)
        btnFavorite        = findViewById(R.id.btn_favorite)
        tvGuideNav         = findViewById(R.id.tv_guide_nav)
        tvGuideSeek        = findViewById(R.id.tv_guide_seek)
        ivCenterPlayPause  = findViewById(R.id.iv_center_play_pause)
        errorLayout        = findViewById(R.id.error_layout)
        tvErrorMessage     = findViewById(R.id.tv_error_message)
        tvErrorSuggestion  = findViewById(R.id.tv_error_suggestion)
        btnGoToSettings    = findViewById(R.id.btn_go_to_settings)
        btnBackToList      = findViewById(R.id.btn_back_to_list)

        diagnosticsLayout  = findViewById(R.id.diagnostics_layout)
        tvDiagTitle        = findViewById(R.id.tv_diag_title)
        tvDiagInternet     = findViewById(R.id.tv_diag_internet)
        tvDiagServer       = findViewById(R.id.tv_diag_server)
        tvDiagResolution   = findViewById(R.id.tv_diag_resolution)
        tvDiagBuffer       = findViewById(R.id.tv_diag_buffer)
        tvDiagError        = findViewById(R.id.tv_diag_error)

        autoPlayOverlay    = findViewById(R.id.autoplay_overlay)
        tvAutoPlayTitle    = findViewById(R.id.tv_autoplay_title)
        tvAutoPlayCountdown = findViewById(R.id.tv_autoplay_countdown)
        btnCancelAutoPlay  = findViewById(R.id.btn_cancel_autoplay)

        playerView.setOnTouchListener { _, event -> gestureDetector.onTouchEvent(event); true }
        ivCenterPlayPause.setOnClickListener { togglePlayPause() }
        ivFavorite.setOnClickListener { toggleFavorite() }
        btnLoadingBack.setOnClickListener { saveCurrentPosition(); finish() }
        btnCancelAutoPlay.setOnClickListener { cancelAutoPlay() }
        btnBackToList.setOnClickListener { saveCurrentPosition(); finish() }
        btnGoToSettings.setOnClickListener {
            saveCurrentPosition()
            val i = Intent("com.aladin.iptv.player.pro.OPEN_SETTINGS").apply { setPackage(packageName) }
            sendBroadcast(i); finish()
        }
    }
}
