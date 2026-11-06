import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../router/app_routes.dart';
import '../../../router/result_route_arguments.dart';
import '../../design/design.dart';
import '../../providers/mock_exam_countdown.dart';
import '../../providers/mock_exam_session_notifier.dart';
import '../../providers/mock_exam_session_state.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/mock_exam/mock_exam_palette_sheet.dart';
import '../../widgets/mock_exam/mock_exam_question_view.dart';
import '../../widgets/mock_exam/mock_exam_timer_chip.dart';

/// 모의고사 풀이 (#866): 남은 시간·문항 이동·표시·번호판·제출, 시간 끝 자동 제출
/// 정답·해설·SQL 실행·광고 없음. 답은 보기 탭마다 서버 저장, 남은 시간은 서버 값 + 단조 시계
class MockExamSolvingPage extends ConsumerStatefulWidget {
  const MockExamSolvingPage({super.key, required this.attemptUuid});

  final String attemptUuid;

  @override
  ConsumerState<MockExamSolvingPage> createState() =>
      _MockExamSolvingPageState();
}

class _MockExamSolvingPageState extends ConsumerState<MockExamSolvingPage>
    with WidgetsBindingObserver {
  final ValueNotifier<int> _remainingSeconds = ValueNotifier(0);
  Timer? _tickTimer;
  Timer? _resyncTimer;
  int? _lastAnnouncedMinute;
  bool _isAutoSubmitStarted = false;
  bool _isLeavingToResult = false;

  MockExamSessionNotifier get _session =>
      ref.read(mockExamSessionProvider(widget.attemptUuid).notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tickTimer = Timer.periodic(_tickInterval, (_) => _onTick());
    _resyncTimer = Timer.periodic(_resyncInterval, (_) => _session.resync());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tickTimer?.cancel();
    _resyncTimer?.cancel();
    _remainingSeconds.dispose();
    super.dispose();
  }

  /// 앱 복귀: 서버와 다시 맞춤 (잠든 동안 흐른 시간·다른 기기 답 반영)
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) _session.resync();
  }

  /// 1초마다: 남은 시간 표시 > 스크린리더 알림 > 마감 지나면 자동 제출 1회
  void _onTick() {
    final session = ref
        .read(mockExamSessionProvider(widget.attemptUuid))
        .valueOrNull;
    if (session == null || session.isFinished) return;
    final countdown = _session.countdown;
    _remainingSeconds.value = countdown.remainingSeconds;
    _announceRemainingMinutes(countdown.remainingSeconds);
    if (!_isAutoSubmitStarted &&
        countdown.secondsPastDeadline >= mockExamAutoSubmitDelaySeconds) {
      _isAutoSubmitStarted = true;
      _submit();
    }
  }

  void _announceRemainingMinutes(int remainingSeconds) {
    for (final minute in mockExamAnnounceMinutes) {
      final isCrossing =
          remainingSeconds <= minute * 60 &&
          remainingSeconds > minute * 60 - _tickInterval.inSeconds;
      if (isCrossing && _lastAnnouncedMinute != minute) {
        _lastAnnouncedMinute = minute;
        SemanticsService.sendAnnouncement(
          View.of(context),
          '남은 시간 $minute분',
          TextDirection.ltr,
        );
      }
    }
  }

  Future<void> _submit() async {
    try {
      await _session.submit();
    } catch (error) {
      if (mounted) {
        showAppToast(
          context,
          error.asAppException.message,
          actionLabel: '다시 제출',
          onAction: _submit,
        );
      }
    }
  }

  Future<void> _confirmSubmit(MockExamSessionState session) async {
    final isConfirmed = await showPassqlConfirmDialog(
      context,
      title: '제출할까요?',
      message:
          '안 푼 문항 ${session.unansweredCount}개 · 표시한 문항 ${session.flaggedCount}개\n'
          '제출하면 답을 바꿀 수 없어요.',
      confirmLabel: '제출',
      isDestructive: false,
    );
    if (isConfirmed) await _submit();
  }

  Future<void> _confirmLeave() async {
    final isConfirmed = await showPassqlConfirmDialog(
      context,
      title: '시험을 잠시 나갈까요?',
      message: '시간은 계속 흘러요. 목록에서 이어 풀 수 있어요.',
      confirmLabel: '나가기',
      isDestructive: false,
    );
    if (isConfirmed && mounted) context.pop();
  }

  void _goToResult() {
    if (_isLeavingToResult) return;
    _isLeavingToResult = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.pushReplacement(
        AppRoutes.mockExamResult(widget.attemptUuid),
        extra: const MockExamSubmittedArguments(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(mockExamSessionProvider(widget.attemptUuid));
    final session = sessionAsync.valueOrNull;
    if (session != null && session.isFinished) _goToResult();
    if (session != null &&
        _remainingSeconds.value == 0 &&
        !session.isFinished) {
      _remainingSeconds.value = _session.countdown.remainingSeconds;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (isPopped, _) {
        if (!isPopped) _confirmLeave();
      },
      child: Scaffold(
        appBar: PassqlNavBar(
          leading: PassqlNavLeading.close,
          onLeadingTap: _confirmLeave,
          middle: session == null
              ? null
              : Text(
                  '${session.currentIndex + 1} / ${session.questions.length}',
                  style: PassqlTypography.headline.copyWith(
                    fontFeatures: PassqlTypography.tabular,
                  ),
                ),
          trailing: session == null
              ? null
              : _NavTrailing(
                  remainingSeconds: _remainingSeconds,
                  hasUnsyncedAnswer: session.hasUnsyncedAnswer,
                ),
        ),
        body: SafeArea(
          child: sessionAsync.when(
            loading: () => const PassqlStatusView.loading(),
            error: (error, _) => PassqlStatusView.error(
              message: error.asAppException.message,
              onRetry: () =>
                  ref.invalidate(mockExamSessionProvider(widget.attemptUuid)),
            ),
            data: (session) => session.isFinished || session.questions.isEmpty
                ? const PassqlStatusView.loading()
                : _SolvingBody(
                    session: session,
                    onChoiceTap: _session.selectChoice,
                    onPrevious: () => _session.goTo(session.currentIndex - 1),
                    onNext: () => _session.goTo(session.currentIndex + 1),
                    onToggleFlag: _session.toggleFlag,
                    onOpenPalette: () => showMockExamPaletteSheet(
                      context,
                      session: session,
                      onQuestionSelected: _session.goTo,
                      onSubmitRequested: () => _confirmSubmit(session),
                    ),
                    onSubmit: () => _confirmSubmit(session),
                  ),
          ),
        ),
      ),
    );
  }
}

/// 상단 바 오른쪽: 저장 안 됨 아이콘(있을 때) + 남은 시간 (1초마다 이 부분만 다시 그림)
class _NavTrailing extends StatelessWidget {
  const _NavTrailing({
    required this.remainingSeconds,
    required this.hasUnsyncedAnswer,
  });

  final ValueListenable<int> remainingSeconds;
  final bool hasUnsyncedAnswer;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasUnsyncedAnswer) ...[
          Semantics(
            label: '저장 안 된 답이 있어요. 연결되면 다시 저장해요',
            child: Icon(
              CupertinoIcons.cloud,
              size: PassqlIconSize.sm,
              color: colors.warningText,
            ),
          ),
          const SizedBox(width: PassqlSpacing.xs),
        ],
        ValueListenableBuilder<int>(
          valueListenable: remainingSeconds,
          builder: (_, seconds, _) =>
              MockExamTimerChip(remainingSeconds: seconds),
        ),
      ],
    );
  }
}

