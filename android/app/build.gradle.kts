import java.util.Properties
import java.io.FileInputStream
import javax.imageio.ImageIO

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
        // Keep Android packages aligned with the build number in pubspec.yaml.
        versionCode = flutter.versionCode
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
            // Publish native symbol tables for Play crash reports while the
            // shared libraries delivered to users stay stripped and compact.
            ndk {
                debugSymbolLevel = "SYMBOL_TABLE"
            }
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

val verifyTvArtwork by tasks.registering {
    group = "verification"
    description = "Validates every Android TV launcher icon and banner before packaging."

    doLast {
        val policyDir = file("src/main/res/drawable-xhdpi")
        val policyIconFile = policyDir.resolve("tv_launcher_icon.png")
        val policyBannerFile = policyDir.resolve("tv_banner.png")

        check(policyIconFile.isFile) { "Missing Google Play xhdpi TV icon: $policyIconFile" }
        check(policyBannerFile.isFile) { "Missing Google Play xhdpi TV banner: $policyBannerFile" }

        val policyIcon = ImageIO.read(policyIconFile)
            ?: error("Unreadable Google Play xhdpi TV icon: $policyIconFile")
        val policyBanner = ImageIO.read(policyBannerFile)
            ?: error("Unreadable Google Play xhdpi TV banner: $policyBannerFile")

        check(policyIcon.width == 512 && policyIcon.height == 512) {
            "Google Play xhdpi TV icon must be 512x512, found ${policyIcon.width}x${policyIcon.height}"
        }
        check(policyBanner.width == 320 && policyBanner.height == 180) {
            "Google Play xhdpi TV banner must be 320x180, found ${policyBanner.width}x${policyBanner.height}"
        }
        check(listOf(
            policyIcon.getRGB(0, 0),
            policyIcon.getRGB(policyIcon.width - 1, 0),
            policyIcon.getRGB(0, policyIcon.height - 1),
            policyIcon.getRGB(policyIcon.width - 1, policyIcon.height - 1),
        ).all { (it ushr 24) == 0xFF }) {
            "Google Play xhdpi TV icon must fill the complete 512x512 canvas"
        }

        val expectedSizes = mapOf(
            "mdpi" to Pair(80, 80),
            "hdpi" to Pair(120, 120),
            "xhdpi" to Pair(160, 160),
            "xxhdpi" to Pair(240, 240),
            "xxxhdpi" to Pair(320, 320),
        )

        expectedSizes.forEach { (density, iconSize) ->
            val densityDir = file("src/main/res/mipmap-$density")
            val iconFile = densityDir.resolve("tv_launcher_icon.png")
            val bannerFile = densityDir.resolve("tv_banner.png")
            val bannerSize = Pair(iconSize.first * 2, iconSize.second * 9 / 8)

            check(iconFile.isFile) { "Missing Android TV icon: $iconFile" }
            check(bannerFile.isFile) { "Missing Android TV banner: $bannerFile" }

            val icon = ImageIO.read(iconFile)
                ?: error("Unreadable Android TV icon: $iconFile")
            val banner = ImageIO.read(bannerFile)
                ?: error("Unreadable Android TV banner: $bannerFile")

            check(icon.width == iconSize.first && icon.height == iconSize.second) {
                "$density TV icon must be ${iconSize.first}x${iconSize.second}, " +
                    "found ${icon.width}x${icon.height}"
            }
            check(banner.width == bannerSize.first && banner.height == bannerSize.second) {
                "$density TV banner must be ${bannerSize.first}x${bannerSize.second}, " +
                    "found ${banner.width}x${banner.height}"
            }

            val iconCorners = listOf(
                icon.getRGB(0, 0),
                icon.getRGB(icon.width - 1, 0),
                icon.getRGB(0, icon.height - 1),
                icon.getRGB(icon.width - 1, icon.height - 1),
            )
            check(iconCorners.all { (it ushr 24) == 0xFF }) {
                "$density TV icon must fill the complete canvas with opaque pixels"
            }
        }

        val manifest = file("src/main/AndroidManifest.xml").readText()
        check("android:icon=\"@drawable/tv_launcher_icon\"" in manifest) {
            "AndroidManifest.xml must reference @drawable/tv_launcher_icon"
        }
        check("android:banner=\"@drawable/tv_banner\"" in manifest) {
            "AndroidManifest.xml must reference @drawable/tv_banner"
        }
    }
}

tasks.named("preBuild").configure {
    dependsOn(verifyTvArtwork)
}
