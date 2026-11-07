package com.coldredrice.passql

import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
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
                    "login" -> logInWithNaver(call.argument<String>("behavior"), result)
                    "logout" -> NaverIdLoginSDK.logout(replyOnce(result))
                    "deleteToken" -> NidOAuth.disconnect(replyOnce(result))
                    else -> result.notImplemented()
                }
            }
    }

    /** 로그인 방식 지정 > SDK 로그인 > 성공이면 액세스 토큰, 실패면 SDK 오류 코드·설명 */
    private fun logInWithNaver(behavior: String?, result: MethodChannel.Result) {
        NaverIdLoginSDK.behavior =
            if (behavior == "customTabs") NidOAuthBehavior.CUSTOMTABS else NidOAuthBehavior.DEFAULT
        NaverIdLoginSDK.authenticate(this, object : NidOAuthCallback {
            override fun onSuccess() {
                result.success(mapOf("accessToken" to NaverIdLoginSDK.getAccessToken()))
            }

            override fun onFailure(errorCode: String, errorDescription: String) {
                result.error(
                    NAVER_ERROR_LOGIN_FAILED,
                    errorDescription,
                    mapOf(
                        "errorCode" to NaverIdLoginSDK.getLastErrorCode().code,
                        "errorDescription" to NaverIdLoginSDK.getLastErrorDescription(),
                    ),
                )
            }
        })
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
    }
}
