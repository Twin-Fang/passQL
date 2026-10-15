import 'package:flutter/cupertino.dart';

import '../../../data/models/progress/ai_comment_response.dart';
import '../../design/design.dart';
import '../question/markdown_lite_text.dart';

/// AI 영역 분석 카드.
/// /progress/ai-comment API 응답을 그대로 표시.
/// aiComment가 null이면 카드 숨김 처리.
class AiAnalysisCard extends StatelessWidget {
  final AiCommentResponse? aiComment;

  const AiAnalysisCard({super.key, required this.aiComment});

  @override
  Widget build(BuildContext context) {
    final comment = aiComment?.comment;

    // AI 코멘트 없으면 카드 숨김
    if (comment == null) return const SizedBox.shrink();

    return PassqlCard(
      title: 'AI 영역 분석',
      trailing: PassqlIconTile(
        icon: CupertinoIcons.sparkles,
        color: context.passqlColors.accent,
      ),
      // AI 코멘트의 `토픽명` 같은 마크다운 기호를 강조 표시로 바꿔 보여 준다.
      child: MarkdownLiteText(comment),
    );
  }
}
