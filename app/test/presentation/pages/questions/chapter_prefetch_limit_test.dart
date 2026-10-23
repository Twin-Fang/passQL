import 'package:dio/dio.dart';
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
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/flows/question_flow.dart';
import 'package:passql_app/presentation/pages/questions/chapter_page.dart';
import 'package:passql_app/presentation/providers/chapter_providers.dart';
import 'package:passql_app/presentation/providers/plan_providers.dart';
import 'package:passql_app/presentation/providers/question_providers.dart';
import 'package:passql_app/presentation/widgets/pro/pro_access_feedback.dart';
import 'package:passql_app/presentation/widgets/question/question_load_error_view.dart';
import 'package:passql_app/presentation/widgets/question/question_sections.dart';

import '../../../helpers/fakes/fake_http_client_adapter.dart';
import '../../../helpers/text_finders.dart';

// 문제 2개: 1번은 정상, 2번(미리 받기 대상)은 무료 하루 한도
const String _firstQuestionUuid = 'question-1';
const String _limitedQuestionUuid = 'question-2';
const String _dailyLimitReason = '오늘 무료 10문제를 다 풀었어요';
const String _sheetTitle = '이용권';

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

/// 선택지 세트 없는 2번 문제 (넘어가면 SSE 생성 시작)
const QuestionDetail _choicelessLimitedQuestion = QuestionDetail(
  questionUuid: _limitedQuestionUuid,
  stem: '두 번째 문제',
);

const AppException _dailyLimitError = AppException(
  code: ErrorCode.freeDailyLimitReached,
  message: '오늘 무료 10문제를 다 풀었어요.',
  statusCode: 403,
  serverCode: 'FREE_DAILY_LIMIT_REACHED',
);

const AppException _fairUseLimitError = AppException(
  code: ErrorCode.fairUseDailyLimitReached,
  message: '오늘 풀 수 있는 문제를 모두 풀었어요.',
  statusCode: 429,
  serverCode: 'FAIR_USE_DAILY_LIMIT_REACHED',
);

/// 등급 고정 (결제 켜짐, 무료 또는 프로)
class _FixedPlanNotifier extends PlanNotifier {
  _FixedPlanNotifier(this._plan);

  final MemberPlanType _plan;

  @override
  Future<MemberPlanResponse> build() async => MemberPlanResponse(
    isBillingEnabled: true,
    plan: _plan,
    dailyFreeLimit: 10,
  );

  @override
  Future<void> refresh() async {}
}

/// 문제별 상세 요청 횟수 (미리 받기·재요청 확인용)
final Map<String, int> _detailRequestCountByUuid = {};