/// 문항 본문 + 하단 버튼 줄 (이전·표시·번호판·다음 또는 제출)
class _SolvingBody extends StatelessWidget {
  const _SolvingBody({
    required this.session,
    required this.onChoiceTap,
    required this.onPrevious,
    required this.onNext,
    required this.onToggleFlag,
    required this.onOpenPalette,
    required this.onSubmit,
  });

  final MockExamSessionState session;
  final void Function(String choiceKey) onChoiceTap;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToggleFlag;
  final VoidCallback onOpenPalette;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final question = session.currentQuestion;
    final answer = session.answerOf(question.questionNumber);
    return Column(
      children: [
        Expanded(
          child: PassqlPageSlideSwitcher(
            child: SingleChildScrollView(
              key: ValueKey(question.questionNumber),
              padding: const EdgeInsets.only(bottom: PassqlSpacing.xl),
              child: MockExamQuestionView(
                questionNumber: question.questionNumber,
                subject: question.subject,
                topicName: question.topicName,
                stem: question.stem,
                schemaTables: question.schemaTables,
                choices: question.choices,
                isFlagged: answer.isFlagged,
                choiceStateOf: (choice) =>
                    choice.key == answer.selectedChoiceKey
                    ? PassqlChoiceState.selected
                    : PassqlChoiceState.idle,
                onChoiceTap: (choice) => onChoiceTap(choice.key),
              ),
            ),
          ),
        ),
        PassqlBottomActionBar(
          actions: [
            Row(
              children: [
                Expanded(
                  child: PassqlButton(
                    label: '이전',
                    variant: PassqlButtonVariant.tinted,
                    size: PassqlButtonSize.regular,
                    onPressed: session.isFirstQuestion ? null : onPrevious,
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xs),
                Expanded(
                  child: PassqlButton(
                    label: answer.isFlagged ? '표시됨' : '표시',
                    variant: PassqlButtonVariant.tinted,
                    size: PassqlButtonSize.regular,
                    onPressed: onToggleFlag,
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xs),
                Expanded(
                  child: PassqlButton(
                    label: '번호판',
                    variant: PassqlButtonVariant.tinted,
                    size: PassqlButtonSize.regular,
                    onPressed: onOpenPalette,
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xs),
                Expanded(
                  child: PassqlButton(
                    label: session.isLastQuestion ? '제출' : '다음',
                    size: PassqlButtonSize.regular,
                    isLoading: session.isSubmitting,
                    onPressed: session.isLastQuestion ? onSubmit : onNext,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// 남은 시간 표시 주기
const Duration _tickInterval = Duration(seconds: 1);
// 서버와 다시 맞추는 주기 (다른 기기 답·기기 잠듦 보정)
const Duration _resyncInterval = Duration(seconds: 30);
