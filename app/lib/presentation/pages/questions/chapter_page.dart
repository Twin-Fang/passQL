import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/monitoring/crash_reporter.dart';
import '../../../data/models/question/submit_result.dart';
import '../../../presentation/flows/question_flow.dart';
import '../../../presentation/providers/ai_explanation_session_provider.dart';
import '../../../presentation/providers/chapter_providers.dart';
import '../../../presentation/providers/choice_explanation_providers.dart';
import '../../../presentation/providers/learning_refresh.dart';
import '../../../presentation/providers/onboarding_providers.dart';
import '../../../presentation/providers/plan_providers.dart';
import '../../../presentation/providers/question_providers.dart';
import '../../widgets/ai_explanation/ai_explanation_dock.dart';
import '../../widgets/ai_explanation/ai_explanation_history_button.dart';
import '../../widgets/chapter/chapter_app_bar.dart';
import '../../../data/models/question/question_detail.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/chapter/chapter_feedback_bar.dart';
import '../../widgets/pro/pro_access_feedback.dart';
import '../../widgets/question/choice_display_label.dart';
import '../../../router/app_routes.dart';
import '../../../router/solving_flow_exit.dart';
import '../../design/design.dart';
import '../../widgets/question/question_sections.dart';
import '../../widgets/question/question_solving_body.dart';
import '../../widgets/question/question_load_error_view.dart';
import '../../widgets/question/question_solving_skeleton.dart';

/// 문제 풀이 플로우 메인 페이지 (풀스크린).
///
/// 문제 묶음을 순서대로 풀고 마지막 제출 후 흐름(`QuestionFlow`)이 정한 곳으로 이동한다.
/// 토픽 챕터, 데일리 세트가 이 화면을 함께 쓴다.
class ChapterPage extends ConsumerStatefulWidget {
  final QuestionFlow flow;

  const ChapterPage({super.key, required this.flow});

  @override
  ConsumerState<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends ConsumerState<ChapterPage> {
  /// 선택지를 이미 준비한 questionUuid — 중복 준비 방지.
  final Set<String> _choiceInitializedUuids = {};

  /// 프로 접근 오류 안내를 이미 띄운 대상 — 같은 오류로 시트 반복 방지
  /// 상세 실패: questionUuid (다시 시도하면 지움), 선택지 생성 실패: 오류 이벤트 (다시 시도마다 새 이벤트)
  final Set<Object> _proAccessNoticedKeys = {};

  /// 이번 풀이의 세션 식별자. 화면이 다시 그려져도 바뀌지 않도록 상태에 둔다.
  final String _sessionUuid = const Uuid().v4();

  /// 마지막 문제 이후 완료 처리(점수 등록 등)가 진행 중인지. 중복 실행과 연타를 막는다.
  bool _isCompleting = false;

  /// 이 화면에서 답안을 한 번이라도 제출했는지. 벗어날 때 학습 현황을 갱신할지 정한다.
  bool _hasSubmittedAny = false;

  /// 온보딩 첫 문제 축하를 이미 띄웠는지. 이후 문제에는 배지·축하가 없다.
  bool _hasShownOnboardingCelebration = false;
  bool _isShowingOnboardingCelebration = false;

  /// dispose 시점에는 ref 를 쓸 수 없으므로 컨테이너를 미리 잡아 둔다.
  late final ProviderContainer _container;

  @override
  void initState() {
    super.initState();
    _container = ProviderScope.containerOf(context, listen: false);
    _clearOnboardingOnceListLoaded();
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

  /// 다음 문제 상세 미리 받기: 구독만 걸어 캐시 유지 (autoDispose), 넘길 때 로딩 없이 바로 표시
  /// 선택지 준비(SSE 생성)는 비용이 커서 그 문제로 넘어간 뒤에만 시작
  void _prefetchNextQuestionDetail(ChapterState chapter) {
    final nextQuestionUuid = _nextQuestionUuidOf(chapter);
    if (nextQuestionUuid == null) return;
    ref.listen(questionDetailProvider(nextQuestionUuid), (_, _) {});
  }

  /// 무료(결제 UI 대상) 제출 성공 > 다음 문제 상세 다시 받기
  /// 제출 전에 미리 받은 상세는 하루 한도 셈 이전 값 > 한도면 상세 403 > 넘어갈 때 시트 (§5-4)
  void _refetchNextQuestionDetailIfFree() {
    if (!ref.read(shouldShowProUiProvider)) return;
    final nextQuestionUuid = _nextQuestionUuidOf(
      ref.read(chapterProvider(widget.flow.id)),
    );
    if (nextQuestionUuid == null) return;
    ref.invalidate(questionDetailProvider(nextQuestionUuid));
  }

  /// 다음 문제 questionUuid (마지막 문제면 null)
  String? _nextQuestionUuidOf(ChapterState chapter) {
    final nextIndex = chapter.currentIndex + 1;
    if (nextIndex >= chapter.questionUuids.length) return null;
    return chapter.questionUuids[nextIndex];
  }

  /// 현재 문제 실패 1회 안내: 프로 접근 오류면 시트·토스트 > 시트로 프로가 됐을 때만 [onUnlockedPro]
  /// 현재 문제만 대상 (미리 받기 실패는 그 문제로 넘어왔을 때 여기서 안내, 풀이 도중 시트 금지 §4-5)
  void _showProAccessFeedbackOnce(
    Object noticeKey,
    Object error,
    VoidCallback onUnlockedPro,
  ) {
    if (!_proAccessNoticedKeys.add(noticeKey)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final feedbackResult = await showProAccessFeedback(context, ref, error);
      if (feedbackResult == ProAccessFeedbackResult.sheetUnlockedPro &&
          mounted) {
        onUnlockedPro();
      }
    });
  }

  /// 선택지 생성 연결 거부 1회 안내 (미리 받은 상세가 200 이어도 하루 한도는 선택지 받기에서 걸림)
  void _showChoiceGenerationFeedbackOnce(
    QuestionInteractionState interaction,
    QuestionInteractionNotifier interactionNotifier,
  ) {
    final sseError = interaction.sseError;
    final connectFailure = sseError?.connectFailure;
    if (sseError == null || connectFailure == null) return;
    _showProAccessFeedbackOnce(
      sseError,
      connectFailure,
      interactionNotifier.startSseGeneration,
    );
  }

  /// 현재 문제 상세 다시 받기 (오류 안내도 다시 가능)
  void _retryQuestionDetail(String questionUuid) {
    _proAccessNoticedKeys.remove(questionUuid);
    ref.invalidate(questionDetailProvider(questionUuid));
  }

  /// 제출: 선택 키 고정 > 서버 제출 > 결과 기록(성공) + 해설함 추가 또는 원인별 토스트(실패)
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
      // 실패 원인별 문구 (네트워크, 서버 오류, 입력 오류 등)
      if (mounted) showAppToast(context, exception.message);
      return;
    }
    if (!mounted || submitResult == null) return;

