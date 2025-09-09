# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Stone SDK rules
-keep class br.com.stone.** { *; }
-keep class stone.** { *; }
-dontwarn br.com.stone.**
-dontwarn stone.**

# Logback and SLF4J rules
-keep class ch.qos.logback.** { *; }
-keep class org.slf4j.** { *; }
-dontwarn ch.qos.logback.**
-dontwarn org.slf4j.**

# JDK internal classes - ignore missing classes
-dontwarn jdk.internal.**
-dontwarn sun.misc.**
-dontwarn java.lang.invoke.**

# Concurrent HashMap rules
-keep class j$.util.concurrent.** { *; }
-dontwarn j$.util.concurrent.**

# Kotlin coroutines
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# General Android rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider