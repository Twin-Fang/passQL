import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/monitoring/crash_reporter.dart';
import '../../../presentation/flows/continuous_question_loader.dart';
import '../../../presentation/providers/ai_explanation_session_provider.dart';
import '../../../presentation/providers/chapter_providers.dart';
import '../../../presentation/providers/onboarding_providers.dart';
import '../../../router/app_routes.dart';
import '../../../router/solving_flow_exit.dart';
import '../../design/design.dart';
import '../../widgets/common/app_toast.dart';
import 'chapter_page.dart';

/// 문제 풀이 진행: 다음 문제 > (온보딩 축하) > 연속 흐름 이어 받기 > 완료(요약·흐름 처리) > 나가기
/// 화면 그리기·제출은 [ChapterPage] 상태가 맡음
mixin ChapterFlowProgression on ConsumerState<ChapterPage> {
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

  /// 온보딩 첫 문제 축하를 이미 띄웠는지. 이후 문제에는 배지·축하가 없다.
  bool _hasShownOnboardingCelebration = false;
  bool _isShowingOnboardingCelebration = false;

  bool get isWaitingMoreQuestions => _isWaitingMoreQuestions;

  bool get hasShownOnboardingCelebration => _hasShownOnboardingCelebration;

  /// 이번 풀이의 세션 식별자 (완료 처리에 넘김)
  String get sessionUuid;

  /// initState 에서 1회: 온보딩 대기 정리 감시 + 연속 흐름 이어 받기 감시
  void startFlowProgression() {
    _clearOnboardingOnceListLoaded();
    if (widget.flow.isContinuous) {
      _continuousQuestionLoader.listenToLoadMoreWhenRunningLow();
    }
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
  Future<void> goNext(ChapterState chapter) async {
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
        extra: (
          isLastQuestion: chapter.isLastQuestion,
          setQuestionCount: chapter.questionUuids.length,
        ),
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
  void leaveContinuousFlow() {
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
      await widget.flow.onCompleted(context, ref, summary, sessionUuid);
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
}