    _hasSubmittedAny = true;
    ref
        .read(chapterProvider(widget.flow.id).notifier)
        .recordSubmission(submitResult, selectedKey);
    _refetchNextQuestionDetailIfFree();
    _addExplanationEntry(
      questionUuid: currentUuid,
      result: submitResult,
      selectedKey: selectedKey,
      questionNumber: questionNumber,
      displayLabelByChoiceKey: displayLabelByChoiceKey,
    );
  }

  /// 해설함에 이번 제출 추가 > 미리보기용 해설 조회가 바로 시작되고 다음 문제로 가도 계속됨
  void _addExplanationEntry({
    required String questionUuid,
    required SubmitResult result,
    required String selectedKey,
    required int questionNumber,
    required Map<String, String> displayLabelByChoiceKey,
  }) {
    final request = ChoiceExplanationRequest.fromSubmission(
      questionUuid: questionUuid,
      result: result,
      selectedChoiceKey: selectedKey,
    );
    if (request == null) return;
    ref
        .read(aiExplanationSessionProvider.notifier)
        .addEntry(
          AiExplanationEntry(
            request: request,
            isCorrect: result.isCorrect,
            questionNumber: questionNumber,
            displayLabelByChoiceKey: displayLabelByChoiceKey,
            rationale: result.rationale,
          ),
        );
  }

  /// 현재 문제 제출의 해설함 항목 (세트를 몰라 해설이 없으면 null)
  AiExplanationEntry? _currentExplanationEntry(
    String questionUuid,
    ChapterState chapter,
  ) {
    final result = chapter.lastSubmitResult;
    if (!chapter.isAnswered || result == null) return null;
    final request = ChoiceExplanationRequest.fromSubmission(
      questionUuid: questionUuid,
      result: result,
      selectedChoiceKey: chapter.lastSelectedKey,
    );
    if (request == null) return null;
    return ref.watch(
      aiExplanationSessionProvider.select(
        (session) => session.entryById(request.id),
      ),
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
  Future<void> _goNext(ChapterState chapter) async {
    if (_isCompleting || _isShowingOnboardingCelebration) return;
    if (widget.flow.isOnboarding && !_hasShownOnboardingCelebration) {
      setState(() => _hasShownOnboardingCelebration = true);
      // 축하 화면이 뜨는 사이 [다음] 연타로 문제를 건너뛰지 않게 막는다.
      _isShowingOnboardingCelebration = true;
      await context.push<void>(
        AppRoutes.onboardingCelebration,
        extra: chapter.isLastQuestion,
      );
      _isShowingOnboardingCelebration = false;
      if (!mounted) return;
    }
    if (chapter.isLastQuestion) {
      _complete();
    } else {
      // 새 문제를 풀 때는 지난 해설 시트를 닫음 (해설함·백그라운드 조회는 유지)
      ref.read(aiExplanationSessionProvider.notifier).closePanel();
      ref.read(chapterProvider(widget.flow.id).notifier).nextQuestion();
    }
  }

  /// 마지막 문제까지 끝남 — 요약을 만들어 이후 처리는 흐름에 맡긴다.
  Future<void> _complete() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    final summary = ref
        .read(chapterProvider(widget.flow.id).notifier)
        .buildSummary(widget.flow.title);
    try {
      await widget.flow.onCompleted(context, ref, summary, _sessionUuid);
    } catch (exception, stackTrace) {
      // 완료 처리에서 예상 밖 오류가 나도 화면이 멈추지 않게 하고, 다시 시도할 수 있게 잠금을 푼다.
      reportIfUnexpectedFailure(
        exception,
        stackTrace,
        reason: 'chapterComplete:${widget.flow.id}',
      );
      if (mounted) showAppToast(context, '완료 처리에 실패했어요. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  @override
  void dispose() {
    // 챕터는 문제를 여러 번 제출하므로 매번이 아니라 화면을 벗어날 때 한 번만 갱신한다.
    // (중간에 나가도, 끝까지 풀고 결과 화면으로 가도 같은 경로를 탄다.)
    if (_hasSubmittedAny) refreshLearningData(_container.invalidate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flowId = widget.flow.id;
    final chapter = ref.watch(chapterProvider(flowId));

    // 로딩 중
    if (chapter.isLoadingList) {
      return PassqlStatusScaffold(
        title: widget.flow.title,
        leading: PassqlNavLeading.close,
        onLeadingTap: () => leaveSolvingFlow(context),
        body: PassqlStatusView.loading(),
      );
    }

    // 에러 또는 빈 목록
    if (chapter.listError != null || chapter.questionUuids.isEmpty) {
      return PassqlStatusScaffold(
        title: widget.flow.title,
        leading: PassqlNavLeading.close,
        onLeadingTap: () => leaveSolvingFlow(context),
        body: PassqlStatusView.error(
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

    _prefetchNextQuestionDetail(chapter);
    _showChoiceGenerationFeedbackOnce(interaction, interactionNotifier);

    // 한 문제라도 제출했거나 2번째 문제 이상이면 "풀이 시작"으로 본다.
    final hasStarted = chapter.currentIndex > 0 || chapter.isAnswered;
    final explanationEntry = _currentExplanationEntry(currentUuid, chapter);

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
      ),
      // 문제 교체: 옆으로 미끄러지며 바뀜 (문제마다 key), 같은 문제 안 로딩 > 내용은 페이드
      // 해설 시트는 본문 위에 떠서 하단 바를 가리지 않음 (다음 문제로 넘어가면 닫히고 해설함에서 다시 열 수 있음)
      body: AiExplanationDock(
        child: PassqlPageSlideSwitcher(
          child: KeyedSubtree(
            key: ValueKey(currentUuid),
            child: PassqlFadeSwitcher(
              child: detailAsync.when(
                loading: () =>
                    const QuestionSolvingSkeleton(key: ValueKey('loading')),
                error: (error, _) {
                  _showProAccessFeedbackOnce(
                    currentUuid,
                    error,
                    () => _retryQuestionDetail(currentUuid),
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
      // 하단 바 — 미제출: 제출 버튼 / 제출 완료: 피드백 바 / 프로 접근 사유 화면: 없음 (풀 문제 없음)
      // 문제 로딩 중에도 바 유지 (선택 전이라 제출 비활성), 교체 때 바가 깜빡이지 않게
      bottomNavigationBar:
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
              isLastQuestion: chapter.isLastQuestion,
              onNext: () => _goNext(chapter),
            ),
    );

    // 완료 처리(점수 등록)가 길어질 수 있어, 진행 중에는 화면을 잠그고 로딩을 보여준다.
    // 트리 모양을 고정한다. 완료 처리 여부로 Scaffold 의 부모가 바뀌면 피드백 바가 다시 만들어져 햅틱이 또 울린다.
    final body = Stack(
      children: [
        scaffold,
        if (_isCompleting) ...[
          ModalBarrier(
            dismissible: false,
            color: context.passqlColors.label.withValues(alpha: 0.2),
          ),
          const Center(
            child: PassqlLoadingIndicator(size: PassqlLoadingSize.blocking),
          ),
        ],
      ],
    );
    // 시스템 뒤로가기(Android 백 버튼, iOS 스와이프)도 홈 아이콘과 같은 확인을 거친다.
    return PopScope(
      canPop: !hasStarted,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await confirmChapterExit(context) && context.mounted) {
          leaveSolvingFlow(context);
        }
      },
      child: body,
    );
  }
}
