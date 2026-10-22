import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passql_app/core/error/app_exception.dart';
import 'package:passql_app/core/error/error_code.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/core/billing/pro_purchase_port.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/data/models/member/choice_generation_mode.dart';
import 'package:passql_app/data/models/progress/wrong_questions_response.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/presentation/providers/plan_providers.dart';
import 'package:passql_app/presentation/providers/settings_providers.dart';
import 'package:passql_app/presentation/providers/wrong_questions_provider.dart';
import 'package:passql_app/presentation/widgets/pro/locked_preview_samples.dart';
import 'package:passql_app/presentation/widgets/settings/choice_mode_tile.dart';
import 'package:passql_app/presentation/widgets/settings/nickname_edit_sheet.dart';
import 'package:passql_app/presentation/widgets/settings/wrong_notes_section.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../helpers/fakes/fake_member_api.dart';
import '../../helpers/pump_app.dart';

class _SignedInAuth extends AuthNotifier {
  @override
  Future<AuthSession?> build() async => const AuthSession(
    accessToken: 'a',
    refreshToken: 'r',
    memberUuid: 'm-1',
    nickname: '기존닉네임',
  );
}

/// 시트 안 PassqlButton 을 라벨로 찾는다(버튼 종류가 바뀌어도 활성 여부만 본다).
PassqlButton _button(WidgetTester tester, String label) =>
    tester.widget<PassqlButton>(find.widgetWithText(PassqlButton, label));

DioException _serverError(int status, String code, String message) {
  final opts = RequestOptions(path: '/x');
  return DioException(
    requestOptions: opts,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: opts,
      statusCode: status,
      data: {'errorCode': code, 'message': message},
    ),
  );
}