/// [firstQuestionError]: 1번 문제 상세 오류 (없으면 정상 문제)
/// [isLimitedOnChoiceGeneration]: 2번 상세는 200, 선택지 생성 연결이 한도 403 (제출 전에 미리 받은 경우)
Widget _chapterApp({
  MemberPlanType plan = MemberPlanType.free,
  AppException? firstQuestionError,
  bool isLimitedOnChoiceGeneration = false,
}) => ProviderScope(
  overrides: [
    planProvider.overrideWith(() => _FixedPlanNotifier(plan)),
    // 실제 앱은 main 이 등급을 앱 수명 유지 > 테스트는 확정 값으로 고정
    isProProvider.overrideWith((ref) => plan == MemberPlanType.pro),
    shouldShowProUiProvider.overrideWith((ref) => plan == MemberPlanType.free),
    proPurchasePortProvider.overrideWithValue(
      const UnavailableProPurchasePort(),
    ),
    questionDetailProvider.overrideWith((ref, questionUuid) async {
      _detailRequestCountByUuid.update(
        questionUuid,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
      if (questionUuid == _limitedQuestionUuid) {
        if (isLimitedOnChoiceGeneration) return _choicelessLimitedQuestion;
        throw _dailyLimitError;
      }
      if (firstQuestionError != null) throw firstQuestionError;
      return _firstQuestion;
    }),
    // 선택지 생성 연결: 서버 거부 JSON (SSE 시작 전 하루 한도)
    dioProvider.overrideWith(
      (ref) =>
          Dio(BaseOptions(baseUrl: 'http://test.local/api'))
            ..httpClientAdapter = FakeHttpClientAdapter(
              (_) => jsonResponseBody(403, {
                'errorCode': 'FREE_DAILY_LIMIT_REACHED',
                'message': _dailyLimitReason,
              }),
            ),
    ),
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
  setUp(_detailRequestCountByUuid.clear);

  testWidgets('prefetchLimitError_doesNotOpenSheetMidQuestion', (tester) async {
    await tester.pumpWidget(_chapterApp());
    await tester.pumpAndSettle();

    // 1번 문제 풀이 중 (보기 선택), 2번 미리 받기는 한도 오류
    expect(find.text('첫 번째 문제'), findsOneWidget);
    await tester.tap(find.text('보기 A'));
    await tester.pumpAndSettle();

    // 미리 받기가 실제로 한도 오류를 받았는데도 시트 없음
    expect(
      _detailRequestCountByUuid[_limitedQuestionUuid],
      greaterThanOrEqualTo(1),
    );
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

    // 다음 문제로 이동 > 미리 받아 둔 한도 오류로 시트 + 이유 줄(사유 + 내일 0시), 시트 뒤는 사유 화면
    _chapterNotifierOf(tester).nextQuestion();
    await tester.pumpAndSettle();

    expect(find.text(_sheetTitle), findsWidgets);
    expect(
      findTextContainingIgnoringWordJoiners(freeDailyLimitSheetReason),
      findsOneWidget,
    );
    expect(
      findTextContainingIgnoringWordJoiners(_dailyLimitReason),
      findsNWidgets(2),
    );
  });

  testWidgets('limitSheetDismissed_showsReasonInsteadOfGenericError', (
    tester,
  ) async {
    await tester.pumpWidget(_chapterApp());
    await tester.pumpAndSettle();
    _chapterNotifierOf(tester).nextQuestion();
    await tester.pumpAndSettle();

    // 시트 닫기 > 일반 오류 대신 한도 사유 + 내일 0시 + 이용권으로 열기
    Navigator.of(tester.element(find.text(_sheetTitle).first)).pop();
    await tester.pumpAndSettle();

    expect(find.text(_sheetTitle), findsNothing);
    expect(find.text(_dailyLimitReason), findsOneWidget);
    expect(find.text(freeDailyLimitResetNotice), findsOneWidget);
    expect(find.text(PassqlLockedPreview.unlockLabel), findsOneWidget);
    expect(
      find.text(QuestionLoadErrorView.genericFailureMessage),
      findsNothing,
    );
    // 풀 문제가 없으니 제출 바 없음
    expect(find.byType(QuestionSubmitBar), findsNothing);

    // 이용권으로 열기 > 같은 시트 다시
    await tester.tap(find.text(PassqlLockedPreview.unlockLabel));
    await tester.pumpAndSettle();
    expect(find.text(_sheetTitle), findsWidgets);
  });

  testWidgets('prefetchedDetailThenChoiceLimit_opensSheetWithReason', (
    tester,
  ) async {
    await tester.pumpWidget(_chapterApp(isLimitedOnChoiceGeneration: true));
    await tester.pumpAndSettle();

    // 미리 받은 상세는 200 > 넘어간 뒤 선택지 생성이 한도 403 > 재시도 반복 대신 시트 + 이유 한 줄
    _chapterNotifierOf(tester).nextQuestion();
    await tester.pumpAndSettle();

    expect(find.text('두 번째 문제'), findsOneWidget);
    expect(find.text(_sheetTitle), findsWidgets);
    expect(
      findTextContainingIgnoringWordJoiners(_dailyLimitReason),
      findsOneWidget,
    );
  });

  testWidgets('fairUseLimitError_showsToastOnce_withoutRetryRequest', (
    tester,
  ) async {
    await tester.pumpWidget(
      _chapterApp(
        plan: MemberPlanType.pro,
        firstQuestionError: _fairUseLimitError,
      ),
    );
    await tester.pumpAndSettle();

    // 프로 사용자 공정 사용 한도 > 토스트 1회 + 사유 화면(결제 버튼 없음), 같은 문제 다시 요청 없음 (반복 방지)
    expect(_detailRequestCountByUuid[_firstQuestionUuid], 1);
    expect(find.text(_fairUseLimitError.message), findsNWidgets(2));
    expect(find.text(fairUseLimitResetNotice), findsOneWidget);
    expect(find.text(PassqlLockedPreview.unlockLabel), findsNothing);
    expect(find.text(_sheetTitle), findsNothing);
  });
}
