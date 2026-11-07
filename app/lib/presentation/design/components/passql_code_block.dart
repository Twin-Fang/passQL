import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// SQL 표시 공통 블록. 기본은 줄바꿈해 전체가 보이게 하고, 정렬이 중요한 곳만
/// `shouldWrap: false`로 가로 스크롤한다. 길게 눌러 복사할 수 있다.
/// 상자는 채움 대신 얇은 테두리 (입력 칸과 구분), 코드 속 한글은 본문 글꼴 (#903)
class PassqlCodeBlock extends StatelessWidget {
  const PassqlCodeBlock({
    super.key,
    required this.code,
    this.isSelectable = true,
    this.shouldWrap = true,
    this.hasBackground = true,
  });
  final String code;
  final bool isSelectable;

  /// true면 줄바꿈, false면 가로 스크롤.
  final bool shouldWrap;

  /// false면 테두리 상자 없이 코드만 (카드 안에 넣어 상자가 겹치지 않게)
  final bool hasBackground;

  /// 한글 음절 덩어리 (고정폭 한글은 글자 사이가 벌어져 보여 본문 글꼴로)
  static final RegExp _hangulRunRe = RegExp(r'[\uAC00-\uD7A3\u3131-\u318E]+');

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final style = PassqlTypography.code.copyWith(color: colors.label);
    final span = TextSpan(style: style, children: _toCodeSpans(style));
    final codeText = isSelectable
        ? SelectableText.rich(span)
        : Text.rich(span);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: hasBackground ? Border.all(color: colors.separator) : null,
        borderRadius: BorderRadius.circular(PassqlRadius.sm),
      ),
      child: shouldWrap
          ? Padding(
              padding: const EdgeInsets.all(PassqlSpacing.sm),
              child: codeText,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(PassqlSpacing.sm),
              child: codeText,
            ),
    );
  }

  /// 코드 > 글 조각 (한글 덩어리만 본문 글꼴, 크기·줄 높이는 코드와 같게)
  List<TextSpan> _toCodeSpans(TextStyle codeStyle) {
    final hangulStyle = PassqlTypography.callout.copyWith(
      fontSize: codeStyle.fontSize,
      height: codeStyle.height,
      color: codeStyle.color,
    );
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in _hangulRunRe.allMatches(code)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: code.substring(cursor, match.start)));
      }
      spans.add(TextSpan(text: match.group(0), style: hangulStyle));
      cursor = match.end;
    }
    if (cursor < code.length) spans.add(TextSpan(text: code.substring(cursor)));
    return spans;
  }
}
