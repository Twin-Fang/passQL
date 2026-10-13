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
    final c = context.pq;
    final base = PqType.subheadline.copyWith(color: c.label, height: 1.6);
    final lines = text.replaceAll('\r\n', '\n').split('\n');
    final children = <Widget>[];
    for (final line in lines) {
      if (line.trim().isEmpty) {
        // 연속 빈 줄이 여러 번 간격을 만들지 않게 한 번만 둔다.
        if (children.isNotEmpty && children.last is! SizedBox) {
          children.add(const SizedBox(height: PqSpace.sm));
        }
        continue;
      }
      final bullet = _bulletRe.firstMatch(line);
      if (bullet != null) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: PqSpace.xxs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: PqSpace.md,
                  child: Text('•', style: base),
                ),
                Expanded(child: _rich(bullet.group(1)!, base, c)),
              ],
            ),
          ),
        );
      } else {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: PqSpace.xxs),
            child: _rich(line, base, c),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _rich(String line, TextStyle base, PqColors c) {
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final m in _inlineRe.allMatches(line)) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: line.substring(cursor, m.start)));
      }
      if (m.group(1) != null) {
        spans.add(
          TextSpan(
            text: m.group(1),
            style: PqType.subheadlineSemibold.copyWith(
              color: c.label,
              height: 1.6,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: m.group(2),
            style: PqType.code.copyWith(
              fontSize: (base.fontSize ?? 14) * 0.92,
              backgroundColor: c.fill,
            ),
          ),
        );
      }
      cursor = m.end;
    }
    if (cursor < line.length) spans.add(TextSpan(text: line.substring(cursor)));
    return Text.rich(TextSpan(style: base, children: spans));
  }
}
