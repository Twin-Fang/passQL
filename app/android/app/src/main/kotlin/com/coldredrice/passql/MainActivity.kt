package com.coldredrice.passql

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.res.Configuration
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.os.SystemClock
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import com.navercorp.nid.NaverIdLoginSDK
import com.navercorp.nid.NidOAuth
import com.navercorp.nid.oauth.domain.`enum`.NidOAuthBehavior
import com.navercorp.nid.oauth.util.NidOAuthCallback

// 네이버 로그인 플러그인이 FlutterFragmentActivity 를 요구 (ActivityResult 등록, #509)
class MainActivity : FlutterFragmentActivity() {
    // 네이버 로그인 진단 (#942): 로그인 중 화면 구성 변경(폴더블 접기·펴기, 창 크기) 기록
    private var naverLoginConfigChanges = mutableListOf<String>()
    private var isNaverLoginInProgress = false

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        if (isNaverLoginInProgress) naverLoginConfigChanges.add(describeWindow(newConfig))
    }

    /** 화면 구성 요약: 가로x세로dp, 방향 */
    private fun describeWindow(config: Configuration): String =
        "${config.screenWidthDp}x${config.screenHeightDp}dp " +
            if (config.orientation == Configuration.ORIENTATION_LANDSCAPE) "landscape" else "portrait"
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createDefaultNotificationChannel()
    }

    // 네이티브 광고 팩토리 2개 등록 (엔진 수명과 함께): 탭 바 아래 한 줄 띠(#527), 문제 탭 카드 (Dart NativeAd factoryId 가 이 이름을 찾음)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            PassqlStripNativeAdFactory.FACTORY_ID,
            PassqlStripNativeAdFactory(this),
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            PassqlNativeAdFactory.FACTORY_ID,
            PassqlNativeAdFactory(this),
        )
        registerRingerModeChannel(flutterEngine)
        registerNaverLoginChannel(flutterEngine)
    }

    // 소리 모드 조회 채널 (의견 진단 정보, #708): normal, vibrate, silent
    private fun registerRingerModeChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "passql/ringer_mode")
            .setMethodCallHandler { call, result ->
                if (call.method != "getRingerMode") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val audioManager = getSystemService(AUDIO_SERVICE) as? AudioManager
                result.success(
                    when (audioManager?.ringerMode) {
                        AudioManager.RINGER_MODE_SILENT -> "silent"
                        AudioManager.RINGER_MODE_VIBRATE -> "vibrate"
                        AudioManager.RINGER_MODE_NORMAL -> "normal"
                        else -> null
                    },
                )
            }
    }

    // 네이버 로그인 채널 (#942): flutter_naver_login 2.1.1 은 SDK 5.10 전용이라 Android 로그인만 SDK 5.12 를 직접 부름
    // 메서드 3개: login(behavior: default 네이버 앱 우선 | customTabs Chrome 로그인 화면), logout, deleteToken(연동 해제)
    private fun registerNaverLoginChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "passql/naver_login")
            .setMethodCallHandler { call, result ->
                if (!ensureNaverSdkInitialized()) {
                    result.error(NAVER_ERROR_NOT_INITIALIZED, "naver sdk not initialized", null)
                    return@setMethodCallHandler
                }
                when (call.method) {
                    "login" -> logInWithNaver(
                        call.argument<String>("behavior"),
                        call.argument<Boolean>("isDeveloperLog") == true,
                        result,
                    )
                    "logout" -> NaverIdLoginSDK.logout(replyOnce(result))
                    "deleteToken" -> NidOAuth.disconnect(replyOnce(result))
                    else -> result.notImplemented()
                }
            }
    }

    /** 로그인 방식 지정 > SDK 로그인 > 성공이면 액세스 토큰, 실패면 SDK 오류 코드·설명 (둘 다 진단 정보 포함) */
    private fun logInWithNaver(behavior: String?, isDeveloperLog: Boolean, result: MethodChannel.Result) {
        NaverIdLoginSDK.showDevelopersLog(isDeveloperLog)
        NaverIdLoginSDK.behavior =
            if (behavior == "customTabs") NidOAuthBehavior.CUSTOMTABS else NidOAuthBehavior.DEFAULT
        naverLoginConfigChanges = mutableListOf()
        isNaverLoginInProgress = true
        val startedAt = SystemClock.elapsedRealtime()
        val startWindow = describeWindow(resources.configuration)

        // 진단 정보 (로그용, 토큰·개인정보 없음)
        fun diagnostics(): Map<String, Any?> = mapOf(
            "sdkVersion" to NaverIdLoginSDK.getVersion(),
            "behavior" to (behavior ?: "default"),
            "isNaverAppInstalled" to isPackageInstalled(NAVER_APP_PACKAGE),
            "elapsedMs" to (SystemClock.elapsedRealtime() - startedAt),
            "startWindow" to startWindow,
            "configChanges" to naverLoginConfigChanges.joinToString(" > ").ifEmpty { "none" },
            "isInMultiWindow" to (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && isInMultiWindowMode),
        )

        NaverIdLoginSDK.authenticate(this, object : NidOAuthCallback {
            override fun onSuccess() {
                isNaverLoginInProgress = false
                result.success(mapOf("accessToken" to NaverIdLoginSDK.getAccessToken(), "diagnostics" to diagnostics()))
            }

            override fun onFailure(errorCode: String, errorDescription: String) {
                isNaverLoginInProgress = false
                result.error(
                    NAVER_ERROR_LOGIN_FAILED,
                    errorDescription,
                    mapOf(
                        "errorCode" to NaverIdLoginSDK.getLastErrorCode().code,
                        "errorDescription" to NaverIdLoginSDK.getLastErrorDescription(),
                        "callbackErrorCode" to errorCode,
                        "diagnostics" to diagnostics(),
                    ),
                )
            }
        })
    }

    /** 앱 설치 여부 (네이버 앱 로그인 경로 판단용, 매니페스트 queries 에 등록된 패키지만 보임) */
    private fun isPackageInstalled(packageName: String): Boolean = try {
        packageManager.getPackageInfo(packageName, 0)
        true
    } catch (_: Exception) {
        false
    }

    /** 로그아웃·연동 해제 응답 (실패도 성공으로 돌려 앱 흐름은 계속, 원인은 Dart 로그) */
    private fun replyOnce(result: MethodChannel.Result) = object : NidOAuthCallback {
        override fun onSuccess() = result.success(null)
        override fun onFailure(errorCode: String, errorDescription: String) =
            result.success(mapOf("errorCode" to errorCode, "errorDescription" to errorDescription))
    }

    /** SDK 초기화 확인 (플러그인이 앱 시작 때 초기화, 안 됐으면 빌드 리소스 값으로 직접) */
    private fun ensureNaverSdkInitialized(): Boolean {
        if (NaverIdLoginSDK.isInitialized()) return true
        val clientId = getString(R.string.naver_client_id)
        if (clientId.isEmpty()) return false
        NaverIdLoginSDK.initialize(
            applicationContext,
            clientId,
            getString(R.string.naver_client_secret),
            getString(R.string.naver_client_name),
        )
        return NaverIdLoginSDK.isInitialized()
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, PassqlStripNativeAdFactory.FACTORY_ID)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, PassqlNativeAdFactory.FACTORY_ID)
        super.cleanUpFlutterEngine(flutterEngine)
    }

    // 푸시 기본 채널 생성 (Android 8+ 필수, 이미 있으면 무시됨)
    private fun createDefaultNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            getString(R.string.default_notification_channel_id),
            getString(R.string.default_notification_channel_name),
            NotificationManager.IMPORTANCE_HIGH,
        )
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    companion object {
        // 네이버 로그인 채널 오류 코드 (Dart naver_social_sign_in.dart 와 같은 값)
        private const val NAVER_ERROR_LOGIN_FAILED = "naver_login_failed"
        private const val NAVER_ERROR_NOT_INITIALIZED = "naver_not_initialized"
        // 네이버 앱 패키지 (앱 로그인 경로)
        private const val NAVER_APP_PACKAGE = "com.nhn.android.search"
    }
}
