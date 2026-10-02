import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // 앱 렌더링 전 저장된 로그인 세션을 읽어, 첫 화면이 깜빡이지 않게 한다.
  final container = ProviderContainer();
  await container.read(authProvider.future);

  // 인증 상태가 바뀔 때마다 라우터에 알려 로그인/홈 화면 전환을 맡긴다.
  container.listen(authProvider, (_, next) {
    AppRouter.authenticated.value = next.valueOrNull != null;
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
