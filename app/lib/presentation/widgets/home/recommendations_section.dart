import 'package:flutter/cupertino.dart';
import '../../../core/utils/question_difficulty.dart';
import '../../../data/models/home/question_summary.dart';
import '../../design/design.dart';
import '../question/stem_text.dart';

/// 홈 화면 추천 문제 리스트.
/// 최대 3개 문제를 구간 면 안 행으로 표시.
class RecommendationsSection extends StatelessWidget {
  final List<QuestionSummary> questions;
  final void Function(String questionUuid)? onQuestionTap;

  /// 구간 맨 아래 '더 보기' (추천 3개 다음 이어 풀 곳, 토스 증권 목록 끝 더 보기와 같은 모양)
  final VoidCallback? onViewMore;

  const RecommendationsSection({
    super.key,
    required this.questions,
    this.onQuestionTap,
    this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return const SizedBox.shrink();

    final colors = context.passqlColors;
    return PassqlSection(
      title: '추천 문제',
      // 행 폭을 구간 끝까지: 문장이 짧은 행도 왼쪽에 붙게 (기본 가운데 정렬이면 짧은 행만 가운데로 밀림)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < questions.length; i++) ...[
            // 같은 구간 안 행 사이 헤어라인
            if (i > 0)
              Container(height: PassqlSize.hairline, color: colors.separator),
            // 행 사이에만 위아래 sm: 첫 행 위·마지막 행 아래는 구간 여백이 맡아 다른 구간과 간격을 맞춤
            Padding(
              padding: EdgeInsets.only(
                top: i > 0 ? PassqlSpacing.sm : 0,
                bottom: i < questions.length - 1 ? PassqlSpacing.sm : 0,
              ),
              child: _QuestionRow(
                question: questions[i],
                onTap: () => onQuestionTap?.call(questions[i].questionUuid),
              ),
            ),
          ],
          if (onViewMore != null) ...[
            const SizedBox(height: PassqlSpacing.sm),
            Container(height: PassqlSize.hairline, color: colors.separator),
            PassqlPressable(
              onTap: onViewMore,
              semanticLabel: '추천 문제 더 보기',
              child: SizedBox(
                height: PassqlSize.minTouchTarget,
                child: Center(
                  child: Text(
                    '더 보기',
                    // 회색이라 흐려 보여 굵기로 누르는 글자임을 드러냄
                    style: PassqlTypography.subheadlineSemibold.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  final QuestionSummary question;
  final VoidCallback? onTap;

  const _QuestionRow({required this.question, this.onTap});

  /// 난이도 앞 메타 글자: "SQL 기본 | 최신 경향" (없는 항목 생략, #523)
  static String _metaTextOf(QuestionSummary question) =>
      [?question.topicName, if (question.isLatestTrend) '최신 경향'].join(' | ');

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final metaStyle = PassqlTypography.footnote.copyWith(
      color: colors.secondaryLabel,
    );
    final metaText = _metaTextOf(question);
    final difficultyLevel = toQuestionDifficultyLevel(question.difficulty);
    final hasMetaLine = metaText.isNotEmpty || difficultyLevel != null;
    return PassqlPressable(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 위 회색 메타 한 줄: "SQL 기본 | 최신 경향 | ━━─ 어려움" (칩 없이, 풀이 머리와 같은 모양, #1147)
          if (hasMetaLine) ...[
            Text.rich(
              TextSpan(
                style: metaStyle,
                children: [
                  TextSpan(text: metaText),
                  if (difficultyLevel != null) ...[
                    if (metaText.isNotEmpty) const TextSpan(text: ' | '),
                    PassqlDifficultyIndicator.spanOf(
                      difficultyLevel,
                      metaStyle,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: PassqlSpacing.xxs),
          ],
          Text(
            stripCodeFences(question.stemPreview ?? ''),
            style: PassqlTypography.subheadline.copyWith(color: colors.label),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
