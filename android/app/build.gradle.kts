android {
    namespace = "com.example.zoya"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.zoya"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
