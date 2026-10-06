pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    // Firebase Android SDK 가 코틀린 2.3 메타데이터로 빌드되어, 컴파일러가 이를 읽을 수 있는 2.2 이상이 필요하다.
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    // google-services.json 을 읽어 Firebase/구글 로그인 설정을 앱에 주입한다.
    id("com.google.gms.google-services") version "4.4.2" apply false
}

include(":app")
