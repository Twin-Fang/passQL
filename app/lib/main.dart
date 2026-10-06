import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/app_theme.dart';
import 'core/auth/install_guard.dart';
import 'core/auth/token_store.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/session_reset.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  // google-services.json / GoogleService-Info.plist 의 설정으로 초기화한다.
  await Firebase.initializeApp();

  // 앱 렌더링 전 저장된 로그인 세션을 읽어, 첫 화면이 깜빡이지 않게 한다.
  // 재설치 직후라면 키체인에 남은 이전 로그인을 지운 뒤 세션을 읽는다.
  await resetSecureStorageOnFreshInstall(TokenStore());
  final container = ProviderContainer();
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

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PassqlApp(),
    ),
  );
}

class PassqlApp extends StatelessWidget {
  const PassqlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // iPhone 15 기준 디자인 사이즈
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp.router(
        title: 'passQL',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
