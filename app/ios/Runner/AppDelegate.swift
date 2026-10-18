import Flutter
import NidThirdPartyLogin
import UIKit
import google_mobile_ads

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // 네이티브 광고 팩토리 2개 등록: 탭 바 아래 한 줄 띠(#527), 문제 탭 카드 (Dart NativeAd factoryId 가 이 이름을 찾음)
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      self,
      factoryId: PassqlStripNativeAdFactory.factoryId,
      nativeAdFactory: PassqlStripNativeAdFactory()
    )
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      self,
      factoryId: PassqlNativeAdFactory.factoryId,
      nativeAdFactory: PassqlNativeAdFactory()
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 네이버 앱 로그인 복귀 URL 먼저 처리, 그 외(카카오 등)는 플러그인 위임 (#509)
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if NidOAuth.shared.handleURL(url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }
}
