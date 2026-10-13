import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/pages/login/login_page.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';

class SignedOutAuth extends AuthNotifier {
  @override
  Future<AuthSession?> build() async => null;
}

Future<void> pumpLogin(WidgetTester tester, ThemeData theme) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authProvider.overrideWith(SignedOutAuth.new)],
      child: MaterialApp(theme: theme, home: const LoginPage()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('Google 버튼은 화면 55~80% 지점에 있고 약관 문구는 하단 inset 안에 있다', (
    tester,
  ) async {
    await pumpLogin(tester, PqTheme.light);

    final button = tester.getCenter(find.text('Google로 계속하기'));
    expect(button.dy / 844, inInclusiveRange(0.55, 0.80));

    final legal = tester.getRect(find.textContaining('동의').first);
    expect(legal.bottom, lessThanOrEqualTo(844 - 16));
  });

  testWidgets('다크 테마에서도 예외 없이 그려진다', (tester) async {
    await pumpLogin(tester, PqTheme.dark);

    expect(tester.takeException(), isNull);
    expect(find.text('Google로 계속하기'), findsOneWidget);
  });
}
