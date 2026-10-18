import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 해설 한 문장: 굵게(`**`)·인라인 코드(`` ` ``)만 꾸미고 줄 수 제한 가능 (미리보기 말줄임)
/// 여러 줄·목록 마크다운은 MarkdownLiteText 가 그림
class AiExplanationInlineText extends StatelessWidget {
  const AiExplanationInlineText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
  });

  final String text;

  /// 기본: 해설 본문 + 기본 글자색
  final TextStyle? style;

  /// null 이면 제한 없음, 넘치면 말줄임
  final int? maxLines;

  static final RegExp _inlinePattern = RegExp(r'\*\*(.+?)\*\*|`([^`\n]+)`');

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final baseStyle =
        style ?? PassqlTypography.explanationBody.copyWith(color: colors.label);
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _inlinePattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final boldText = match.group(1);
      spans.add(
        boldText != null
            ? TextSpan(
                text: boldText,
                style: baseStyle.copyWith(
                  fontFamily: PassqlTypography.subheadlineSemibold.fontFamily,
                ),
              )
            : TextSpan(
                text: match.group(2),
                style: PassqlTypography.inlineCodeOf(
                  baseStyle,
                ).copyWith(backgroundColor: colors.fill),
              ),
      );
      cursor = match.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}
