import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/monitoring/crash_reporter.dart';
import '../../../data/models/question/submit_result.dart';
import '../../../presentation/flows/continuous_question_loader.dart';
import '../../../presentation/flows/next_question_prefetch.dart';
import '../../../presentation/flows/question_flow.dart';
import '../../../presentation/providers/ai_explanation_session_provider.dart';
import '../../../presentation/providers/chapter_providers.dart';
import '../../../presentation/providers/learning_refresh.dart';
import '../../../presentation/providers/onboarding_providers.dart';
import '../../../presentation/providers/question_providers.dart';
import '../../widgets/ai_explanation/ai_explanation_dock.dart';
import '../../widgets/ai_explanation/ai_explanation_history_button.dart';
import '../../widgets/ai_explanation/submission_explanation_entry.dart';
import '../../widgets/chapter/chapter_app_bar.dart';
import '../../../data/models/question/question_detail.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/chapter/chapter_feedback_bar.dart';
import '../../flows/random_practice_flow.dart';
import '../../widgets/pro/pro_access_feedback.dart';
import '../../widgets/question/choice_display_label.dart';
import '../../../router/app_routes.dart';
import '../../../router/solving_flow_exit.dart';
import '../../design/design.dart';
import '../../widgets/question/question_sections.dart';
import '../../widgets/question/question_solving_body.dart';
import '../../widgets/question/question_load_error_view.dart';
import '../../widgets/question/question_pro_access_notice.dart';
import '../../widgets/question/question_solving_skeleton.dart';

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

class _ChapterPageState extends ConsumerState<ChapterPage> {
  /// 선택지를 이미 준비한 questionUuid — 중복 준비 방지.
  final Set<String> _choiceInitializedUuids = {};

  /// 프로 접근 오류 1회 안내 (무료 하루 한도는 본문 한도 화면이 맡음, #963)
  final QuestionProAccessNotice _proAccessNotice = QuestionProAccessNotice();

  /// 이번 풀이의 세션 식별자. 화면이 다시 그려져도 바뀌지 않도록 상태에 둔다.
  final String _sessionUuid = const Uuid().v4();

  /// 마지막 문제 이후 완료 처리(점수 등록 등)가 진행 중인지. 중복 실행과 연타를 막는다.
  bool _isCompleting = false;

  /// 풀이 화면을 이미 떠났는지 (요약 이동·닫기). 교체 애니메이션 중 늦게 끝난 이어 받기의 중복 이동 방지
  bool _hasLeftFlow = false;

  /// 연속 흐름 이어 받기 (#963)
  late final ContinuousQuestionLoader _continuousQuestionLoader =
      ContinuousQuestionLoader(
        flow: widget.flow,
        ref: ref,
        isMounted: () => mounted,
      );

  /// 마지막 문제에서 [다음]을 눌러 이어 받기를 기다리는 중 (버튼 로딩·연타 방지)
  bool _isWaitingMoreQuestions = false;

  /// 이 화면에서 답안을 한 번이라도 제출했는지. 벗어날 때 학습 현황을 갱신할지 정한다.
  bool _hasSubmittedAny = false;

  /// 온보딩 첫 문제 축하를 이미 띄웠는지. 이후 문제에는 배지·축하가 없다.
  bool _hasShownOnboardingCelebration = false;
  bool _isShowingOnboardingCelebration = false;

  /// 문제별 메모 (#904): 이 풀이 화면 동안만 메모리에, 화면을 벗어나면 사라짐
  final PassqlMemoController _memoController = PassqlMemoController();

  /// dispose 시점에는 ref 를 쓸 수 없으므로 컨테이너를 미리 잡아 둔다.
  late final ProviderContainer _container;

