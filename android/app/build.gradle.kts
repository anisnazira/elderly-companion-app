plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")

    // Apply Firebase / Google Services plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.buddi"       
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
        applicationId = "com.example.buddi" // Must match Firebase package name
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM to manage versions automatically
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))

    // Firebase Analytics (example)
    implementation("com.google.firebase:firebase-analytics")

    // Add any other Firebase SDKs you want to use (BoM handles versions)
    // Examples:
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
    // implementation("com.google.firebase:firebase-storage")
}
