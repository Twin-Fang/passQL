import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/core/auth/social_credential.dart';
import 'package:passql_app/core/auth/social_sign_in.dart';
import 'package:passql_app/presentation/pages/login/login_page.dart';
import 'package:passql_app/presentation/pages/login/social_login_button.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/router/app_router.dart';

/// 라우터 전체를 올려 인증 가드와 로그인 화면 동작을 검증한다.
Widget _app({SocialSignIn socialSignIn = const UnconfiguredSocialSignIn()}) =>
    ProviderScope(
      // 저장된 세션이 없는 상태(첫 실행)로 시작한다.
      overrides: [
        authProvider.overrideWith(_SignedOutAuth.new),
        // 기본: 로그인 설정이 없는 상태(실제 SDK 는 테스트에서 쓰지 않는다).
        socialSignInProvider.overrideWithValue(socialSignIn),
      ],
      child: MaterialApp.router(routerConfig: AppRouter.router),
    );

/// 제공자 요청 기록 > 정해 둔 결과(null 이면 사용자 취소, 예외면 실패)
class _ScriptedSocialSignIn implements SocialSignIn {
  _ScriptedSocialSignIn({this.error});

  final SocialSignInException? error;
  final requestedProviders = <SocialProvider>[];

  @override
  Future<SocialCredential?> fetchCredential(SocialProvider provider) async {
    requestedProviders.add(provider);
    if (error != null) throw error!;
    return null;
  }

  @override
  Future<bool> revokeAccessForWithdrawal(
    SocialProvider? provider, {
    String? providerUserId,
  }) async => true;

  @override
  Future<void> disconnectAfterWithdrawal(SocialProvider? provider) async {}

  @override
  Future<void> signOut() async {}
}

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

  testWidgets('카카오·네이버·Google·GitHub 버튼을 같은 높이로 위에서부터 쌓는다', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    const labels = ['카카오로 계속하기', '네이버로 계속하기', 'Google로 계속하기', 'GitHub로 계속하기'];
    final buttonRects = [
      for (final label in labels)
        tester.getRect(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(SocialLoginButton),
          ),
        ),
    ];
    for (var index = 1; index < buttonRects.length; index++) {
      expect(
        buttonRects[index].height,
        moreOrLessEquals(buttonRects.first.height),
      );
      expect(
        buttonRects[index].top,
        greaterThan(buttonRects[index - 1].bottom),
      );
    }
  });

  testWidgets('소셜 로그인 버튼은 접근성 라벨을 한 번만 읽는다', (tester) async {
    final semanticsHandle = tester.ensureSemantics();
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    const labels = ['카카오로 계속하기', '네이버로 계속하기', 'Google로 계속하기', 'GitHub로 계속하기'];
    for (final label in labels) {
      final button = find.ancestor(
        of: find.text(label),
        matching: find.byType(SocialLoginButton),
      );
      expect(tester.getSemantics(button).label, label);
    }
    semanticsHandle.dispose();
  });

  testWidgets('사용자가 소셜 로그인을 취소하면 오류 문구 없이 로그인 화면에 머문다', (tester) async {
    final socialSignIn = _ScriptedSocialSignIn();
    await tester.pumpWidget(_app(socialSignIn: socialSignIn));
    await tester.pumpAndSettle();

    await tester.tap(find.text('카카오로 계속하기'));
    await tester.pumpAndSettle();

    expect(socialSignIn.requestedProviders, [SocialProvider.kakao]);
    expect(find.textContaining('실패'), findsNothing);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('설정 없는 제공자는 준비 중 안내를 보여 준다', (tester) async {
    final preparing = SocialSignInException.preparing();
    await tester.pumpWidget(
      _app(socialSignIn: _ScriptedSocialSignIn(error: preparing)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('GitHub로 계속하기'));
    await tester.pumpAndSettle();

    expect(find.text(preparing.message), findsOneWidget);
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
