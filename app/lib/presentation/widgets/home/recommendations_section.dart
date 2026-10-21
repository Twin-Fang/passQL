import 'package:flutter/cupertino.dart';
import '../../../core/utils/question_difficulty.dart';
import '../../../data/models/home/question_summary.dart';
import '../../design/design.dart';
import '../question/stem_text.dart';

/// 홈 화면 추천 문제 리스트.
/// 최대 3개 문제를 grouped 섹션 행으로 표시.
class RecommendationsSection extends StatelessWidget {
  final List<QuestionSummary> questions;
  final void Function(String questionUuid)? onQuestionTap;

  const RecommendationsSection({
    super.key,
    required this.questions,
    this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return const SizedBox.shrink();

    return PassqlGroupedSection(
      header: '추천 문제',
      children: [
        for (final question in questions)
          _QuestionRow(
            question: question,
            difficultyStars: toDifficultyStarText(question.difficulty),
            onTap: () => onQuestionTap?.call(question.questionUuid),
          ),
      ],
    );
  }
}

/// 난이도 별(★★☆☆☆) 글자 사이 간격
const double _difficultyStarSpacing = 2;

class _QuestionRow extends StatelessWidget {
  final QuestionSummary question;
  final String difficultyStars;
  final VoidCallback? onTap;

  const _QuestionRow({
    required this.question,
    required this.difficultyStars,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlPressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(PassqlSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 토픽 배지 + (최신 경향이면) 최신 경향 배지 (#523)
                  if (question.topicName != null || question.isLatestTrend)
                    Padding(
                      padding: const EdgeInsets.only(bottom: PassqlSpacing.xs),
                      child: Wrap(
                        spacing: PassqlSpacing.xs,
                        runSpacing: PassqlSpacing.xxs,
                        children: [
                          if (question.topicName != null)
                            PassqlBadge(text: question.topicName!),
                          if (question.isLatestTrend)
                            const PassqlLatestTrendBadge(),
                        ],
                      ),
                    ),
                  Text(
                    stripCodeFences(question.stemPreview ?? ''),
                    style: PassqlTypography.subheadline.copyWith(
                      color: colors.label,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: PassqlSpacing.xxs),
                  // 별 글리프 대신 '난이도 N / 5' 로 읽음
                  Semantics(
                    label:
                        '난이도 ${toClampedQuestionDifficulty(question.difficulty)} / $maximumQuestionDifficulty',
                    excludeSemantics: true,
                    child: Text(
                      difficultyStars,
                      style: PassqlTypography.caption.copyWith(
                        color: colors.warningText,
                        letterSpacing: _difficultyStarSpacing,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: PassqlSpacing.xs),
            Padding(
              padding: const EdgeInsets.only(top: PassqlSpacing.xxs),
              child: Icon(
                CupertinoIcons.chevron_forward,
                size: PassqlIconSize.xs,
                color: colors.tertiaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
