import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/ai/ai_result.dart';
import 'package:passql_app/data/models/ai/choice_explanation.dart';
import 'package:passql_app/data/models/ai/choice_explanation_response.dart';
import 'package:passql_app/data/models/ai/similar_question.dart';
import 'package:passql_app/data/models/question/submit_result.dart';
import 'package:passql_app/data/sources/ai_api.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/providers/ai_explanation_session_provider.dart';
import 'package:passql_app/presentation/providers/choice_explanation_providers.dart';
import 'package:passql_app/presentation/providers/session_reset.dart';
import 'package:passql_app/presentation/widgets/ai_explanation/ai_explanation_content.dart';
import 'package:passql_app/presentation/widgets/ai_explanation/ai_explanation_dock.dart';
import 'package:passql_app/presentation/widgets/ai_explanation/ai_explanation_history_button.dart';
import 'package:passql_app/presentation/widgets/ai_explanation/ai_explanation_preview_card.dart';
import 'package:passql_app/presentation/widgets/ai_explanation/ai_explanation_verdict.dart';
import 'package:passql_app/presentation/widgets/chapter/chapter_feedback_bar.dart';

/// 해설 조회 가짜: 호출마다 준비한 응답을 차례로 돌려줌 (마지막 응답은 반복), 호출 인자 기록
class _FakeChoiceExplanationApi implements AiApiClient {
  _FakeChoiceExplanationApi(this.replies);

  /// 응답 또는 던질 오류
  final List<Object> replies;
  final requestedChoiceSetUuids = <String?>[];

  int get callCount => requestedChoiceSetUuids.length;

  @override
  Future<ChoiceExplanationResponse> getChoiceExplanation(
    String questionUuid, {
    String? choiceSetUuid,
    String? selectedChoiceKey,
  }) async {
    requestedChoiceSetUuids.add(choiceSetUuid);
    final reply = replies[(callCount - 1).clamp(0, replies.length - 1)];
    if (reply is ChoiceExplanationResponse) return reply;
    throw reply;
  }

  @override
  Future<AiResult> diffExplain(Map<String, dynamic> body) =>
      throw UnimplementedError();

  @override
  Future<AiResult> explainError(Map<String, dynamic> body) =>
      throw UnimplementedError();

  @override
  Future<List<SimilarQuestion>> getSimilar(String questionUuid, int k) =>
      throw UnimplementedError();
}

/// 서버 키 B 를 골랐고 정답 키는 A. 화면에는 섞인 순서(B 가 첫째) > 표시 라벨 B=A, A=C (#512)
const _explanation = ChoiceExplanation(
  selectedChoiceKey: 'B',
  correctChoiceKey: 'A',
  isSelectedCorrect: false,
  verdict: '오답 · B 선택, 정답은 A',
  correctReason: '`DENSE_RANK` 는 동점 다음 순위를 건너뛰지 않음',
  keyConcepts: [KeyConcept(name: 'DENSE_RANK', description: '동점 같은 순위')],
  confusingPoints: ['`RANK` 와 다음 순위만 다름'],
  choiceAnalyses: [
    ChoiceAnalysis(choiceKey: 'A', isCorrect: true, reason: '건너뛰지 않아 3'),
    ChoiceAnalysis(choiceKey: 'B', isCorrect: false, reason: '4 는 RANK 기준'),
  ],
  examTip: '동점 다음 행 순위로 구분',
);

const _displayLabels = {'B': 'A', 'D': 'B', 'A': 'C', 'C': 'D'};

ChoiceExplanationResponse _generating() => const ChoiceExplanationResponse(
  choiceSetUuid: 'set-1',
  selectedChoiceKey: 'B',
  status: ChoiceExplanationStatus.generating,
  retryAfterMilliseconds: 1500,
);

ChoiceExplanationResponse _ready() => const ChoiceExplanationResponse(
  choiceSetUuid: 'set-1',
  selectedChoiceKey: 'B',
  status: ChoiceExplanationStatus.ready,
  explanation: _explanation,
  text: '**오답**',
);

AiExplanationEntry _entry({
  String choiceSetUuid = 'set-1',
  int questionNumber = 1,
  ChoiceExplanation? initialExplanation,
}) => AiExplanationEntry(
  request: ChoiceExplanationRequest(
    questionUuid: 'q-$questionNumber',
    choiceSetUuid: choiceSetUuid,
    selectedChoiceKey: 'B',
    initialExplanation: initialExplanation,
  ),
  isCorrect: false,
  questionNumber: questionNumber,
  displayLabelByChoiceKey: _displayLabels,
  rationale: '생성 근거 폴백',
);

