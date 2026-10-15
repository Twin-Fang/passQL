import 'package:flutter/cupertino.dart';
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

  String _difficultyStars(int? difficulty) {
    switch (difficulty) {
      case 1:
        return '★☆☆';
      case 2:
        return '★★☆';
      case 3:
        return '★★★';
      default:
        return '★☆☆';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return const SizedBox.shrink();

    return PassqlGroupedSection(
      header: '추천 문제',
      children: [
        for (final question in questions)
          _QuestionRow(
            question: question,
            difficultyStars: _difficultyStars(question.difficulty),
            onTap: () => onQuestionTap?.call(question.questionUuid),
          ),
      ],
    );
  }
}

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
                  if (question.topicName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: PassqlSpacing.xs),
                      child: PassqlBadge(text: question.topicName!),
                    ),
                  Text(
                    stripCodeFences(question.stemPreview ?? ''),
                    style: PassqlTypography.subheadline.copyWith(color: colors.label),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: PassqlSpacing.xxs),
                  Text(
                    difficultyStars,
                    style: PassqlTypography.caption.copyWith(
                      color: colors.warning,
                      letterSpacing: 2,
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
                size: 14,
                color: colors.tertiaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
