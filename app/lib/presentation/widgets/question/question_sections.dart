import 'package:flutter/cupertino.dart';
import '../../../core/utils/question_difficulty.dart';
import '../../../data/models/question/choice_item.dart';
import '../../../data/models/question/question_detail.dart';
import '../../../data/models/question/sse_event.dart';
import '../../../data/models/question/submit_result.dart';
import '../../providers/question_providers.dart';
import '../../design/design.dart';
import 'choice_item_card.dart';
import 'reveal_above_bottom_bar.dart';
import 'sse_loading_widget.dart';
import 'stem_text.dart';
import 'choice_display_label.dart';

// 챕터 풀이(ChapterPage)와 단건 풀이(QuestionDetailPage)가 함께 쓰는 문제 화면 조각.

/// 난이도 별 + 실행 모드 뱃지 + (최신 경향이면) 최신 경향 뱃지 + (있으면) 소주제 제목.
class QuestionHeader extends StatelessWidget {
  final QuestionDetail question;
  const QuestionHeader({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final difficulty = toClampedQuestionDifficulty(question.difficulty);
    final isExecutable = question.executionMode == 'EXECUTABLE';
    final title = question.subtopicName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.md,
        PassqlSpacing.md,
        PassqlSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 난이도 표시는 색만이 아니라 채움 여부(별 모양)로도 구분된다.
              Semantics(
                label: '난이도 $difficulty / $maximumQuestionDifficulty',
                excludeSemantics: true,
                child: Row(
                  children: List.generate(
                    maximumQuestionDifficulty,
                    (i) => Icon(
                      i < difficulty
                          ? CupertinoIcons.star_fill
                          : CupertinoIcons.star,
                      size: PassqlIconSize.sm,
                      color: i < difficulty
                          ? colors.warning
                          : colors.tertiaryLabel,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: PassqlSpacing.xs),
              PassqlBadge(
                // 눌러서 실행하는 버튼으로 보이지 않게 재생 아이콘 없이 유형만 표시
                text: isExecutable ? '실행 결과 문제' : '개념 문제',
                kind: isExecutable
                    ? PassqlBadgeKind.topic
                    : PassqlBadgeKind.neutral,
                icon: isExecutable
                    ? CupertinoIcons.table
                    : CupertinoIcons.book_fill,
              ),
              // 최신 출제 경향 반영 문제 (#523)
              if (question.isLatestTrend) ...[
                const SizedBox(width: PassqlSpacing.xs),
                const PassqlLatestTrendBadge(),
              ],
            ],
          ),
          if (title != null && title.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.xs),
            Text(
              title,
              style: PassqlTypography.title3.copyWith(color: colors.label),
            ),
          ],
        ],
      ),
    );
  }
}

/// 문제 지문 카드.
class QuestionStem extends StatelessWidget {
  final String stem;
  const QuestionStem({super.key, required this.stem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.md,
        vertical: PassqlSpacing.xs,
      ),
      child: PassqlCard(child: StemText(stem)),
    );
  }
}

/// 선택지 영역: 생성 중 로딩 / 생성 오류 / 선택지 목록.
/// [submitResult]가 있으면 채점 결과를 선택지 상태에 반영한다.
class QuestionChoices extends StatelessWidget {
  final QuestionInteractionState interaction;
  final QuestionInteractionNotifier notifier;
  final bool isExecutable;
  final SubmitResult? submitResult;

  /// 채점 뒤 선택 키. 채점 뒤 탭은 선택 상태를 바꾸므로 화면 표시는 제출 당시 키로 고정한다.
  final String? gradedSelectedKey;

  /// true면 재시도가 불가능한 오류여도 "다시 시도"를 보여 막다른 길을 만들지 않는다.
  final bool shouldAlwaysAllowRetry;

  const QuestionChoices({
    super.key,
    required this.interaction,
    required this.notifier,
    required this.isExecutable,
    this.submitResult,
    this.gradedSelectedKey,
    this.shouldAlwaysAllowRetry = false,
  });