  @override
  void initState() {
    super.initState();
    _container = ProviderScope.containerOf(context, listen: false);
    _clearOnboardingOnceListLoaded();
    if (widget.flow.isContinuous) {
      _continuousQuestionLoader.listenToLoadMoreWhenRunningLow();
    }
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
            sessionUuid: widget.flow.shouldTrackSession ? _sessionUuid : null,
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

  /// 온보딩에서 들어왔으면 문제 목록을 실제로 받은 순간 온보딩 대기를 지운다.
  /// 목록 오류·빈 세트면 남겨 두어 다음에 온보딩을 다시 이어 간다.
  void _clearOnboardingOnceListLoaded() {
    if (!widget.flow.isOnboarding) return;
    ref.listenManual(chapterProvider(widget.flow.id), (_, next) {
      if (next.isLoadingList ||
          next.listError != null ||
          next.questionUuids.isEmpty) {
        return;
      }
      ref.read(onboardingPendingProvider.notifier).clear();
    });
  }

  /// 다음 문제·결과로 넘어가기 전, 온보딩 첫 문제였으면 축하 화면을 한 번 띄운다.
  /// 연속 흐름의 마지막 문제면 이어 받기 > 받은 게 있으면 다음 문제, 없으면 요약
  Future<void> _goNext(ChapterState chapter) async {
    if (_isCompleting ||
        _isShowingOnboardingCelebration ||
        _isWaitingMoreQuestions) {
      return;
    }
    if (widget.flow.isOnboarding && !_hasShownOnboardingCelebration) {
      setState(() => _hasShownOnboardingCelebration = true);
      // 축하 화면이 뜨는 사이 [다음] 연타로 문제를 건너뛰지 않게 막는다.
      _isShowingOnboardingCelebration = true;
      await context.push<void>(
        AppRoutes.onboardingCelebration,
        extra: chapter.isLastQuestion,
      );
      _isShowingOnboardingCelebration = false;
      if (!mounted || _hasLeftFlow) return;
    }
    // 백그라운드 이어 받기가 목록을 늘렸을 수 있어 최신 상태로 판정
    final isLastQuestion = ref
        .read(chapterProvider(widget.flow.id))
        .isLastQuestion;
    if (!isLastQuestion) {
      _moveToNextQuestion();
    } else if (widget.flow.isContinuous) {
      await _continueWithMoreQuestions();
    } else {
      _complete();
    }
  }

  /// 다음 문제로 이동 (새 문제를 풀 때는 지난 해설 시트를 닫음, 해설함·백그라운드 조회는 유지)
  void _moveToNextQuestion() {
    ref.read(aiExplanationSessionProvider.notifier).closePanel();
    ref.read(chapterProvider(widget.flow.id).notifier).nextQuestion();
  }

  /// 연속 흐름 마지막 문제의 [다음]: 이어 받기 대기 > 늘었으면 다음 문제, 그대로면 요약 (실패는 토스트 후 다시 누를 수 있게)
  Future<void> _continueWithMoreQuestions() async {
    setState(() => _isWaitingMoreQuestions = true);
    try {
      await _continuousQuestionLoader.loadMoreQuestions();
    } catch (exception, stackTrace) {
      reportIfUnexpectedFailure(
        exception,
        stackTrace,
        reason: 'chapterLoadMore:${widget.flow.id}',
      );
      if (mounted && !_hasLeftFlow) {
        showAppToast(context, exception.asAppException.message);
      }
      return;
    } finally {
      if (mounted) setState(() => _isWaitingMoreQuestions = false);
    }
    // 기다리는 사이 나가기로 요약에 갔으면 다시 이동하지 않음
    if (!mounted || _hasLeftFlow) return;
    if (ref.read(chapterProvider(widget.flow.id)).isLastQuestion) {
      _complete();
    } else {
      _moveToNextQuestion();
    }
  }

  /// 연속 흐름 나가기 (닫기·뒤로가기): 푼 문제가 있으면 확인 없이 요약, 없으면 바로 닫기
  void _leaveContinuousFlow() {
    if (_isCompleting || _hasLeftFlow) return;
    if (ref.read(chapterProvider(widget.flow.id)).results.isEmpty) {
      _hasLeftFlow = true;
      leaveSolvingFlow(context);
      return;
    }
    _complete();
  }

  /// 마지막 문제까지 끝남 — 요약을 만들어 이후 처리는 흐름에 맡긴다.
  Future<void> _complete() async {
    if (_isCompleting || _hasLeftFlow) return;
    _isCompleting = true;
    // 완료 처리(점수 등록)가 길어질 수 있어 공통 잠금 창으로 화면을 막음 (이 창만 닫음)
    final closeBlockingProgress = showPassqlBlockingProgressWithCloser(context);
    final summary = ref
        .read(chapterProvider(widget.flow.id).notifier)
        .buildSummary(widget.flow.title);
    try {
      await widget.flow.onCompleted(context, ref, summary, _sessionUuid);
      _hasLeftFlow = true;
    } catch (exception, stackTrace) {
      // 완료 처리에서 예상 밖 오류가 나도 화면이 멈추지 않게 하고, 다시 시도할 수 있게 잠금을 푼다.
      reportIfUnexpectedFailure(
        exception,
        stackTrace,
        reason: 'chapterComplete:${widget.flow.id}',
      );
      if (mounted) showAppToast(context, '완료 처리에 실패했어요. 다시 시도해 주세요.');
    } finally {
      // 잠금 창 닫기 (성공·실패 공통, 다음 화면으로 바뀌며 이미 닫혔으면 무시)
      closeBlockingProgress();
      _isCompleting = false;
    }
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
        topicName: widget.flow.title,
        currentIndex: chapter.currentIndex,
        total: chapter.questionUuids.length,
        isAnswered: chapter.isAnswered,
        shouldConfirmExit: hasStarted,
        accessory: const AiExplanationHistoryButton(),
        shouldShowRemainingSolves: widget.flow is RandomPracticeFlow,
        isContinuous: widget.flow.isContinuous,
        onExit: widget.flow.isContinuous ? _leaveContinuousFlow : null,
      ),
      // 문제 교체: 옆으로 미끄러지며 바뀜 (문제마다 key), 같은 문제 안 로딩 > 내용은 페이드
      // 해설 시트는 본문 위에 떠서 하단 바를 가리지 않음 (다음 문제로 넘어가면 닫히고 해설함에서 다시 열 수 있음)
      body: AiExplanationDock(
        // 메모: 펜 버튼으로 켜고 끔, 끄면 터치는 전부 문제로 (#904). 해설 시트는 메모 위에 뜸
        child: PassqlMemoScope(
          controller: _memoController,
          activePageKey: currentUuid,
          child: PassqlPageSlideSwitcher(
            child: KeyedSubtree(
              key: ValueKey(currentUuid),
              child: PassqlFadeSwitcher(
                child: detailAsync.when(
                  loading: () =>
                      const QuestionSolvingSkeleton(key: ValueKey('loading')),
                  error: (error, _) {
                    _proAccessNotice.showOnce(
                      context,
                      ref,
                      noticeKey: currentUuid,
                      error: error,
                      onUnlocked: () => _retryQuestionDetail(currentUuid),
                    );
                    return KeyedSubtree(
                      key: const ValueKey('error'),
                      child: QuestionLoadErrorView(
                        error: error,
                        onRetry: () => _retryQuestionDetail(currentUuid),
                      ),
                    );
                  },
                  data: (question) {
                    _initializeChoicesOnce(currentUuid, question);
                    if (choiceLimitFailure != null) {
                      return QuestionLoadErrorView(
                        key: const ValueKey('limit'),
                        error: choiceLimitFailure,
                        onRetry: interactionNotifier.startSseGeneration,
                      );
                    }
                    // Scaffold 안쪽 context 여야 extendBody 가 더한 하단 바 높이를 읽는다.
                    return Builder(
                      key: const ValueKey('data'),
                      builder: (context) => QuestionSolvingBody(
                        questionUuid: currentUuid,
                        question: question,
                        interaction: interaction,
                        notifier: interactionNotifier,
                        // 제출 후에는 정답/오답을 선택지에 표시한다.
                        submitResult: chapter.isAnswered
                            ? chapter.lastSubmitResult
                            : null,
                        gradedSelectedKey: chapter.lastSelectedKey,
                        // 재시도가 소용없는 오류여도 다시 눌러 볼 수 있게 두어 막다른 길을 만들지 않는다.
                        shouldAlwaysAllowRetry: true,
                        topBadge:
                            widget.flow.isOnboarding &&
                                !_hasShownOnboardingCelebration
                            ? const PassqlBadge(text: '첫 문제')
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
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
              isLoadingNext: _isWaitingMoreQuestions,
              onNext: () => _goNext(chapter),
            ),
    );

    // 시스템 뒤로가기(Android 백 버튼, iOS 스와이프)도 홈 아이콘과 같은 확인을 거친다.
    // 연속 흐름은 푼 문제가 있으면 확인 없이 요약으로
    return PopScope(
      canPop: widget.flow.isContinuous ? chapter.results.isEmpty : !hasStarted,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (widget.flow.isContinuous) return _leaveContinuousFlow();
        if (await confirmChapterExit(context) && context.mounted) {
          leaveSolvingFlow(context);
        }
      },
      child: scaffold,
    );
  }
}
