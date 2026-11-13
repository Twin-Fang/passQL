import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/error/app_exception.dart';
import '../../../data/models/question/submit_result.dart';
import '../../../presentation/flows/next_question_prefetch.dart';
import '../../../presentation/flows/question_flow.dart';
import '../../../presentation/providers/ai_explanation_session_provider.dart';
import '../../../presentation/providers/chapter_providers.dart';
import '../../../presentation/providers/learning_refresh.dart';
import '../../../presentation/providers/question_providers.dart';
import '../../widgets/ai_explanation/ai_explanation_history_button.dart';
import '../../widgets/ai_explanation/submission_explanation_entry.dart';
import '../../widgets/chapter/chapter_app_bar.dart';
import '../../widgets/chapter/chapter_question_body.dart';
import 'chapter_flow_progression.dart';
import '../../../data/models/question/question_detail.dart';
import '../../widgets/chapter/chapter_feedback_bar.dart';
import '../../widgets/pro/pro_access_feedback.dart';
import '../../widgets/question/choice_display_label.dart';
import '../../../router/solving_flow_exit.dart';
import '../../design/design.dart';
import '../../widgets/question/question_sections.dart';
import '../../widgets/question/question_load_error_view.dart';
import '../../widgets/question/question_pro_access_notice.dart';

/// 문제 풀이 플로우 메인 페이지 (풀스크린).
///
/// 문제 묶음을 순서대로 풀고 마지막 제출 후 흐름(`QuestionFlow`)이 정한 곳으로 이동한다.
/// 토픽 챕터, 데일리 세트가 이 화면을 함께 쓴다.
/// 연속 흐름(랜덤 풀기)은 남은 문제가 적어지면 이어 받고, 나가면 그때까지의 요약으로 간다 (#963).
class ChapterPage extends ConsumerStatefulWidget {
  final QuestionFlow flow;

  const ChapterPage({super.key, required this.flow});

  @override
  ConsumerState<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends ConsumerState<ChapterPage>
    with ChapterFlowProgression {
  /// 선택지를 이미 준비한 questionUuid — 중복 준비 방지.
  final Set<String> _choiceInitializedUuids = {};

  /// 프로 접근 오류 1회 안내 (무료 하루 한도는 본문 한도 화면이 맡음, #963)
  final QuestionProAccessNotice _proAccessNotice = QuestionProAccessNotice();

  /// 이번 풀이의 세션 식별자. 화면이 다시 그려져도 바뀌지 않도록 상태에 둔다.
  @override
  final String sessionUuid = const Uuid().v4();

  /// 이 화면에서 답안을 한 번이라도 제출했는지. 벗어날 때 학습 현황을 갱신할지 정한다.
  bool _hasSubmittedAny = false;

  /// 문제별 메모 (#904): 이 풀이 화면 동안만 메모리에, 화면을 벗어나면 사라짐
  final PassqlMemoController _memoController = PassqlMemoController();

  /// dispose 시점에는 ref 를 쓸 수 없으므로 컨테이너를 미리 잡아 둔다.
  late final ProviderContainer _container;

  @override
  void initState() {
    super.initState();
    _container = ProviderScope.containerOf(context, listen: false);
    startFlowProgression();
    // 첫 프레임 이후 문제 목록 로드
    Future.microtask(() {
      if (!mounted) return;
      ref
          .read(chapterProvider(widget.flow.id).notifier)
          .load(() => widget.flow.loadStart(ref));
    });
  }

  /// 현재 문제의 선택지 준비를 첫 프레임 뒤 한 번만 요청 (재사용·생성 판단은 notifier 몫)
  void _initializeChoicesOnce(String questionUuid, QuestionDetail question) {
    if (!_choiceInitializedUuids.add(questionUuid)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(questionInteractionProvider(questionUuid).notifier)
          .initializeChoices(question);
    });
  }

  /// 현재 문제 상세 다시 받기 (오류 안내도 다시 가능)
  void _retryQuestionDetail(String questionUuid) {
    _proAccessNotice.forget(questionUuid);
    ref.invalidate(questionDetailProvider(questionUuid));
  }