ProviderContainer _container(
  FakeMemberApi api, {
  ChoiceGenerationMode mode = ChoiceGenerationMode.practice,
}) {
  final container = ProviderContainer(
    overrides: [
      memberApiProvider.overrideWithValue(api),
      authProvider.overrideWith(_SignedInAuth.new),
      settingsDataProvider.overrideWith(
        (ref) async => SettingsData(
          memberUuid: 'm-1',
          nickname: '기존닉네임',
          choiceMode: mode,
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  setUp(() {
    // 닉네임 변경은 로그인 세션(보안 저장소)에 반영되므로 테스트용 저장소를 쓴다.
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('닉네임 Notifier', () {
    test('변경에 성공하면 닉네임 상태와 로그인 세션을 새 닉네임으로 바꾼다', () async {
      final api = FakeMemberApi();
      final container = _container(api);
      await container.read(nicknameNotifierProvider.future);

      await container.read(nicknameNotifierProvider.notifier).change('새닉네임');

      expect(container.read(authProvider).value?.nickname, '새닉네임');
      // 닉네임 상태는 세션을 따라가므로 갱신이 반영될 때까지 기다린다.
      expect(await container.read(nicknameNotifierProvider.future), '새닉네임');
    });

    test('서버가 쿨다운으로 거절하면 서버 문구를 담은 AppException 을 던지고 상태는 유지한다', () async {
      final api = FakeMemberApi(
        changeNicknameError: _serverError(
          400,
          'NICKNAME_COOLDOWN',
          '변경 후 3일간 바꿀 수 없어요',
        ),
      );
      final container = _container(api);
      await container.read(nicknameNotifierProvider.future);

      await expectLater(
        container.read(nicknameNotifierProvider.notifier).change('새닉네임'),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', ErrorCode.nicknameCooldown)
              .having((e) => e.message, 'message', '변경 후 3일간 바꿀 수 없어요'),
        ),
      );
      expect(container.read(nicknameNotifierProvider).value, '기존닉네임');
    });
  });

  group('선택지 생성 모드', () {
    test('토글은 먼저 화면 상태를 바꾸고 서버에 저장한다', () async {
      final api = FakeMemberApi();
      final container = _container(api);
      await container.read(choiceModeProvider.future);

      await container
          .read(choiceModeProvider.notifier)
          .setMode(ChoiceGenerationMode.real);

      expect(
        container.read(choiceModeProvider).value,
        ChoiceGenerationMode.real,
      );
      expect(api.calls, ['mode:REAL']);
    });

    test('저장에 실패하면 이전 값으로 되돌리고 오류를 알린다', () async {
      final api = FakeMemberApi(
        choiceModeError: _serverError(500, 'INTERNAL_SERVER_ERROR', 'x'),
      );
      final container = _container(api);
      await container.read(choiceModeProvider.future);

      await expectLater(
        container
            .read(choiceModeProvider.notifier)
            .setMode(ChoiceGenerationMode.real),
        throwsA(isA<AppException>()),
      );
      expect(
        container.read(choiceModeProvider).value,
        ChoiceGenerationMode.practice,
      );
    });

    test('같은 값으로 바꾸면 서버를 호출하지 않는다', () async {
      final api = FakeMemberApi();
      final container = _container(api);
      await container.read(choiceModeProvider.future);

      await container
          .read(choiceModeProvider.notifier)
          .setMode(ChoiceGenerationMode.practice);

      expect(api.calls, isEmpty);
    });
  });

  group('닉네임 변경 시트', () {
    Future<void> openSheet(
      WidgetTester tester,
      FakeMemberApi api,
      ValueNotifier<bool?> result,
    ) async {
      await pumpApp(
        tester,
        ProviderScope(
          overrides: [
            memberApiProvider.overrideWithValue(api),
            authProvider.overrideWith(_SignedInAuth.new),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async => result.value =
                      await NicknameEditSheet.show(context, '기존닉네임'),
                  child: const Text('열기'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
    }

    testWidgets('형식이 틀리면 안내하고 중복확인·저장을 막는다', (tester) async {
      await openSheet(tester, FakeMemberApi(), ValueNotifier(null));

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump();

      expect(find.textContaining('2~10자'), findsWidgets);
      expect(_button(tester, '중복확인').onPressed, isNull);
      expect(_button(tester, '저장').onPressed, isNull);
    });

    testWidgets('중복확인을 통과해야 저장할 수 있고, 저장하면 닫히며 true 를 돌려준다', (tester) async {
      final api = FakeMemberApi();
      final result = ValueNotifier<bool?>(null);
      await openSheet(tester, api, result);

      await tester.enterText(find.byType(TextField), '새닉네임');
      await tester.pump();
      // 확인 전에는 저장 불가
      expect(_button(tester, '저장').onPressed, isNull);

      await tester.tap(find.text('중복확인'));
      await tester.pumpAndSettle();
      expect(find.text('사용 가능한 닉네임이에요'), findsOneWidget);

      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      expect(api.calls, ['check:새닉네임', 'change:새닉네임']);
      expect(result.value, isTrue);
      expect(find.byType(NicknameEditSheet), findsNothing);
    });

    testWidgets('이미 쓰는 닉네임이면 저장할 수 없다', (tester) async {
      await openSheet(
        tester,
        FakeMemberApi(isNicknameAvailable: false),
        ValueNotifier(null),
      );

      await tester.enterText(find.byType(TextField), '남의닉네임');
      await tester.pump();
      await tester.tap(find.text('중복확인'));
      await tester.pumpAndSettle();

      expect(find.text('이미 사용 중인 닉네임이에요'), findsOneWidget);
      expect(_button(tester, '저장').onPressed, isNull);
    });

    testWidgets('확인 뒤 글자를 바꾸면 다시 확인해야 한다', (tester) async {
      await openSheet(tester, FakeMemberApi(), ValueNotifier(null));

      await tester.enterText(find.byType(TextField), '새닉네임');
      await tester.pump();
      await tester.tap(find.text('중복확인'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '새닉네임2');
      await tester.pump();

      expect(_button(tester, '저장').onPressed, isNull);
    });

    testWidgets('서버가 쿨다운으로 거절하면 사유를 보여주고 시트를 유지한다', (tester) async {
      final api = FakeMemberApi(
        changeNicknameError: _serverError(
          400,
          'NICKNAME_COOLDOWN',
          '변경 후 3일간 바꿀 수 없어요',
        ),
      );
      final result = ValueNotifier<bool?>(null);
      await openSheet(tester, api, result);

      await tester.enterText(find.byType(TextField), '새닉네임');
      await tester.pump();
      await tester.tap(find.text('중복확인'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      expect(find.text('변경 후 3일간 바꿀 수 없어요'), findsWidgets);
      expect(find.byType(NicknameEditSheet), findsOneWidget);
      expect(result.value, isNull);
    });
  });

  group('오답 노트 섹션', () {
    Widget host(
      Override override, {
      Widget child = const WrongNotesSection(),
    }) => ProviderScope(
      overrides: [override],
      child: MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

    testWidgets('오답이 있으면 개수와 목록을 보여준다', (tester) async {
      await pumpApp(
        tester,
        host(
          wrongQuestionsProvider.overrideWith(
            (ref) async => const WrongQuestionsResponse(
              totalCount: 2,
              items: [
                WrongQuestionItem(
                  questionUuid: 'q1',
                  stemPreview: '첫 번째 문제',
                  topicName: 'SQL 기본',
                ),
                WrongQuestionItem(questionUuid: 'q2', stemPreview: '두 번째 문제'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('오답 노트'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('첫 번째 문제'), findsOneWidget);
      expect(find.text('SQL 기본'), findsOneWidget);
      expect(find.text('두 번째 문제'), findsOneWidget);
    });

    testWidgets('오답이 없으면 안내 문구를 보여준다', (tester) async {
      await pumpApp(
        tester,
        host(
          wrongQuestionsProvider.overrideWith(
            (ref) async => const WrongQuestionsResponse(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('아직 틀린 문제가 없어요'), findsOneWidget);
    });

    testWidgets('실패하면 사유와 다시 시도를 보여주고, 다시 시도하면 목록을 불러온다', (tester) async {
      var attempts = 0;
      await pumpApp(
        tester,
        host(
          wrongQuestionsProvider.overrideWith((ref) async {
            attempts++;
            if (attempts == 1) {
              throw DioException(
                requestOptions: RequestOptions(path: '/x'),
                type: DioExceptionType.connectionError,
              );
            }
            return const WrongQuestionsResponse(
              totalCount: 1,
              items: [
                WrongQuestionItem(questionUuid: 'q1', stemPreview: '복구된 문제'),
              ],
            );
          }),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('네트워크 연결을 확인해 주세요.'), findsOneWidget);

      await tester.tap(find.text('다시 시도'));
      await tester.pumpAndSettle();

      expect(find.text('복구된 문제'), findsOneWidget);
    });

    testWidgets('항목을 누르면 해당 문제로 이동한다', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: WrongNotesSection()),
          ),
          GoRoute(
            path: '/questions/:id',
            builder: (_, state) => Text('문제 ${state.pathParameters['id']}'),
          ),
        ],
      );
      await pumpApp(
        tester,
        ProviderScope(
          overrides: [
            wrongQuestionsProvider.overrideWith(
              (ref) async => const WrongQuestionsResponse(
                totalCount: 1,
                items: [
                  WrongQuestionItem(questionUuid: 'abc', stemPreview: '이동할 문제'),
                ],
              ),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('이동할 문제'));
      await tester.pumpAndSettle();

      expect(find.text('문제 abc'), findsOneWidget);
    });
  });

  testWidgets('선택지 모드 토글이 켜면 실전 문구로 바뀐다', (tester) async {
    final api = FakeMemberApi();
    await pumpApp(
      tester,
      ProviderScope(
        overrides: [
          memberApiProvider.overrideWithValue(api),
          settingsDataProvider.overrideWith(
            (ref) async => const SettingsData(
              memberUuid: 'm',
              nickname: 'n',
              choiceMode: ChoiceGenerationMode.practice,
            ),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: ChoiceModeTile())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('검증된 선택지를 먼저'), findsOneWidget);

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();

    expect(find.textContaining('매번 AI가'), findsOneWidget);
    expect(api.calls, ['mode:REAL']);
  });

  testWidgets('무료(결제 켜짐)면 저장값이 실전이어도 연습으로 보이고 실전 모드는 잠금 자리로 보인다', (
    tester,
  ) async {
    final api = FakeMemberApi();
    await pumpApp(
      tester,
      ProviderScope(
        overrides: [
          memberApiProvider.overrideWithValue(api),
          shouldShowProUiProvider.overrideWith((ref) => true),
          proPurchasePortProvider.overrideWithValue(
            const UnavailableProPurchasePort(),
          ),
          settingsDataProvider.overrideWith(
            (ref) async => const SettingsData(
              memberUuid: 'm',
              nickname: 'n',
              choiceMode: ChoiceGenerationMode.real,
            ),
          ),
        ],
        child: MaterialApp(
          theme: PassqlTheme.light,
          home: const Scaffold(
            body: SingleChildScrollView(child: ChoiceModeTile()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 실효 모드(연습) 표시 + 실전 모드 블러 자리
    expect(
      tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch)).value,
      isFalse,
    );
    expect(find.textContaining('검증된 선택지를 먼저'), findsOneWidget);
    expect(find.byType(PassqlLockedPreview), findsOneWidget);
    expect(find.text(LockedPreviewCaptions.realModeSetting), findsWidgets);

    // 스위치 켜기 > 변경 요청 없이 프로 안내 시트
    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();
    expect(api.calls, isEmpty);
    expect(find.text('이미 구매했나요? 복원하기'), findsOneWidget);
  });
}
