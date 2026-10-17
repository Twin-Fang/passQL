import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 릴리스 서명 정보. key.properties 는 커밋하지 않으며 로컬 또는 CI(시크릿)에서 만든다.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

// 빌드 시점 값(AdMob 앱 ID, 카카오 앱 키, 네이버 클라이언트)을 app/.env 에서 읽음 (커밋 제외 파일, 앱 런타임 .env 와 같은 원본)
// 매니페스트 meta-data·URL 스킴은 빌드 타임에 필요해 flutter_dotenv 로는 주입 불가 > manifestPlaceholders·resValue 로 전달
val envProperties = Properties().apply {
    val file = rootProject.file("../.env")
    if (file.exists()) file.reader(Charsets.UTF_8).use { load(it) }
}
fun envValue(key: String): String = envProperties.getProperty(key)?.trim() ?: ""

// AdMob 앱 ID 미설정 시 Google 테스트 앱 ID (비어 있으면 SDK 가 앱 시작 시 종료시킴)
val googleTestAdmobAndroidAppId = "ca-app-pub-3940256099942544~3347511713"

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

        // AndroidManifest.xml 의 ${admobAppId}
        manifestPlaceholders["admobAppId"] =
            envValue("PASSQL_ADMOB_ANDROID_APP_ID").ifEmpty { googleTestAdmobAndroidAppId }

        // 카카오 로그인 리다이렉트 스킴 kakao{네이티브 앱 키} (AndroidManifest.xml 의 ${kakaoNativeAppKey}, #509)
        manifestPlaceholders["kakaoNativeAppKey"] = envValue("KAKAO_NATIVE_APP_KEY")
        // 네이버 SDK 설정 3개 (매니페스트 meta-data 가 @string 으로 참조, 숫자처럼 보이는 값도 문자열 유지)
        resValue("string", "naver_client_id", envValue("NAVER_CLIENT_ID"))
        resValue("string", "naver_client_secret", envValue("NAVER_CLIENT_SECRET"))
        resValue("string", "naver_client_name", envValue("NAVER_CLIENT_NAME").ifEmpty { "passQL" })
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