  /// 제출: 선택 키 고정 > 서버 제출 > 결과 기록(성공) + 해설함 추가, 실패는 한도·이용권 시트(풀리면 다시 제출) 또는 원인별 토스트
  Future<void> _submitCurrentQuestion(String currentUuid) async {
    // 선택 키·보기 표시 라벨·순번 미리 저장 (제출 후 interaction state가 바뀔 수 있으므로)
    final interactionBeforeSubmit = ref.read(
      questionInteractionProvider(currentUuid),
    );
    final selectedKey = interactionBeforeSubmit.selectedChoiceKey ?? '';
    final displayLabelByChoiceKey = choiceDisplayLabelsOf(
      interactionBeforeSubmit.activeChoices,
    );
    final questionNumber =
        ref.read(chapterProvider(widget.flow.id)).currentIndex + 1;
    final SubmitResult? submitResult;
    try {
      submitResult = await ref
          .read(questionInteractionProvider(currentUuid).notifier)
          .submit(
            sessionUuid: widget.flow.shouldTrackSession ? sessionUuid : null,
          );
    } on AppException catch (exception) {
      if (!mounted) return;
      // 제출 시점 하루 한도·프로 필요 > 한도 시트(광고·세트)·이용권 시트, 풀리면 다시 제출 (#867·#963)
      final shouldResubmit = await showSubmitFailureFeedback(
        context,
        ref,
        exception,
      );
      if (!shouldResubmit || !mounted) return;
      return _submitCurrentQuestion(currentUuid);
    }
    if (!mounted || submitResult == null) return;

    _hasSubmittedAny = true;
    ref
        .read(chapterProvider(widget.flow.id).notifier)
        .recordSubmission(submitResult, selectedKey);
    refetchNextQuestionDetailIfFree(ref, widget.flow.id);
    addSubmissionExplanationEntry(
      ref,
      questionUuid: currentUuid,
      result: submitResult,
      selectedKey: selectedKey,
      questionNumber: questionNumber,
      displayLabelByChoiceKey: displayLabelByChoiceKey,
    );
  }

