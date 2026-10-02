import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/presentation/pages/login/login_page.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/router/app_router.dart';

/// 라우터 전체를 올려 인증 가드와 로그인 화면 동작을 검증한다.
Widget _app() => ProviderScope(
  // 저장된 세션이 없는 상태(첫 실행)로 시작한다.
  overrides: [authProvider.overrideWith(_SignedOutAuth.new)],
  child: ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, _) => MaterialApp.router(routerConfig: AppRouter.router),
  ),
);

class _SignedOutAuth extends AuthNotifier {
  @override
  Future<AuthSession?> build() async => null;
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    AppRouter.authenticated.value = false;
  });

  testWidgets('로그인 안 한 상태로 시작하면 홈이 아니라 로그인 화면이 뜬다', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Google로 계속하기'), findsOneWidget);
  });

  testWidgets('소셜 로그인 설정 전에는 Google 버튼이 안내 문구를 보여준다', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Google로 계속하기'));
    await tester.pumpAndSettle();

    expect(find.text('로그인 설정이 아직 완료되지 않았어요.'), findsOneWidget);
    // 실패해도 로그인 화면에 머문다.
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
