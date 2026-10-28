import 'package:flutter/cupertino.dart';
import '../../../core/utils/question_difficulty.dart';
import '../../../data/models/question/question_detail.dart';
import '../../../data/models/question/sse_event.dart';
import '../../providers/question_providers.dart';
import '../../design/design.dart';
import 'stem_text.dart';

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
