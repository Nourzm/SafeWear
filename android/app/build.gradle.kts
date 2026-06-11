plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.safewear"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.safewear"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion  // Required by record_android + flutter_blue_plus + Firebase Auth
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Provided by CI (decoded from the KEYSTORE_BASE64 secret).
            val ksPath = System.getenv("SAFEWEAR_KEYSTORE_PATH")
            if (ksPath != null) {
                storeFile = file(ksPath)
                storePassword = System.getenv("SAFEWEAR_KEYSTORE_PASSWORD")
                keyAlias = "safewear"
                keyPassword = System.getenv("SAFEWEAR_KEYSTORE_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            // Sign with the permanent release key when available (CI), so
            // every distributed APK can update in place. Falls back to debug
            // keys for local `flutter run --release`.
            signingConfig =
                if (System.getenv("SAFEWEAR_KEYSTORE_PATH") != null)
                    signingConfigs.getByName("release")
                else signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