  @override
  void dispose() {
    // 챕터는 문제를 여러 번 제출하므로 매번이 아니라 화면을 벗어날 때 한 번만 갱신한다.
    // (중간에 나가도, 끝까지 풀고 결과 화면으로 가도 같은 경로를 탄다.)
    if (_hasSubmittedAny) refreshLearningData(_container.invalidate);
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flowId = widget.flow.id;
    final chapter = ref.watch(chapterProvider(flowId));

    // 목록 로딩 중 / 에러 또는 빈 목록
    if (chapter.isLoadingList ||
        chapter.listError != null ||
        chapter.questionUuids.isEmpty) {
      return PassqlStatusScaffold(
        title: widget.flow.title,
        leading: PassqlNavLeading.close,
        onLeadingTap: () => leaveSolvingFlow(context),
        body: chapter.isLoadingList
            ? PassqlStatusView.loading()
            : PassqlStatusView.error(
                message: chapter.listError ?? '문제가 없어요',
                // 문제 목록을 다시 불러온다. (오늘의 세트를 이미 끝냈다면 다시 불러도 같은 안내가 나온다)
                onRetry: () => ref
                    .read(chapterProvider(widget.flow.id).notifier)
                    .load(() => widget.flow.loadStart(ref)),
              ),
      );
    }

    final currentUuid = chapter.questionUuids[chapter.currentIndex];
    final detailAsync = ref.watch(questionDetailProvider(currentUuid));
    final interaction = ref.watch(questionInteractionProvider(currentUuid));
    final interactionNotifier = ref.read(
      questionInteractionProvider(currentUuid).notifier,
    );

    prefetchNextQuestionDetail(ref, chapter);
    _proAccessNotice.showOnceForChoiceGeneration(
      context,
      ref,
      interaction,
      interactionNotifier,
    );
    // 선택지 받기가 하루 한도로 막힘 > 본문은 한도 화면, 하단 바 없음
    final choiceLimitFailure = dailyLimitFailureOfChoiceGeneration(interaction);

    // 한 문제라도 제출했거나 2번째 문제 이상이면 "풀이 시작"으로 본다.
    final hasStarted = chapter.currentIndex > 0 || chapter.isAnswered;
    final explanationEntry = watchSubmissionExplanationEntry(
      ref,
      currentUuid,
      chapter,
    );

    final scaffold = Scaffold(
      // 하단 바(글래스) 뒤로 본문이 비쳐 보이도록 body 를 바 아래까지 확장한다.
      extendBody: true,
      appBar: ChapterAppBar(
        flowTitle: widget.flow.title,
        // 캡션 영역 이름: 지금 문제의 영역 (상세 로딩 전이면 흐름 이름만)
        areaName: detailAsync.valueOrNull?.topicName,
        currentIndex: chapter.currentIndex,
        total: chapter.questionUuids.length,
        answeredCorrectness: [
          for (final result in chapter.results) result.isCorrect,
        ],
        shouldConfirmExit: hasStarted,
        accessory: const AiExplanationHistoryButton(),
        isContinuous: widget.flow.isContinuous,
        onExit: widget.flow.isContinuous ? leaveContinuousFlow : null,
      ),
      body: ChapterQuestionBody(
        questionUuid: currentUuid,
        detailAsync: detailAsync,
        interaction: interaction,
        interactionNotifier: interactionNotifier,
        chapter: chapter,
        memoController: _memoController,
        choiceLimitFailure: choiceLimitFailure,
        shouldShowFirstQuestionBadge:
            widget.flow.isOnboarding && !hasShownOnboardingCelebration,
        onDetailError: (error) => _proAccessNotice.showOnce(
          context,
          ref,
          noticeKey: currentUuid,
          error: error,
          onUnlocked: () => _retryQuestionDetail(currentUuid),
        ),
        onDetailLoaded: (question) =>
            _initializeChoicesOnce(currentUuid, question),
        onRetryDetail: () => _retryQuestionDetail(currentUuid),
      ),
      // 하단 바 — 미제출: 제출 버튼 / 제출 완료: 피드백 바 / 프로 접근 사유·한도 화면: 없음 (풀 문제 없음)
      // 문제 로딩 중에도 바 유지 (선택 전이라 제출 비활성), 교체 때 바가 깜빡이지 않게
      bottomNavigationBar:
          choiceLimitFailure != null ||
              detailAsync.hasError &&
                  QuestionLoadErrorView.isProAccessReason(detailAsync.error!)
          ? null
          : !chapter.isAnswered
          ? QuestionSubmitBar(
              interaction: interaction,
              onSubmit: () => _submitCurrentQuestion(currentUuid),
            )
          : ChapterFeedbackBar(
              // 문제가 바뀔 때마다 새로 만들어 햅틱이 다시 울리게 한다.
              key: ValueKey(currentUuid),
              result: chapter.lastSubmitResult!,
              questionUuid: currentUuid,
              explanationEntry: explanationEntry,
              onOpenExplanation: explanationEntry == null
                  ? null
                  : () => ref
                        .read(aiExplanationSessionProvider.notifier)
                        .openEntry(explanationEntry.id),
              correctDisplayLabel: findChoiceDisplayLabel(
                interaction.activeChoices,
                chapter.lastSubmitResult!.correctKey,
              ),
              // 연속 흐름은 늘 [다음] (끝은 나가기로 정함)
              isLastQuestion:
                  chapter.isLastQuestion && !widget.flow.isContinuous,
              isLoadingNext: isWaitingMoreQuestions,
              onNext: () => goNext(chapter),
            ),
    );

    // 시스템 뒤로가기(Android 백 버튼, iOS 스와이프)도 홈 아이콘과 같은 확인을 거친다.
    // 연속 흐름은 푼 문제가 있으면 확인 없이 요약으로
    return PopScope(
      canPop: widget.flow.isContinuous ? chapter.results.isEmpty : !hasStarted,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (widget.flow.isContinuous) return leaveContinuousFlow();
        if (await confirmChapterExit(context) && context.mounted) {
          leaveSolvingFlow(context);
        }
      },
      child: scaffold,
    );
  }
}
