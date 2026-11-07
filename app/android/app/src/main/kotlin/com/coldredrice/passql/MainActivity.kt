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
import com.navercorp.nid.oauth.NidOAuthBehavior

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
        registerNaverLoginBehaviorChannel(flutterEngine)
    }

    // 네이버 로그인 방식 바꾸기 채널 (#942): 네이버 앱 로그인이 실패한 기기에서 Chrome 로그인 화면으로 재시도
    // 값 2개: default(네이버 앱 우선), customTabs(Chrome 로그인 화면만)
    private fun registerNaverLoginBehaviorChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "passql/naver_login_behavior")
            .setMethodCallHandler { call, result ->
                if (call.method != "setBehavior") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                NaverIdLoginSDK.behavior = when (call.argument<String>("behavior")) {
                    "customTabs" -> NidOAuthBehavior.CUSTOMTABS
                    else -> NidOAuthBehavior.DEFAULT
                }
                result.success(null)
            }
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
}