  @override
  Widget build(BuildContext context) {
    if (interaction.isGeneratingChoices) {
      return SseLoadingWidget(
        statusMessage: interaction.sseStatusMessage ?? '선택지 생성 중...',
      );
    }

    final error = interaction.sseError;
    if (error != null) {
      return QuestionSseError(
        error: error,
        onRetry: shouldAlwaysAllowRetry || error.isRetryable
            ? () => notifier.startSseGeneration()
            : null,
      );
    }

    if (interaction.activeChoices.isEmpty) {
      // 세트 준비 전(첫 프레임)은 비워 두고, 준비됐는데 선택지가 0개면 안내 + 새로 만들기
      if (interaction.activeChoiceSetId == null) return const SizedBox.shrink();
      return PassqlStatusView.error(
        message: '이 문제의 선택지가 비어 있어요',
        onRetry: () => notifier.startSseGeneration(),
      );
    }

    final hasRunnableChoice =
        isExecutable &&
        interaction.activeChoices.any((choice) => choice.kind == 'SQL');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 실행형 보기 안내: 보기를 실제 DB 에서 돌려 볼 수 있음 (채점 전만, #727)
        if (hasRunnableChoice && submitResult == null) const _RunChoiceHint(),
        for (final (displayIndex, item) in interaction.activeChoices.indexed)
          // 채점 직후 정답 보기를 하단 피드백 바 위로 (#551)
          RevealAboveBottomBarOnTrigger(
            shouldReveal: item.key == submitResult?.correctKey,
            child: _buildChoiceCard(displayIndex, item),
          ),
      ],
    );
  }

  /// 보기 카드 1개: 탭은 고르기, 실행형 SQL 보기는 ▶ 실행 버튼 (채점 뒤 카드 탭도 실행)
  Widget _buildChoiceCard(int displayIndex, ChoiceItem item) {
    final isRunnable = isExecutable && item.kind == 'SQL';
    void runThisChoice() =>
        notifier.runChoice(choiceKey: item.key, sql: item.body);
    return ChoiceItemCard(
      item: item,
      displayLabel: toChoiceDisplayLabel(displayIndex),
      state: resolveChoiceState(
        key: item.key,
        selectedKey: submitResult != null
            ? gradedSelectedKey
            : interaction.selectedChoiceKey,
        result: submitResult,
      ),
      onTap: () => notifier.selectChoice(item.key),
      // 채점 뒤에도 다른 선택지의 SQL 실행 결과를 볼 수 있게 한다(채점 표시는 그대로).
      onGradedTap: submitResult != null && isRunnable ? runThisChoice : null,
      onRunTap: isRunnable ? runThisChoice : null,
      isRunning:
          interaction.isExecuting && interaction.executedChoiceKey == item.key,
    );
  }
}

/// 실행형 문제 보기 위 한 줄 안내: ▶ 아이콘 + 실제 DB 실행 설명
class _RunChoiceHint extends StatelessWidget {
  const _RunChoiceHint();

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.xs,
        PassqlSpacing.md,
        PassqlSpacing.xxs,
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.play_circle_fill,
            size: PassqlIconSize.md,
            color: colors.accentText,
          ),
          const SizedBox(width: PassqlSpacing.xs),
          Expanded(
            child: Text(
              '보기마다 실행을 누르면 실제 DB 에서 결과를 볼 수 있어요',
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 선택지 생성 실패 안내.
class QuestionSseError extends StatelessWidget {
  final SseErrorEvent error;
  final VoidCallback? onRetry;

  const QuestionSseError({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.md,
        vertical: PassqlSpacing.xs,
      ),
      child: PassqlCard(
        child: Row(
          children: [
            const Expanded(
              child: PassqlResultMark(isCorrect: false, label: '선택지를 만들지 못했어요'),
            ),
            if (onRetry != null)
              PassqlButton(
                label: '다시 시도',
                onPressed: onRetry,
                variant: PassqlButtonVariant.plain,
                size: PassqlButtonSize.small,
                isFullWidth: false,
              ),
          ],
        ),
      ),
    );
  }
}

/// 제출 전 하단 바. 선택지를 고르고 선택지 세트가 있을 때만 활성화된다.
class QuestionSubmitBar extends StatelessWidget {
  final QuestionInteractionState interaction;
  final VoidCallback onSubmit;

  const QuestionSubmitBar({
    super.key,
    required this.interaction,
    required this.onSubmit,
  });

  bool get _canSubmit =>
      interaction.selectedChoiceKey != null &&
      interaction.activeChoiceSetId != null &&
      !interaction.isSubmitting;

  @override
  Widget build(BuildContext context) {
    return PassqlBottomActionBar(
      actions: [
        PassqlButton(
          label: '제출',
          onPressed: _canSubmit ? onSubmit : null,
          isLoading: interaction.isSubmitting,
        ),
      ],
    );
  }
}
