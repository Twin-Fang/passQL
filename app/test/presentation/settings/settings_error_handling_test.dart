import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/social_sign_in.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/pages/settings/settings_page.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/presentation/providers/app_config_providers.dart';
import 'package:passql_app/presentation/providers/settings_providers.dart';
import 'package:passql_app/presentation/providers/wrong_questions_provider.dart';

import '../../helpers/fakes/fake_member_api.dart';
import '../settings_layout_test.dart' show SignedInAuth;

/// 설정 화면: [settingsData] 가 null 이면 회원 API 실패로 그린다
Future<void> _pumpSettings(
  WidgetTester tester, {
  required FakeMemberApi memberApi,
  SettingsData? settingsData,
  AuthNotifier Function() authOverride = SignedInAuth.new,
}) async {
  await tester.binding.setSurfaceSize(const Size(400, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        memberApiProvider.overrideWithValue(memberApi),
        authProvider.overrideWith(authOverride),
        settingsDataProvider.overrideWith(
          (ref) async => settingsData ?? (throw Exception('members/me 실패')),
        ),
        currentAppVersionProvider.overrideWith((ref) async => '1.2.3'),
        wrongQuestionTotalCountProvider.overrideWith((ref) async => 0),
      ],
      child: MaterialApp(theme: PassqlTheme.light, home: const SettingsPage()),
    ),
  );
  await tester.pumpAndSettle();
}

/// 탈퇴 대역: 재인증 취소는 아무 일 없이 반환, 실패는 [SocialSignInException]
class _WithdrawAuth extends SignedInAuth {
  _WithdrawAuth({this.failureMessage});

  final String? failureMessage;

  @override
  Future<void> withdraw() async {
    if (failureMessage != null) throw SocialSignInException(failureMessage!);
  }
}

Future<void> _tapWithdrawAndConfirm(WidgetTester tester) async {
  await tester.tap(find.text('회원 탈퇴'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('탈퇴하기'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('회원 정보를 못 불러와도 버전 행은 보인다 (#484)', (tester) async {
    await _pumpSettings(tester, memberApi: FakeMemberApi());

    expect(find.text('버전'), findsOneWidget);
    expect(find.text('1.2.3'), findsOneWidget);
  });

  testWidgets('탈퇴 재인증을 취소하면 잠금 스피너가 닫히고 계정은 그대로다 (#547)', (tester) async {
    await _pumpSettings(
      tester,
      memberApi: FakeMemberApi(),
      authOverride: _WithdrawAuth.new,
    );

    await _tapWithdrawAndConfirm(tester);

    expect(find.byType(PassqlLoadingIndicator), findsNothing);
    expect(find.text('회원 탈퇴'), findsOneWidget);
  });

  testWidgets('탈퇴에 실패하면 잠금 스피너가 닫히고 사유를 토스트로 알린다 (#547)', (tester) async {
    await _pumpSettings(
      tester,
      memberApi: FakeMemberApi(),
      authOverride: () => _WithdrawAuth(failureMessage: '탈퇴 계정이 달라요'),
    );

    await _tapWithdrawAndConfirm(tester);

    expect(find.byType(PassqlLoadingIndicator), findsNothing);
    expect(find.text('탈퇴 계정이 달라요'), findsOneWidget);
  });
}
