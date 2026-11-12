import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/question/execute_result.dart';
import '../../design/design.dart';
import '../../providers/lock_screen_question_providers.dart';
import '../../providers/plan_providers.dart';
import '../pro/locked_preview_samples.dart';
import '../question/choice_display_label.dart';
import '../question/choice_item_card.dart';
import '../question/execute_result_card.dart';
import '../question/question_sections.dart';
import '../question/sse_loading_widget.dart';

/// 잠금화면 문제 본문 (실제 잠금화면·미리보기 공통): 캡션 > 태그 > 지문 카드 > 보기(탭 = 제출) > 채점 마크·실행 결과·해설
/// 실행형 결과: 정답 실행 결과가 오면 표, 무료라 빠졌으면 흐린 표 + PRO로 결과 보기([onExecutionResultUnlock])
class LockScreenQuestionView extends ConsumerStatefulWidget {
  const LockScreenQuestionView({
    super.key,
    required this.state,
    required this.onChoiceTap,
    required this.onExecutionResultUnlock,
    this.caption = defaultCaption,
  });

  static const String defaultCaption = '오늘의 잠금 문제';

  final LockScreenQuestionState state;
  final ValueChanged<String> onChoiceTap;
  final VoidCallback onExecutionResultUnlock;
  final String caption;

  @override
  ConsumerState<LockScreenQuestionView> createState() =>
      _LockScreenQuestionViewState();
}

class _LockScreenQuestionViewState
    extends ConsumerState<LockScreenQuestionView> {
  // 무료 응답에서 실행 결과가 빠졌다는 표시 (서버 lockedSections 값)
  static const String _executionResultSection = 'EXECUTION_RESULT';

  final GlobalKey _resultKey = GlobalKey();

  @override
  void didUpdateWidget(covariant LockScreenQuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 채점 직후 결과 자리를 화면 안으로
    if (oldWidget.state.submitResult == null &&
        widget.state.submitResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealResult());
    }
  }

  void _revealResult() {
    final resultContext = _resultKey.currentContext;
    if (resultContext == null || !mounted) return;
    Scrollable.ensureVisible(
      resultContext,
      duration: PassqlMotion.durationOf(context, PassqlMotion.standard),
      curve: PassqlMotion.curve,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final state = widget.state;
    final question = state.question;
    if (question == null) return const SizedBox.shrink();
    final topicName = question.topicName;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: PassqlSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 캡션 + 주제 태그
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PassqlSpacing.md,
              PassqlSpacing.xs,
              PassqlSpacing.md,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.caption,
                    style: PassqlTypography.footnote.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ),
                if (topicName != null && topicName.isNotEmpty)
                  PassqlBadge(text: topicName, kind: PassqlBadgeKind.neutral),
              ],
            ),
          ),
          QuestionStem(
            stem: question.stem,
            schemaTables: question.schemaTables,
          ),
          // AI 선택지 생성 대기: 선택지 자리에 기존 생성 로딩
          if (state.isGeneratingChoices)
            const SseLoadingWidget(statusMessage: 'AI가 선택지를 만드는 중이에요'),
          for (final (displayIndex, choice) in state.choices.indexed)
            ChoiceItemCard(
              item: choice,
              displayLabel: toChoiceDisplayLabel(displayIndex),
              state: resolveChoiceState(
                key: choice.key,
                selectedKey: state.selectedKey,
                result: state.submitResult,
              ),
              onTap: () => widget.onChoiceTap(choice.key),
              isRunning: state.isSubmitting && state.selectedKey == choice.key,
            ),
          if (state.submitErrorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PassqlSpacing.md,
                vertical: PassqlSpacing.xs,
              ),
              child: PassqlKeepAllText(
                state.submitErrorMessage!,
                style: PassqlTypography.footnote.copyWith(
                  color: colors.wrongText,
                ),
              ),
            ),
          if (state.submitResult != null)
            KeyedSubtree(key: _resultKey, child: _buildGradedSection(context)),
        ],
      ),
    );
  }

  /// 채점 뒤: 정답/오답 마크 > (실행형) 실행 결과 표 또는 잠금 > 해설 한 단락
  Widget _buildGradedSection(BuildContext context) {
    final colors = context.passqlColors;
    final state = widget.state;
    final result = state.submitResult!;
    final rationale = result.rationale?.trim();
    return PassqlReveal(
      index: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          PassqlSpacing.sm,
          PassqlSpacing.md,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: PassqlPopIn(
                child: PassqlResultMark(isCorrect: result.isCorrect),
              ),
            ),
            if (state.isExecutable) ...[
              const SizedBox(height: PassqlSpacing.sm),
              _buildExecutionResult(context, result.correctResult),
            ],
            if (rationale != null && rationale.isNotEmpty) ...[
              const SizedBox(height: PassqlSpacing.sm),
              PassqlCard(
                child: PassqlKeepAllText(
                  rationale,
                  style: PassqlTypography.explanationBody.copyWith(
                    color: colors.label,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 실행 결과: 정답 실행 결과 표 > 무료(빠짐) 흐린 표 + PRO로 결과 보기 > 둘 다 아니면 없음
  Widget _buildExecutionResult(
    BuildContext context,
    ExecuteResult? correctResult,
  ) {
    if (correctResult != null) {
      return ExecuteResultCard(
        result: correctResult,
        subjectLabel: '정답 SQL',
        margin: EdgeInsets.zero,
      );
    }
    final isLocked =
        widget.state.submitResult!.lockedSections.contains(
          _executionResultSection,
        ) ||
        ref.watch(shouldShowProUiProvider);
    if (!isLocked) return const SizedBox.shrink();
    return PassqlLockedPreview(
      preview: const ExecutionResultLockedSample(),
      caption: LockedPreviewCaptions.lockScreenExecutionResult,
      unlockButtonLabel: 'PRO로 결과 보기',
      onUnlock: widget.onExecutionResultUnlock,
    );
  }
}
