import 'package:flutter/material.dart';

import '../../design/design.dart';
import 'result_rows_table.dart';
import 'stem_markdown_table.dart';

/// 지문 안의 ```lang ... ``` 블록 분리용 정규식.
final RegExp _fenceRe = RegExp(r'```[A-Za-z]*\r?\n?([\s\S]*?)```');

/// 목록 미리보기용: 코드 펜스(```sql, ```)와 인라인 백틱을 걷어내고 내용은 한 줄로 합친다.
/// 잘린 미리보기는 닫는 펜스가 없을 수 있어 남은 ``` 도 함께 지운다.
String stripCodeFences(String text) {
  return text
      .replaceAll(RegExp(r'```[A-Za-z]*'), '')
      .replaceAll('`', '')
      .replaceAll(RegExp(r'\s*\n\s*'), ' ')
      .trim();
}

/// 문제 지문. 코드 펜스 구간은 고정폭 코드 박스로, 마크다운 표는 결과 표로, 나머지는 일반 글로 그린다.
class StemText extends StatelessWidget {
  const StemText(this.stem, {super.key});

  final String stem;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    var cursor = 0;

    // 글 조각 안의 마크다운 표는 결과 표와 같은 모양으로 (#550)
    void addText(String raw) {
      for (final segment in splitStemMarkdownTables(raw)) {
        if (segment is StemMarkdownTable) {
          children.add(
            ResultRowsTable.positional(
              columns: segment.columns,
              rows: segment.rows,
            ),
          );
          continue;
        }
        final trimmed = (segment as String).trim();
        if (trimmed.isNotEmpty) children.add(InlineCodeText(trimmed));
      }
    }

    for (final match in _fenceRe.allMatches(stem)) {
      addText(stem.substring(cursor, match.start));
      children.add(PassqlCodeBlock(code: (match.group(1) ?? '').trimRight()));
      cursor = match.end;
    }
    addText(stem.substring(cursor));

    // 펜스가 하나도 없으면 기존과 같은 한 덩어리 글
    if (children.isEmpty) return const SizedBox.shrink();

    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) spaced.add(const SizedBox(height: PassqlSpacing.sm));
      spaced.add(children[i]);
    }
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: spaced,
      ),
    );
  }
}

/// 인라인 코드(`키워드`)를 고정폭 + 연한 배경으로 강조하는 일반 글.
/// 백틱은 표시하지 않는다. 짝이 맞지 않는 백틱은 글자 그대로 둔다.
class InlineCodeText extends StatelessWidget {
  const InlineCodeText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  static final RegExp _inlineRe = RegExp(r'`([^`\n]+)`');

  /// 줄바꿈 안 되는 공백 (U+00A0)
  static const String _nonBreakingSpace = '\u00A0';

  /// 붙여 둘 코드 최대 글자 수: 넘으면 한 줄보다 길 수 있어 빈칸에서 줄바꿈 허용 (#577)
  static const int _maxKeptTogetherCodeLength = 20;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final base =
        style ?? PassqlTypography.callout.copyWith(color: colors.label);
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _inlineRe.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans.add(
        TextSpan(
          // 짧은 코드 안 공백은 줄바꿈 안 되는 공백으로: 'GROUP BY' 가 두 줄로 갈라지지 않게 (#554)
          // 긴 코드는 그대로: 한 줄보다 길면 글자 중간에서 잘리므로 빈칸에서 줄바꿈 (#577)
          text: _toCodeSpanText(match.group(1)!),
          style: PassqlTypography.inlineCodeOf(
            base,
          ).copyWith(backgroundColor: colors.fill),
        ),
      );
      cursor = match.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
    return Text.rich(TextSpan(style: base, children: spans));
  }

  static String _toCodeSpanText(String code) =>
      code.length <= _maxKeptTogetherCodeLength
      ? code.replaceAll(' ', _nonBreakingSpace)
      : code;
}
