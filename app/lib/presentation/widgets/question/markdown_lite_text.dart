import 'package:flutter/material.dart';

import '../../design/design.dart';

/// AI 해설이 쓰는 마크다운 일부(굵게 `**`, 인라인 코드 `` ` ``, 목록 `* `/`- `)만 그리는 가벼운 위젯.
/// 전체 마크다운 패키지를 들이지 않고, 해설에 실제로 나오는 표기만 처리한다.
class MarkdownLiteText extends StatelessWidget {
  const MarkdownLiteText(this.text, {super.key});

  final String text;

  static final RegExp _bulletRe = RegExp(r'^\s*[*-]\s+(.*)$');
  static final RegExp _inlineRe = RegExp(r'\*\*(.+?)\*\*|`([^`\n]+)`');

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final base = PassqlTypography.explanationBody.copyWith(color: colors.label);
    final lines = text.replaceAll('\r\n', '\n').split('\n');
    final children = <Widget>[];
    for (final line in lines) {
      if (line.trim().isEmpty) {
        // 연속 빈 줄이 여러 번 간격을 만들지 않게 한 번만 둔다.
        if (children.isNotEmpty && children.last is! SizedBox) {
          children.add(const SizedBox(height: PassqlSpacing.sm));
        }
        continue;
      }
      final bullet = _bulletRe.firstMatch(line);
      if (bullet != null) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: PassqlSpacing.xxs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: PassqlSpacing.md,
                  child: Text('•', style: base),
                ),
                Expanded(child: _rich(bullet.group(1)!, base, colors)),
              ],
            ),
          ),
        );
      } else {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: PassqlSpacing.xxs),
            child: _rich(line, base, colors),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _rich(String line, TextStyle base, PassqlColors colors) {
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _inlineRe.allMatches(line)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: line.substring(cursor, match.start)));
      }
      if (match.group(1) != null) {
        spans.add(
          TextSpan(
            text: match.group(1),
            style: PassqlTypography.explanationEmphasis.copyWith(
              color: colors.label,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: match.group(2),
            style: PassqlTypography.code.copyWith(
              fontSize: (base.fontSize ?? 14) * 0.92,
              backgroundColor: colors.fill,
            ),
          ),
        );
      }
      cursor = match.end;
    }
    if (cursor < line.length) spans.add(TextSpan(text: line.substring(cursor)));
    return Text.rich(TextSpan(style: base, children: spans));
  }
}
