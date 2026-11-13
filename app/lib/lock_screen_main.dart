import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_bootstrap.dart';
import 'core/monitoring/firebase_analytics_backend.dart';
import 'core/monitoring/firebase_crash_reporter.dart';
import 'core/utils/app_locale_settings.dart';
import 'presentation/design/design.dart';
import 'presentation/pages/lock_screen/lock_screen_page.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/lock_screen_providers.dart';
import 'presentation/providers/theme_mode_provider.dart';

/// 잠금화면 엔진 진입점 (#990, Android LockScreenEngine 이 서비스 시작 때 실행)
/// 공통 준비(.env·서버 주소·Firebase) > 오류·분석 수집 > 화면 모드 > 세션 복원 > 잠금화면 앱
/// 앱 로그 파일은 앱 엔진만 씀 (두 isolate 가 같은 파일을 회전시키지 않게)
@pragma('vm:entry-point')
Future<void> lockScreenMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await prepareAppEnvironment();
  final themeModeLoad = loadSavedThemeMode();
  await Future.wait<void>([
    startFirebaseCrashReporting(),
    startFirebaseAnalytics(),
    themeModeLoad,
  ]);
  final container = ProviderContainer(
    overrides: [
      initialThemeModeProvider.overrideWithValue(await themeModeLoad),
    ],
  );
  // 세션 복원 실패는 화면이 미로그인으로 보고 조용히 닫음
  await container.read(authProvider.future).catchError((Object _) => null);
  startLockScreenStatusSync(container);
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LockScreenApp(),
    ),
  );
}

/// 잠금화면 앱: 테마·글자 크기 상한만 앱과 같게, 화면은 잠금화면 문제 하나
class LockScreenApp extends ConsumerWidget {
  const LockScreenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'passQL',
      debugShowCheckedModeBanner: false,
      locale: AppLocaleSettings.locale,
      supportedLocales: AppLocaleSettings.supportedLocales,
      localizationsDelegates: AppLocaleSettings.localizationsDelegates,
      theme: PassqlTheme.light,
      darkTheme: PassqlTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      builder: (context, child) => PassqlTextScaleLimit.wrap(context, child),
      home: const LockScreenPage(),
    );
  }
}
