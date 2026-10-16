import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/member/choice_generation_mode.dart';
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
}) async {
  await tester.binding.setSurfaceSize(const Size(400, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        memberApiProvider.overrideWithValue(memberApi),
        authProvider.overrideWith(SignedInAuth.new),
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

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('회원 정보를 못 불러와도 버전 행은 보인다 (#484)', (tester) async {
    await _pumpSettings(tester, memberApi: FakeMemberApi());

    expect(find.text('버전'), findsOneWidget);
    expect(find.text('1.2.3'), findsOneWidget);
  });

  testWidgets('닉네임 재생성에 실패하면 사유를 토스트로 알리고 닉네임은 그대로 둔다 (#484)', (tester) async {
    final requestOptions = RequestOptions(
      path: '/members/me/nickname/regenerate',
    );
    final memberApi = FakeMemberApi(
      regenerateNicknameError: DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
      ),
    );
    await _pumpSettings(
      tester,
      memberApi: memberApi,
      settingsData: const SettingsData(
        memberUuid: 'm-1',
        nickname: '기존닉네임',
        choiceMode: ChoiceGenerationMode.practice,
      ),
    );

    await tester.tap(find.byIcon(CupertinoIcons.arrow_clockwise));
    await tester.pumpAndSettle();

    expect(memberApi.calls, contains('regenerate'));
    expect(find.text('네트워크 연결을 확인해 주세요.'), findsOneWidget);
    expect(find.text('기존닉네임'), findsOneWidget);
  });
}
