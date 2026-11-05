import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import 'concept_markdown_body.dart';
import 'concept_reading_parser.dart';

/// 자주 헷갈리는 점 1장 (#835): 주의색 강조 상자 > 굵은 첫 문장 제목 > 나머지 본문(글·표·코드)
class ConceptPitfallCard extends StatelessWidget {
  const ConceptPitfallCard({
    super.key,
    required this.order,
    required this.pitfall,
  });

  final int order;
  final ConceptPitfall pitfall;

  // 제목 속 인라인 코드 (`코드`)
  static final RegExp _inlineCodeRe = RegExp(r'`([^`\n]+)`');

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final titleStyle = PassqlTypography.articleEmphasis.copyWith(
      color: colors.label,
    );
    return PassqlCallout(
      kind: PassqlCalloutKind.warning,
      icon: CupertinoIcons.exclamationmark_triangle_fill,
      label: '헷갈리는 점 $order',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              style: titleStyle,
              children: _titleSpans(pitfall.title, titleStyle, colors),
            ),
          ),
          if (pitfall.bodyMd.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.xs),
            ConceptMarkdownBody(pitfall.bodyMd),
          ],
        ],
      ),
    );
  }

  /// 제목 > 일반 글자·인라인 코드 조각 (굵은 제목 안 백틱이 그대로 보이지 않게)
  List<InlineSpan> _titleSpans(
    String title,
    TextStyle titleStyle,
    PassqlColors colors,
  ) {
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _inlineCodeRe.allMatches(title)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: title.substring(cursor, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: PassqlTypography.inlineCodeOf(
            titleStyle,
          ).copyWith(backgroundColor: colors.fill),
        ),
      );
      cursor = match.end;
    }
    if (cursor < title.length) {
      spans.add(TextSpan(text: title.substring(cursor)));
    }
    return spans;
  }
}
