plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Thêm Google Services plugin (apply cho app module)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.attendify_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.attendify"
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

dependencies {
    // 👇 Import Firebase BoM để đồng bộ version
    implementation(platform("com.google.firebase:firebase-bom:34.1.0"))

    // 👇 Thêm Firebase Analytics (hoặc các SDK khác bạn cần)
    implementation("com.google.firebase:firebase-analytics")

    // Ví dụ: nếu dùng Firestore, thêm:
    // implementation("com.google.firebase:firebase-firestore")
    // Nếu dùng Auth:
    // implementation("com.google.firebase:firebase-auth")
}