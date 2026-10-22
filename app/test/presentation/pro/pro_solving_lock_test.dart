import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passql_app/data/models/ai/choice_explanation.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/data/models/question/choice_item.dart';
import 'package:passql_app/data/models/question/locked_section_names.dart';
import 'package:passql_app/data/models/question/submit_result.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/pages/result/result_page.dart';
import 'package:passql_app/presentation/providers/question_providers.dart';
import 'package:passql_app/presentation/providers/random_practice_providers.dart';
import 'package:passql_app/presentation/widgets/pro/locked_preview_samples.dart';
import 'package:passql_app/router/result_route_arguments.dart';

import '../../helpers/fakes/fake_http_client_adapter.dart';
import '../../helpers/fakes/fake_pro_plan.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/text_finders.dart';

const _sql = 'SELECT ENAME FROM EMP';

/// 무료 제출 응답: 실행 결과·해설 본문을 뺀 채 판정만 (서버 ProResponseRedactor 모양)
const _freeSubmitResult = SubmitResult(
  isCorrect: false,
  correctKey: 'B',
  rationale: '정답은 B',
  submissionUuid: 'sub-1',
  choiceSetUuid: 'cs-1',
  structuredExplanation: ChoiceExplanation(
    selectedChoiceKey: 'A',
    correctChoiceKey: 'B',
    verdict: 'A는 오답, 정답은 B예요.',
  ),
  lockedSections: [
    LockedSectionNames.executionResult,
    LockedSectionNames.fullExplanation,
  ],
);

/// 요청 경로를 기록하는 가짜 서버 (/questions/random 만 목록 응답)
FakeHttpClientAdapter _recordingAdapter() => FakeHttpClientAdapter((options) {
  if (options.path == '/questions/random') {
    return jsonListResponseBody(200, [
      {'questionUuid': 'r-1'},
      {'questionUuid': 'r-2'},
    ]);
  }
  return jsonResponseBody(200, const {});
});

/// 채점 결과 화면 (경로 /questions/q-1/result 에서 questionUuid 를 읽음)
Future<FakeHttpClientAdapter> _pumpResult(
  WidgetTester tester,
  SubmitResult result,
  MemberPlanResponse plan,
) async {
  final adapter = _recordingAdapter();
  final container = await signedInPlanContainer(adapter: adapter, plan: plan);
  tester.view.physicalSize = const Size(400, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpApp(
    tester,
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: PassqlTheme.light,
        routerConfig: GoRouter(
          initialLocation: '/questions/q-1/result',
          routes: [
            GoRoute(
              path: '/questions/:questionUuid/result',
              builder: (_, _) => ResultPage(
                arguments: QuestionResultArguments(
                  result: result,
                  selectedChoiceKey: 'A',
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  await pumpUntilMotionDone(tester);
  return adapter;
}

void main() {
  group('채점 결과 화면', () {
    testWidgets('무료: 판정 선명, 해설·실행 결과 블러, 유사 문제 요청 없음', (tester) async {
      final adapter = await _pumpResult(tester, _freeSubmitResult, freePlan);

      expect(findTextContainingIgnoringWordJoiners('오답'), findsWidgets);
      expect(
        findTextContainingIgnoringWordJoiners(
          LockedPreviewCaptions.explanation,
        ),
        findsOneWidget,
      );
      expect(
        findTextContainingIgnoringWordJoiners(
          LockedPreviewCaptions.executionResult,
        ),
        findsOneWidget,
      );
      expect(
        adapter.requests.where(
          (request) => request.path.startsWith('/ai/similar/'),
        ),
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('billingDisabled_noChipNoBlur: 잠긴 묶음 없으면 블러 없음', (
      tester,
    ) async {
      final adapter = await _pumpResult(
        tester,
        _freeSubmitResult.copyWith(lockedSections: const []),
        billingOffPlan,
      );

      expect(find.byType(PassqlLockedPreview), findsNothing);
      expect(
        adapter.requests.where(
          (request) => request.path.startsWith('/ai/similar/'),
        ),
        isNotEmpty,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('문제 풀이 실행', () {
    Future<(QuestionInteractionNotifier, FakeHttpClientAdapter)> notifierFor(
      MemberPlanResponse plan,
    ) async {
      final adapter = _recordingAdapter();
      final container = await signedInPlanContainer(
        adapter: adapter,
        plan: plan,
      );
      container.listen(questionInteractionProvider('q-1'), (_, _) {});
      final notifier =
          container.read(questionInteractionProvider('q-1').notifier)
            ..useExistingChoiceSet('cs-1', const [
              ChoiceItem(key: 'A', kind: 'SQL', body: _sql),
            ]);
      return (notifier, adapter);
    }

    test('무료: 보기를 골라도 실행 요청 없이 잠금 표시', () async {
      final (notifier, adapter) = await notifierFor(freePlan);

      await notifier.selectChoice(
        choiceKey: 'A',
        sql: _sql,
        isExecutable: true,
      );

      expect(notifier.state.isExecutionLocked, isTrue);
      expect(notifier.state.isExecuting, isFalse);
      expect(
        adapter.requests.where((request) => request.path.endsWith('/execute')),
        isEmpty,
      );
    });

    test('결제 꺼짐: 지금처럼 바로 실행', () async {
      final (notifier, adapter) = await notifierFor(billingOffPlan);

      await notifier.selectChoice(
        choiceKey: 'A',
        sql: _sql,
        isExecutable: true,
      );

      expect(notifier.state.isExecutionLocked, isFalse);
      expect(
        adapter.requests.where((request) => request.path.endsWith('/execute')),
        hasLength(1),
      );
    });
  });

  test('랜덤 풀기: GET /questions/random?size=10 > 문제 UUID 목록', () async {
    final adapter = _recordingAdapter();
    final container = await signedInPlanContainer(
      adapter: adapter,
      plan: freePlan,
    );

    final questionUuids = await container
        .read(randomPracticeServiceProvider)
        .fetchQuestionUuids();

    expect(questionUuids, ['r-1', 'r-2']);
    expect(adapter.lastRequest.path, '/questions/random');
    expect(adapter.lastRequest.queryParameters['size'], 10);
  });
}
