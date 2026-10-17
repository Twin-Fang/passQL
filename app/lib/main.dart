import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/ads/ad_consent.dart';
import 'core/auth/install_guard.dart';
import 'core/auth/token_store.dart';
import 'core/monitoring/firebase_analytics_backend.dart';
import 'core/monitoring/firebase_crash_reporter.dart';
import 'core/network/dio_client.dart';
import 'core/notification/app_icon_badge_updater.dart';
import 'core/push/firebase_push_messaging_client.dart';
import 'presentation/design/design.dart';
import 'presentation/providers/app_icon_badge_sync.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/monitoring_member_sync.dart';
import 'presentation/providers/push_notification_providers.dart';
import 'presentation/providers/theme_mode_provider.dart';
import 'router/app_launch_gate_routing.dart';
import 'router/app_router.dart';
import 'router/screen_view_tracker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  // 서버 주소 누락은 첫 요청이 아니라 시작 시점에 실패
  readBackendBaseUrl();
  // google-services.json / GoogleService-Info.plist 의 설정으로 초기화한다.
  await Firebase.initializeApp();
  startAppIconBadge();

  // 서로 무관한 시작 준비 병렬 실행 (SDK 설정 3종, 재설치 세션 정리, 화면 모드 읽기)
  // 재설치 정리는 아래 세션 읽기(authProvider)보다 먼저 끝나야 해서 여기서 함께 기다림
  final themeModeLoad = loadSavedThemeMode();
  await Future.wait<void>([
    startFirebaseCrashReporting(),
    startFirebaseAnalytics(),
    startFirebasePushMessaging(),
    resetSecureStorageOnFreshInstall(TokenStore()),
    themeModeLoad,
  ]);
  // 저장된 화면 모드로 첫 프레임부터 그림 (깜빡임 방지)
  final themeMode = await themeModeLoad;
  final container = ProviderContainer(
    overrides: [initialThemeModeProvider.overrideWithValue(themeMode)],
  );
  await container.read(authProvider.future);

  // 인증 상태가 바뀔 때마다 라우터에 알려 로그인/홈 화면 전환을 맡긴다.
  container.listen(authProvider, (_, next) {
    AppRouter.authenticated.value = next.valueOrNull != null;
  }, fireImmediately: true);
  syncMonitoringMemberWithAuth(container);
  trackScreenViews(AppRouter.router);
  startPushNotificationSync(container, AppRouter.router);
  startAppIconBadgeSync(container);

  // 앱 시작 설정 1회 조회 > 점검·강제 업데이트 차단 분기 (실패해도 진행, #464)
  await AppLaunchGateRouting.bindAndLoad(container);

  runApp(
    UncontrolledProviderScope(container: container, child: const PassqlApp()),
  );
  // iOS 추적 허용(ATT)은 첫 프레임 뒤 앱 시작 시 1회 질문 (광고 요청에만 묶으면 심사 2.1 리젝)
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => AdConsent.requestOnLaunch(),
  );
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
