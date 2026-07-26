# Flutter, Isar, Media3 and Glide ship their own consumer rules. Avoid broad
# package-wide keep rules so R8 can shrink, optimize and obfuscate their code.
-dontwarn androidx.media3.**

# Glide
-keep public class * extends com.bumptech.glide.module.AppGlideModule
-keep public class * extends com.bumptech.glide.module.LibraryGlideModule
-keep class com.bumptech.glide.GeneratedAppGlideModuleImpl { *; }
-keep public enum com.bumptech.glide.load.ImageHeaderParser$** {
  **[] $VALUES;
  public *;
}

# Flutter Play Store Split / Deferred Components (R8 Fix)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.gms.common.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# proguard-android-optimize.txt already enables safe access modification and
# class merging; no duplicate global optimization flags are needed here.
