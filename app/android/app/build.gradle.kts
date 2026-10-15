import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 릴리스 서명 정보. key.properties 는 커밋하지 않으며 로컬 또는 CI(시크릿)에서 만든다.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

android {
    namespace = "com.coldredrice.passql"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications 가 요구하는 Java 8+ API 지원(desugaring). 꺼 두면 AAR 메타데이터 검사에서 빌드가 실패한다.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.coldredrice.passql"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystoreProperties.isNotEmpty()) {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // 릴리스는 항상 릴리스 키로 서명 (키가 없으면 아래 검사 작업이 빌드를 멈춤)
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

// 릴리스 서명 준비 여부: key.properties 와 그 storeFile(android/app 기준 경로)이 모두 있어야 함
val releaseKeystoreFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
val isReleaseKeystoreReady = releaseKeystoreFile?.exists() == true

// 릴리스 빌드(assemble/bundle Release) 시작 전 검사: 디버그 키로 조용히 서명된 산출물 차단
// 디버그 빌드는 이 작업을 거치지 않음. CI 는 android/key.properties(storeFile=keystore/key.jks)를 만든 뒤 빌드
val verifyReleaseKeystore by tasks.registering {
    doLast {
        if (!isReleaseKeystoreReady) {
            throw GradleException(
                "Release keystore missing: create android/key.properties " +
                    "(storeFile, storePassword, keyAlias, keyPassword) and the storeFile " +
                    "relative to android/app. Use a debug build for local runs."
            )
        }
    }
}
tasks.matching { it.name == "preReleaseBuild" }.configureEach {
    dependsOn(verifyReleaseKeystore)
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
