plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.admin_patitas"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Request Java 21 for source and target compatibility. Gradle/AGP and
        // the local JDK must support Java 21; if not installed, set JAVA_HOME
        // or install JDK 21 first.
        sourceCompatibility = JavaVersion.toVersion(21)
        targetCompatibility = JavaVersion.toVersion(21)
    }

    kotlinOptions {
        // Kotlin jvmTarget should match the Java language level. Requires a
        // recent Kotlin and toolchain that support targeting Java 21.
        jvmTarget = JavaVersion.toVersion(21).toString()
    }

    // Configure the Gradle Java toolchain to request a Java 21 launcher when
    // available. This helps Gradle pick the correct JDK independent of the
    // system JAVA_HOME. Note: Android Gradle Plugin may ignore the toolchain
    // for some tasks; installing JDK 21 and setting JAVA_HOME is recommended.
    java {
        toolchain {
            languageVersion.set(org.gradle.jvm.toolchain.JavaLanguageVersion.of(21))
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.admin_patitas"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
