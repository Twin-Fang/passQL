import 'package:flutter/cupertino.dart';

import '../../../data/models/question/choice_item.dart';
import '../../../data/models/question/submit_result.dart';
import '../../design/design.dart';
import '../../providers/question_providers.dart';
import 'choice_display_label.dart';
import 'choice_item_card.dart';
import 'question_sections.dart';
import 'reveal_above_bottom_bar.dart';
import 'sse_loading_widget.dart';

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
        // 실행형 보기 안내: 채점 전 > 제출하면 실행 가능, 채점 뒤 > 실행 아이콘 안내 (#727)
        if (hasRunnableChoice) _RunChoiceHint(isGraded: submitResult != null),
        for (final (displayIndex, item) in interaction.activeChoices.indexed)
          // 채점 직후 정답 보기를 하단 피드백 바 위로 (#551)
          RevealAboveBottomBarOnTrigger(
            shouldReveal: item.key == submitResult?.correctKey,
            child: _buildChoiceCard(displayIndex, item),
          ),
      ],
    );
  }

  /// 보기 카드 1개: 탭은 고르기, 채점 뒤 실행형 SQL 보기는 카드 탭·▶ 아이콘으로 실행
  /// 채점 전 실행 막음 (결과를 묻는 문제라 실행하면 정답이 보임)
  Widget _buildChoiceCard(int displayIndex, ChoiceItem item) {
    final isRunnable =
        isExecutable && item.kind == 'SQL' && submitResult != null;
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
      onGradedTap: isRunnable ? runThisChoice : null,
      onRunTap: isRunnable ? runThisChoice : null,
      isRunning:
          interaction.isExecuting && interaction.executedChoiceKey == item.key,
    );
  }
}

/// 실행형 문제 보기 위 한 줄 안내: ▶ 아이콘 + 실제 DB 실행 설명 (채점 전·후 문구 다름)
class _RunChoiceHint extends StatelessWidget {
  const _RunChoiceHint({required this.isGraded});

  final bool isGraded;

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
              isGraded
                  ? '보기를 누르면 실제 DB 에서 실행한 결과를 볼 수 있어요'
                  : '제출하면 보기마다 실제 DB 에서 실행해 볼 수 있어요',
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
