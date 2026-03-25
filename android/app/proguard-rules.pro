# Basic ProGuard rules for Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.editing.** { *; }


# SQLite
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# Sqflite
-keep class com.tekartik.sqflite.** { *; }

# OpenRouter API related
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class com.google.gson.stream.** { *; }

# HTTP and JSON related
-keep class com.squareup.okhttp.** { *; }
-keep interface com.squareup.okhttp.** { *; }
-dontwarn com.squareup.okhttp.**

-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

-keep class okio.** { *; }
-keep interface okio.** { *; }
-dontwarn okio.**

# Keep JSON classes
-keep class org.json.** { *; }
-dontwarn org.json.**

# Keep Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class androidx.security.crypto.** { *; }

# Keep HTTP related
-keep class javax.net.ssl.** { *; }
-dontwarn javax.net.ssl.**

# Keep Dart-specific classes
-keep class dart.** { *; }
-keep class io.flutter.dart.** { *; }

# Keep model classes
-keep class com.example.calendar_this.models.** { *; }
-keep class com.example.calendar_this.** { *; }
-keep class calendar_this.models.** { *; }
-keep class **.models.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep the R class and its fields
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Suppress optional Play Core task API references used by Flutter deferred components
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
