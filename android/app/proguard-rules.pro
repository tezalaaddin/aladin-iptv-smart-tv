# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Isar
-keep class io.isar.** { *; }
-keep class * extends io.isar.IsarLink { *; }
-keep class * extends io.isar.IsarLinks { *; }

# Media3 / ExoPlayer
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**

# Glide
-keep public class * extends com.bumptech.glide.module.AppGlideModule
-keep public class * extends com.bumptech.glide.module.LibraryGlideModule
-keep class com.bumptech.glide.GeneratedAppGlideModuleImpl { *; }
-keep public enum com.bumptech.glide.load.ImageHeaderParser$** {
  **[] $VALUES;
  public *;
}

# Android TV Global Search
-keep class com.aladin.iptv.player.pro.AladinSearchProvider { *; }

# Flutter Play Store Split / Deferred Components (R8 Fix)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.gms.common.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# R8 Optimizations
-allowaccessmodification
-mergeinterfacesaggressively
