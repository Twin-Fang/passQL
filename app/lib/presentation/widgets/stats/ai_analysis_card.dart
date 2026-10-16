import 'package:flutter/cupertino.dart';

import '../../../data/models/progress/ai_comment_response.dart';
import '../../design/design.dart';
import '../question/markdown_lite_text.dart';

/// AI 영역 분석 카드: 반짝이 머리 + 단어 순차 등장 (웹 StatsAnalysisCard 와 같은 연출)
/// aiComment 가 null 이면 숨김
class AiAnalysisCard extends StatelessWidget {
  final AiCommentResponse? aiComment;

  const AiAnalysisCard({super.key, required this.aiComment});

  @override
  Widget build(BuildContext context) {
    final comment = aiComment?.comment;
    if (comment == null) return const SizedBox.shrink();

    return PassqlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PassqlAiHeader(title: 'AI 영역 분석'),
          const SizedBox(height: PassqlSpacing.sm),
          // AI 코멘트의 `토픽명` 같은 마크다운 기호를 강조 표시로 바꿔 보여 준다.
          MarkdownLiteText(comment, isAnimated: true),
        ],
      ),
    );
  }
}

/// AI 코멘트를 기다리는 동안의 자리: 머리 + 글 3줄 (실제 카드와 비슷한 높이)
class AiAnalysisCardSkeleton extends StatelessWidget {
  const AiAnalysisCardSkeleton({super.key});

  // 글 줄 높이와 줄별 너비 비율 (웹 스켈레톤 100% / 83% / 67%)
  static const double _lineHeight = 12;
  static const double _titleWidth = 96;
  static const List<double> _lineWidthFactors = [1, 0.83, 0.67];

  @override
  Widget build(BuildContext context) {
    return PassqlCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              PassqlSkeletonBox(
                width: PassqlSize.iconTile,
                height: PassqlSize.iconTile,
                radius: PassqlRadius.iconTile,
              ),
              SizedBox(width: PassqlSpacing.xs),
              PassqlSkeletonBox(width: _titleWidth, height: _lineHeight),
            ],
          ),
          const SizedBox(height: PassqlSpacing.sm),
          for (final widthFactor in _lineWidthFactors) ...[
            FractionallySizedBox(
              widthFactor: widthFactor,
              child: const PassqlSkeletonBox(height: _lineHeight),
            ),
            const SizedBox(height: PassqlSpacing.xs),
          ],
        ],
      ),
    );
  }
}
