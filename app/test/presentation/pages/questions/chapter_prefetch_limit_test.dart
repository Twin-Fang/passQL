import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/billing/pro_purchase_port.dart';
import 'package:passql_app/core/error/app_exception.dart';
import 'package:passql_app/core/error/error_code.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/data/models/question/choice_item.dart';
import 'package:passql_app/data/models/question/choice_set_summary.dart';
import 'package:passql_app/data/models/question/question_detail.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/flows/question_flow.dart';
import 'package:passql_app/presentation/pages/questions/chapter_page.dart';
import 'package:passql_app/presentation/providers/chapter_providers.dart';
import 'package:passql_app/presentation/providers/plan_providers.dart';
import 'package:passql_app/presentation/providers/question_providers.dart';

import '../../../helpers/text_finders.dart';

// 문제 2개: 1번은 정상, 2번(미리 받기 대상)은 무료 하루 한도
const String _firstQuestionUuid = 'question-1';
const String _limitedQuestionUuid = 'question-2';
const String _dailyLimitReason = '오늘 무료 10문제를 다 풀었어요';
const String _sheetTitle = '회차 패스';

/// 고정 문제 2개를 푸는 흐름 (완료 처리 없음)
class _TwoQuestionFlow extends QuestionFlow {
  const _TwoQuestionFlow();

  @override
  String get id => 'prefetch-limit-test';

  @override
  String get title => '테스트 챕터';

  @override
  Future<List<String>> loadQuestionUuids(WidgetRef ref) async => const [
    _firstQuestionUuid,
    _limitedQuestionUuid,
  ];

  @override
  Future<void> onCompleted(
    BuildContext context,
    WidgetRef ref,
    ChapterSummary summary,
    String sessionUuid,
  ) async {}
}

/// 바로 쓸 수 있는 선택지 세트가 있는 문제 (SSE 생성 없음)
const QuestionDetail _firstQuestion = QuestionDetail(
  questionUuid: _firstQuestionUuid,
  stem: '첫 번째 문제',
  choiceSets: [
    ChoiceSetSummary(
      choiceSetUuid: 'choice-set-1',
      source: 'AI',
      status: 'OK',
      items: [
        ChoiceItem(key: 'A', kind: 'TEXT', body: '보기 A'),
        ChoiceItem(key: 'B', kind: 'TEXT', body: '보기 B'),
      ],
    ),
  ],
);

const AppException _dailyLimitError = AppException(
  code: ErrorCode.freeDailyLimitReached,
  message: '오늘 무료 10문제를 다 풀었어요.',
  statusCode: 403,
  serverCode: 'FREE_DAILY_LIMIT_REACHED',
);

/// 등급 고정 (결제 켜짐 + 무료)
class _FreePlanNotifier extends PlanNotifier {
  @override
  Future<MemberPlanResponse> build() async =>
      const MemberPlanResponse(isBillingEnabled: true, dailyFreeLimit: 10);

  @override
  Future<void> refresh() async {}
}

Widget _chapterApp() => ProviderScope(
  overrides: [
    planProvider.overrideWith(_FreePlanNotifier.new),
    shouldShowProUiProvider.overrideWith((ref) => true),
    proPurchasePortProvider.overrideWithValue(
      const UnavailableProPurchasePort(),
    ),
    questionDetailProvider.overrideWith((ref, questionUuid) async {
      if (questionUuid == _limitedQuestionUuid) throw _dailyLimitError;
      return _firstQuestion;
    }),
  ],
  child: MaterialApp(
    theme: PassqlTheme.light,
    home: const ChapterPage(flow: _TwoQuestionFlow()),
  ),
);

ChapterNotifier _chapterNotifierOf(WidgetTester tester) =>
    ProviderScope.containerOf(
      tester.element(find.byType(ChapterPage)),
    ).read(chapterProvider(const _TwoQuestionFlow().id).notifier);

void main() {
  testWidgets('prefetchLimitError_doesNotOpenSheetMidQuestion', (tester) async {
    await tester.pumpWidget(_chapterApp());
    await tester.pumpAndSettle();

    // 1번 문제 풀이 중 (보기 선택), 2번 미리 받기는 한도 오류
    expect(find.text('첫 번째 문제'), findsOneWidget);
    await tester.tap(find.text('보기 A'));
    await tester.pumpAndSettle();

    expect(find.text(_sheetTitle), findsNothing);
    expect(
      findTextContainingIgnoringWordJoiners(_dailyLimitReason),
      findsNothing,
    );
  });

  testWidgets('movingToNextAfterLimit_opensSheetWithReason', (tester) async {
    await tester.pumpWidget(_chapterApp());
    await tester.pumpAndSettle();
    expect(find.text(_sheetTitle), findsNothing);

    // 다음 문제로 이동 > 미리 받아 둔 한도 오류로 시트 + 이유 한 줄
    _chapterNotifierOf(tester).nextQuestion();
    await tester.pumpAndSettle();

    expect(find.text(_sheetTitle), findsWidgets);
    expect(
      findTextContainingIgnoringWordJoiners(_dailyLimitReason),
      findsOneWidget,
    );
  });
}
