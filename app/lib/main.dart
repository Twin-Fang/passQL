import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/install_guard.dart';
import 'core/auth/token_store.dart';
import 'core/monitoring/firebase_analytics_backend.dart';
import 'core/monitoring/firebase_crash_reporter.dart';
import 'presentation/design/design.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/monitoring_member_sync.dart';
import 'presentation/providers/theme_mode_provider.dart';
import 'presentation/providers/session_reset.dart';
import 'router/app_launch_gate_routing.dart';
import 'router/app_router.dart';
import 'router/screen_view_tracker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  // google-services.json / GoogleService-Info.plist 의 설정으로 초기화한다.
  await Firebase.initializeApp();
  await startFirebaseCrashReporting();
  await startFirebaseAnalytics();

  // 앱 렌더링 전 저장된 로그인 세션을 읽어, 첫 화면이 깜빡이지 않게 한다.
  // 재설치 직후라면 키체인에 남은 이전 로그인을 지운 뒤 세션을 읽는다.
  await resetSecureStorageOnFreshInstall(TokenStore());
  // 저장된 화면 모드도 먼저 읽어, 첫 프레임부터 그 모드로 그린다.
  final themeMode = await loadSavedThemeMode();
  final container = ProviderContainer(
    overrides: [initialThemeModeProvider.overrideWithValue(themeMode)],
  );
  await container.read(authProvider.future);

  // 인증 상태가 바뀔 때마다 라우터에 알려 로그인/홈 화면 전환을 맡긴다.
  container.listen(authProvider, (prev, next) {
    AppRouter.authenticated.value = next.valueOrNull != null;

    // 로그아웃하거나 다른 계정으로 바뀌면 이전 사용자의 캐시를 비운다.
    final before = prev?.valueOrNull?.memberUuid;
    final after = next.valueOrNull?.memberUuid;
    if (prev != null && before != after) {
      resetUserScopedProviders(container.invalidate);
    }
  }, fireImmediately: true);
  syncMonitoringMemberWithAuth(container);
  trackScreenViews(AppRouter.router);

  // 앱 시작 설정 1회 조회 > 점검·강제 업데이트 차단 분기 (실패해도 진행, #464)
  await AppLaunchGateRouting.bindAndLoad(container);

  runApp(
    UncontrolledProviderScope(container: container, child: const PassqlApp()),
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
    );
  }
}
