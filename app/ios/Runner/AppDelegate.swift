import Flutter
import NidThirdPartyLogin
import UIKit
import google_mobile_ads

/// 앱 진입점 (UIScene 수명주기, 장면 대리자는 Info.plist 의 FlutterSceneDelegate)
/// 엔진 준비 > 플러그인 등록 > 네이티브 광고 팩토리 2개 > 네이버 로그인 복귀 URL 처리기 등록
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  // 네이버 복귀 URL 처리기 등록 이름 (플러그인 등록부에서 이 이름으로 장면 이벤트를 받음)
  private static let naverLoginUrlHandlerPluginKey = "PassqlNaverLoginUrlHandler"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    let pluginRegistry = engineBridge.pluginRegistry
    GeneratedPluginRegistrant.register(with: pluginRegistry)
    // 네이티브 광고 팩토리 2개 등록: 탭 바 아래 한 줄 띠(#527), 문제 탭 카드 (Dart NativeAd factoryId 가 이 이름을 찾음)
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      pluginRegistry,
      factoryId: PassqlStripNativeAdFactory.factoryId,
      nativeAdFactory: PassqlStripNativeAdFactory()
    )
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      pluginRegistry,
      factoryId: PassqlNativeAdFactory.factoryId,
      nativeAdFactory: PassqlNativeAdFactory()
    )
    // 장면 대리자가 URL 을 등록 순서대로 플러그인에 넘김 (카카오·Google 등은 자기 URL 만 처리하고 나머지는 넘김)
    pluginRegistry.registrar(forPlugin: Self.naverLoginUrlHandlerPluginKey)?
      .addSceneDelegate(NaverLoginUrlSceneHandler())
  }
}

/// 네이버 앱 로그인 복귀 URL(passqlnaver://) > 네이버 SDK (#509)
/// UIScene 에서는 앱 대리자 open url 이 불리지 않아 장면 이벤트(실행 중 복귀·URL 로 새로 실행)로 받음
private final class NaverLoginUrlSceneHandler: NSObject, FlutterSceneLifeCycleDelegate {
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
    return handleNaverLoginUrls(URLContexts)
  }

  // URL 로 새로 실행된 경우도 처리하되 연결 자체는 가로채지 않음 (false > 다른 플러그인도 받음)
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {
    if let urlContexts = connectionOptions?.urlContexts {
      _ = handleNaverLoginUrls(urlContexts)
    }
    return false
  }

  private func handleNaverLoginUrls(_ urlContexts: Set<UIOpenURLContext>) -> Bool {
    var isHandled = false
    for urlContext in urlContexts where NidOAuth.shared.handleURL(urlContext.url) {
      isHandled = true
    }
    return isHandled
  }
}
