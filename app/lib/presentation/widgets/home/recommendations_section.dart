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
                difficultyStars: toDifficultyStarText(questions[i].difficulty),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 토픽 배지 + (최신 경향이면) 최신 경향 배지 (#523)
          Wrap(
            spacing: PassqlSpacing.xs,
            runSpacing: PassqlSpacing.xxs,
            children: [
              if (question.topicName != null)
                PassqlBadge(text: question.topicName!),
              if (question.isLatestTrend) const PassqlLatestTrendBadge(),
            ],
          ),
          const SizedBox(height: PassqlSpacing.xs),
          Text(
            stripCodeFences(question.stemPreview ?? ''),
            style: PassqlTypography.subheadline.copyWith(color: colors.label),
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
    );
  }
}
