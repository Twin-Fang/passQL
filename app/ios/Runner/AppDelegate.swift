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
    // 탭 바 아래 한 줄 광고 띠 네이티브 팩토리 등록 (#527)
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      self,
      factoryId: PassqlStripNativeAdFactory.factoryId,
      nativeAdFactory: PassqlStripNativeAdFactory()
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
