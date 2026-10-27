import 'package:firebase_core/firebase_core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/ads/ad_consent.dart';
import 'core/auth/install_guard.dart';
import 'core/auth/token_store.dart';
import 'core/logging/app_log_file_store.dart';
import 'core/logging/app_log_lifecycle_observer.dart';
import 'core/logging/app_logger.dart';
import 'core/monitoring/firebase_analytics_backend.dart';
import 'core/monitoring/firebase_crash_reporter.dart';
import 'core/network/dio_client.dart';
import 'core/notification/app_icon_badge_updater.dart';
import 'core/push/firebase_push_messaging_client.dart';
import 'presentation/design/design.dart';
import 'presentation/providers/app_icon_badge_sync.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/monitoring_member_sync.dart';
import 'presentation/providers/onboarding_providers.dart';
import 'presentation/providers/pro_purchase_sync.dart';
import 'presentation/providers/push_notification_providers.dart';
import 'presentation/providers/theme_mode_provider.dart';
import 'router/app_launch_gate_routing.dart';
import 'router/app_router.dart';
import 'router/screen_view_tracker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 앱 로그 시작 (오류 훅 등록보다 먼저) > 시작 로그 + 생명주기 관찰
  await _startAppLogging();
  await dotenv.load(fileName: '.env');
  // 서버 주소 누락은 첫 요청이 아니라 시작 시점에 실패
  readBackendBaseUrl();
  // google-services.json / GoogleService-Info.plist 의 설정으로 초기화한다.
  await Firebase.initializeApp();
  startAppIconBadge();

  // 서로 무관한 시작 준비 병렬 실행 (SDK 설정 3종, 재설치 세션 정리, 화면 모드 읽기)
  // 재설치 정리는 아래 세션 읽기(authProvider)보다 먼저 끝나야 해서 여기서 함께 기다림
  final themeModeLoad = loadSavedThemeMode();
  final onboardingPendingLoad = loadOnboardingPending();
  await Future.wait<void>([
    startFirebaseCrashReporting(),
    startFirebaseAnalytics(),
    startFirebasePushMessaging(),
    resetSecureStorageOnFreshInstall(TokenStore()),
    themeModeLoad,
    onboardingPendingLoad,
  ]);
  // 저장된 화면 모드로 첫 프레임부터 그림 (깜빡임 방지)
  final themeMode = await themeModeLoad;
  final container = ProviderContainer(
    overrides: [
      initialThemeModeProvider.overrideWithValue(themeMode),
      // 온보딩 도중 앱이 꺼졌으면 첫 화면부터 온보딩으로 이어 감
      initialOnboardingPendingProvider.overrideWithValue(
        await onboardingPendingLoad,
      ),
      // 플랫폼별 결제 어댑터 (Android Play, iOS App Store)
      proPurchasePortOverride,
    ],
  );
  await container.read(authProvider.future);

  // 인증 상태가 바뀔 때마다 라우터에 알려 로그인/홈 화면 전환을 맡긴다.
  container.listen(authProvider, (_, next) {
    final isSignedIn = next.valueOrNull != null;
    // 세션이 끝나면(로그아웃·만료·이용 제한·탈퇴) 온보딩 대기도 지워 다음 계정이 물려받지 않게 한다.
    if (!isSignedIn) container.read(onboardingPendingProvider.notifier).clear();
    // 온보딩 신호를 로그인 신호보다 먼저 바꿔야 라우터가 로그인 직후 홈을 거치지 않는다.
    AppRouter.onboardingPending.value =
        isSignedIn && container.read(onboardingPendingProvider);
    AppRouter.authenticated.value = isSignedIn;
  }, fireImmediately: true);
  // 온보딩을 끝내거나 건너뛰면 라우터에 알린다.
  container.listen(onboardingPendingProvider, (_, isPending) {
    AppRouter.onboardingPending.value =
        isPending && AppRouter.authenticated.value;
  });
  syncMonitoringMemberWithAuth(container);
  trackScreenViews(AppRouter.router);
  startPushNotificationSync(container, AppRouter.router);
  startAppIconBadgeSync(container);
  startProPurchaseSync(container, AppRouter.router);

  // 앱 시작 설정 1회 조회 > 점검·강제 업데이트 차단 분기 (실패해도 진행, #464)
  await AppLaunchGateRouting.bindAndLoad(container);

  runApp(
    UncontrolledProviderScope(container: container, child: const PassqlApp()),
  );
  // iOS 추적 허용(ATT)은 첫 프레임 뒤 앱 시작 시 1회 질문 (광고 요청에만 묶으면 심사 2.1 리젝)
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => container.read(adConsentProvider).requestOnLaunch(),
  );
}

/// 로그 파일 저장소 연결 > "app start {version}+{build}" 기록 > 생명주기 관찰 등록
Future<void> _startAppLogging() async {
  // 로그는 부가 기능: 실패해도 앱 시작을 막지 않음
  try {
    final logDirectory = await getApplicationSupportDirectory();
    await AppLogger.start(AppLogFileStore(directory: logDirectory));
    final packageInfo = await PackageInfo.fromPlatform();
    AppLogger.info(
      'lifecycle',
      'app start ${packageInfo.version}+${packageInfo.buildNumber}',
    );
    WidgetsBinding.instance.addObserver(AppLogLifecycleObserver());
  } catch (_) {
    // 로그 시작 실패 무시
  }
}

class PassqlApp extends ConsumerWidget {
  const PassqlApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'passQL',
      debugShowCheckedModeBanner: false,
      theme: PassqlTheme.light,
      darkTheme: PassqlTheme.dark,
      // 설정 > 화면 모드에서 고른 값(기본: 시스템 설정 따르기).
      themeMode: ref.watch(themeModeProvider),
      routerConfig: AppRouter.router,
      // 시스템 글자 크기는 상한까지만 반영
      builder: PassqlTextScaleLimit.wrap,
    );
  }
}
