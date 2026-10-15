import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/data/models/member/choice_generation_mode.dart';
import 'package:passql_app/data/models/progress/wrong_questions_response.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/pages/settings/settings_page.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/presentation/providers/settings_providers.dart';
import 'package:passql_app/presentation/providers/wrong_questions_provider.dart';

class SignedInAuth extends AuthNotifier {
  @override
  Future<AuthSession?> build() async => const AuthSession(
    accessToken: 'a',
    refreshToken: 'r',
    memberUuid: 'm-1',
    nickname: '기존닉네임',
  );
}

Future<void> pumpSettings(WidgetTester tester, ThemeData theme) async {
  // 목록이 길어 아래 행(회원 탈퇴)까지 한 번에 그려지도록 화면을 키운다.
  await tester.binding.setSurfaceSize(const Size(400, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authProvider.overrideWith(SignedInAuth.new),
        settingsDataProvider.overrideWith(
          (ref) async => const SettingsData(
            memberUuid: 'm-1',
            nickname: '기존닉네임',
            version: '1.0.0',
            choiceMode: ChoiceGenerationMode.practice,
          ),
        ),
        wrongQuestionsProvider.overrideWith(
          (ref) async => const WrongQuestionsResponse(totalCount: 3),
        ),
      ],
      child: MaterialApp(theme: theme, home: const SettingsPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('설정은 large title 바와 grouped 섹션으로 구성되고 회원 탈퇴는 오답색이다', (
    tester,
  ) async {
    await pumpSettings(tester, PassqlTheme.light);

    expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
    expect(find.byType(PassqlGroupedSection), findsAtLeastNWidgets(2));
    expect(
      tester.widget<Text>(find.text('회원 탈퇴')).style!.color,
      PassqlColors.light.wrong,
    );
  });

  testWidgets('다크 테마에서도 예외 없이 그려진다', (tester) async {
    await pumpSettings(tester, PassqlTheme.dark);

    expect(tester.takeException(), isNull);
    expect(find.byType(PassqlGroupedSection), findsAtLeastNWidgets(2));
  });
}
