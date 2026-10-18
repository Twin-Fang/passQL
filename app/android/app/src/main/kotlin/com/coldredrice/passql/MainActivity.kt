package com.coldredrice.passql

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

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
