import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.aladin.iptv.player.pro"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.aladin.iptv.player.pro"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        // Public release 47 follows the already-published 1046 Android code.
        versionCode = 1047
        versionName = flutter.versionName
    }

    signingConfigs {
        getByName("debug") {
            // debug keystore varsayılan konumda
        }
        create("release") {
            keyAlias     = keystoreProperties["keyAlias"]     as String?
            keyPassword  = keystoreProperties["keyPassword"]  as String?
            storeFile    = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            // Madde 2: Fallback KALDIRILDI. key.properties yoksa build kasıtlı olarak hata verir.
            // Hatalı/debug-imzalı AAB'nin Play Store'a gitmesini engeller.
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled    = true
            isShrinkResources  = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isMinifyEnabled   = false
            isShrinkResources = false
        }
    }

    lint {
        disable       += "MissingTranslation"
        abortOnError   = true
        checkReleaseBuilds = true
    }

    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }
}

flutter {
    source = "../.."
}

// Tüm Media3 bağımlılıklarının aynı versiyonda kalmasını zorla.
// Farklı Flutter paketleri eski Media3 sürümlerini geçişli olarak çekebilir;
// bu blok sürüm çakışmalarını önler.
val media3Version = "1.3.1"

configurations.all {
    resolutionStrategy {
        force("androidx.core:core:1.13.1")
        force("androidx.core:core-ktx:1.13.1")
        force("androidx.media3:media3-common:$media3Version")
        force("androidx.media3:media3-exoplayer:$media3Version")
        force("androidx.media3:media3-ui:$media3Version")
        force("androidx.media3:media3-session:$media3Version")
    }
}

dependencies {
    // AndroidX
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("androidx.activity:activity-ktx:1.9.0")
    implementation("androidx.leanback:leanback:1.0.0")

    // Media3 — tüm modüller aynı versiyonda olmalı
    implementation("androidx.media3:media3-exoplayer:$media3Version")
    implementation("androidx.media3:media3-datasource:$media3Version")
    implementation("androidx.media3:media3-exoplayer-hls:$media3Version")   // HLS (.m3u8)
    implementation("androidx.media3:media3-exoplayer-dash:$media3Version")  // DASH (.mpd) — YENİ
    implementation("androidx.media3:media3-exoplayer-rtsp:$media3Version")  // RTSP
    implementation("androidx.media3:media3-ui:$media3Version")
    implementation("androidx.media3:media3-common:$media3Version")
    implementation("androidx.media3:media3-session:$media3Version") // YENİ: MediaSession desteği

    // Glide — poster yükleme
    implementation("com.github.bumptech.glide:glide:4.16.0")

    // FFmpeg extension (yerel AAR)
    implementation(files("libs/media3-ffmpeg.aar"))
}