Widget _app(_FakeChoiceExplanationApi api, Widget child) => ProviderScope(
  overrides: [
    aiApiProvider.overrideWithValue(api),
    currentMemberUuidProvider.overrideWithValue('member-1'),
  ],
  child: MaterialApp(theme: PassqlTheme.light, home: child),
);

/// 미리보기 카드 하나 (제출 직후 피드백 바와 같은 자리)
Widget _previewHost(AiExplanationEntry entry) => Scaffold(
  body: Padding(
    padding: const EdgeInsets.all(PassqlSpacing.md),
    child: AiExplanationPreviewCard(entry: entry, onOpenFullExplanation: () {}),
  ),
);

void main() {
  group('재조회 간격', () {
    test('서버 간격부터 1.5배씩 늘고 6초 상한', () {
      final delays = [
        for (var attempt = 0; attempt < 6; attempt++)
          ChoiceExplanationPolling.delayOf(attempt, 1500).inMilliseconds,
      ];
      expect(delays, [1500, 2250, 3375, 5063, 6000, 6000]);
    });

    test('서버 간격이 더 길면 서버 간격, 없으면 기본 1.5초', () {
      expect(ChoiceExplanationPolling.delayOf(0, 4000).inMilliseconds, 4000);
      expect(ChoiceExplanationPolling.delayOf(0, null).inMilliseconds, 1500);
    });
  });

  test('판정은 서버 choiceKey 가 아니라 화면 표시 라벨로 조립 (#512)', () {
    expect(
      composeAiExplanationVerdict(_explanation, _entry()),
      '오답 · A 선택, 정답은 C · 4 는 RANK 기준',
    );
  });

  test('제출 결과에 선택지 세트가 없으면 해설 요청을 만들지 않음', () {
    expect(
      ChoiceExplanationRequest.fromSubmission(
        questionUuid: 'q',
        result: const SubmitResult(isCorrect: false),
      ),
      isNull,
    );
  });

  testWidgets('제출 응답에 구조화 해설이 있으면 요청 없이 바로 미리보기', (tester) async {
    final api = _FakeChoiceExplanationApi([_generating()]);
    await tester.pumpWidget(
      _app(api, _previewHost(_entry(initialExplanation: _explanation))),
    );
    await tester.pump();
    expect(find.text('오답 · A 선택, 정답은 C · 4 는 RANK 기준'), findsOneWidget);
    expect(find.byType(PassqlTextSkeleton), findsNothing);
    expect(api.callCount, 0);
  });

  testWidgets('생성 중이면 스켈레톤 한 블록 > 재조회 > 준비되면 미리보기로 교체', (tester) async {
    final api = _FakeChoiceExplanationApi([_generating(), _ready()]);
    await tester.pumpWidget(_app(api, _previewHost(_entry())));
    await tester.pump();
    // 스켈레톤은 반짝임 1개짜리 한 블록
    expect(find.byType(PassqlTextSkeleton), findsOneWidget);
    expect(api.callCount, 1);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(PassqlMotion.standard);
    await tester.pump(PassqlMotion.standard);
    expect(api.callCount, 2);
    expect(find.text('오답 · A 선택, 정답은 C · 4 는 RANK 기준'), findsOneWidget);
    expect(find.byType(PassqlTextSkeleton), findsNothing);
  });

  testWidgets('조회 실패면 다시 시도 > 성공하면 해설 표시', (tester) async {
    final api = _FakeChoiceExplanationApi([StateError('network'), _ready()]);
    await tester.pumpWidget(
      _app(
        api,
        Scaffold(
          body: SingleChildScrollView(
            child: AiExplanationContent(entry: _entry()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(PassqlMotion.standard);
    expect(find.text('다시 시도'), findsOneWidget);
    // 실패 시 생성 근거 폴백
    expect(find.textContaining('생성 근거 폴백'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(api.callCount, 2);
    expect(find.text('핵심 개념'), findsOneWidget);
    expect(find.text('헷갈리는 지점'), findsOneWidget);
    expect(find.text('보기별 판단'), findsOneWidget);
    expect(find.text('시험 팁'), findsOneWidget);
    expect(find.text('내 선택'), findsOneWidget);
  });

  testWidgets('재조회 상한을 넘기면 준비 안 됨 안내 + 다시 시도', (tester) async {
    final api = _FakeChoiceExplanationApi([_generating()]);
    await tester.pumpWidget(_app(api, _previewHost(_entry())));
    await tester.pump();
    for (
      var attempt = 0;
      attempt < ChoiceExplanationPolling.maximumAttemptCount;
      attempt++
    ) {
      await tester.pump(const Duration(seconds: 7));
    }
    await tester.pump(PassqlMotion.standard);
    expect(api.callCount, ChoiceExplanationPolling.maximumAttemptCount + 1);
    expect(find.text(choiceExplanationTimeoutMessage), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });

  group('해설 시트·해설함', () {
    /// 풀이 화면 축약판: 상단 바 해설함 버튼 + 본문 위 시트 + 하단 피드백 바(다음)
    Widget dockHost(ValueNotifier<int> currentQuestion) => Consumer(
      builder: (context, ref, _) => ValueListenableBuilder<int>(
        valueListenable: currentQuestion,
        builder: (context, questionNumber, _) {
          final session = ref.watch(aiExplanationSessionProvider);
          final entry = session.entries.isEmpty ? null : session.entries.first;
          return Scaffold(
            extendBody: true,
            appBar: AppBar(actions: const [AiExplanationHistoryButton()]),
            body: AiExplanationDock(
              child: Center(child: Text('$questionNumber번 본문')),
            ),
            bottomNavigationBar: ChapterFeedbackBar(
              result: const SubmitResult(isCorrect: false, correctKey: 'A'),
              questionUuid: 'q-$questionNumber',
              explanationEntry: entry,
              onOpenExplanation: entry == null
                  ? null
                  : () => ref
                        .read(aiExplanationSessionProvider.notifier)
                        .openEntry(entry.id),
              isLastQuestion: false,
              onNext: () => currentQuestion.value++,
            ),
          );
        },
      ),
    );

    testWidgets('시트를 연 채로 다음 문제로 가도 시트 유지, 해설함에서 이전 해설 다시 열기', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final api = _FakeChoiceExplanationApi([_ready()]);
      final currentQuestion = ValueNotifier(1);
      await tester.pumpWidget(_app(api, dockHost(currentQuestion)));
      final container = ProviderScope.containerOf(
        tester.element(find.byType(AiExplanationDock)),
      );
      final session = container.read(aiExplanationSessionProvider.notifier);

      // 1번 제출 > 미리보기 > 전체 보기
      session.addEntry(_entry(initialExplanation: _explanation));
      await tester.pump();
      await tester.tap(find.byType(AiExplanationPreviewCard));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('AI 해설 · 1번 문제'), findsOneWidget);

      // 시트가 떠 있어도 하단 바 '다음' 을 누를 수 있음
      await tester.tap(find.text('다음'));
      await tester.pump(const Duration(seconds: 1));
      expect(currentQuestion.value, 2);
      expect(find.text('2번 본문'), findsOneWidget);
      expect(find.text('AI 해설 · 1번 문제'), findsOneWidget);

      // 2번 제출 (생성 중) > 해설함에 2개
      session.addEntry(_entry(choiceSetUuid: 'set-2', questionNumber: 2));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.bySemanticsLabel('해설함, 2개'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('해설함'), findsOneWidget);
      expect(find.text('1번 문제'), findsOneWidget);
      expect(find.text('2번 문제'), findsOneWidget);

      // 이전 해설 다시 열기
      await tester.tap(find.text('1번 문제'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('AI 해설 · 1번 문제'), findsOneWidget);

      // 닫으면 상단 바 해설함 버튼으로 다시 열 수 있음
      await tester.tap(find.bySemanticsLabel('해설 닫기'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('AI 해설 · 1번 문제'), findsNothing);
      await tester.tap(find.byType(AiExplanationHistoryButton));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('해설함'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('다음 문제로 넘어가도 이전 해설 재조회는 백그라운드로 끝까지', (tester) async {
      final api = _FakeChoiceExplanationApi([_generating(), _ready()]);
      final currentQuestion = ValueNotifier(1);
      await tester.pumpWidget(_app(api, dockHost(currentQuestion)));
      final container = ProviderScope.containerOf(
        tester.element(find.byType(AiExplanationDock)),
      );
      final entry = _entry();
      container.read(aiExplanationSessionProvider.notifier).addEntry(entry);
      await tester.pump();
      await tester.tap(find.text('다음'));
      await tester.pump(const Duration(seconds: 2));
      expect(api.callCount, 2);
      expect(
        container.read(choiceExplanationProvider(entry.request)).phase,
        ChoiceExplanationPhase.ready,
      );
    });
  });

  testWidgets('다크·큰 글자에서도 전체 해설이 넘치지 않음', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final api = _FakeChoiceExplanationApi([_ready()]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiApiProvider.overrideWithValue(api),
          currentMemberUuidProvider.overrideWithValue('member-1'),
        ],
        child: MaterialApp(
          theme: PassqlTheme.dark,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.6),
              disableAnimations: true,
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: AiExplanationContent(
                  entry: _entry(initialExplanation: _explanation),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('시험 팁'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
