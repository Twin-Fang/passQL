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
    this.highlightedKeywords = const {},
    this.shouldColorStringLiterals = false,
    this.shouldColorCommentLines = false,
  });

  /// 화면 SQL 말투 블록(결과·첫 문제·크레딧 소진)이 칠하는 키워드 공통 목록 (#999)
  static const Set<String> sqlKeywords = {
    'SELECT',
    'FROM',
    'WHERE',
    'UPDATE',
    'SET',
  };

  final String code;
  final bool isSelectable;

  /// true면 줄바꿈, false면 가로 스크롤.
  final bool shouldWrap;

  /// false면 테두리 상자 없이 코드만 (카드 안에 넣어 상자가 겹치지 않게)
  final bool hasBackground;

  /// 강조색 글자로 칠할 SQL 키워드 (단어 단위 일치, 비면 칠하지 않음)
  final Set<String> highlightedKeywords;

  /// true면 작은따옴표 문자열('오늘')을 정답색 글자로 (#999)
  final bool shouldColorStringLiterals;

  /// true면 `--` 로 시작하는 주석 줄을 보조 글자색으로 (지문 제약 설명 주석)
  final bool shouldColorCommentLines;

  /// `--` 로 시작하는 줄 전체 (앞 공백 포함)
  static const String _commentLinePattern = r'^[ \t]*--[^\n]*';

  /// 작은따옴표 문자열 리터럴
  static final RegExp _stringLiteralRe = RegExp(r"'[^']*'");

  /// 한글 음절 덩어리 (고정폭 한글은 글자 사이가 벌어져 보여 본문 글꼴로)
  static final RegExp _hangulRunRe = RegExp(r'[\uAC00-\uD7A3\u3131-\u318E]+');

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final style = PassqlTypography.code.copyWith(color: colors.label);
    final span = TextSpan(
      style: style,
      children: _toCodeSpans(
        style,
        colors.accentText,
        colors.correctText,
        colors.secondaryLabel,
      ),
    );
    final codeText = isSelectable ? SelectableText.rich(span) : Text.rich(span);
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

  /// 코드 > 글 조각 (한글 덩어리만 본문 글꼴, 크기·줄 높이는 코드와 같게, 키워드는 강조색, 문자열은 정답색)
  List<TextSpan> _toCodeSpans(
    TextStyle codeStyle,
    Color keywordColor,
    Color stringLiteralColor,
    Color commentColor,
  ) {
    final hangulStyle = PassqlTypography.callout.copyWith(
      fontSize: codeStyle.fontSize,
      height: codeStyle.height,
      color: codeStyle.color,
    );
    final keywordStyle = codeStyle.copyWith(color: keywordColor);
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in _segmentPattern().allMatches(code)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: code.substring(cursor, match.start)));
      }
      final matchedText = match.group(0)!;
      if (shouldColorCommentLines && matchedText.trimLeft().startsWith('--')) {
        // 주석 안 한글도 본문 글꼴 유지, 색만 보조 글자색
        spans.add(
          TextSpan(
            style: TextStyle(color: commentColor),
            children: _toHangulAwareSpans(
              matchedText,
              hangulStyle.copyWith(color: commentColor),
            ),
          ),
        );
      } else if (shouldColorStringLiterals && matchedText.startsWith("'")) {
        // 문자열 안 한글도 본문 글꼴 유지, 색만 정답색
        spans.add(
          TextSpan(
            style: TextStyle(color: stringLiteralColor),
            children: _toHangulAwareSpans(
              matchedText,
              hangulStyle.copyWith(color: stringLiteralColor),
            ),
          ),
        );
      } else {
        final isKeyword = highlightedKeywords.contains(matchedText);
        spans.add(
          TextSpan(
            text: matchedText,
            style: isKeyword ? keywordStyle : hangulStyle,
          ),
        );
      }
      cursor = match.end;
    }
    if (cursor < code.length) spans.add(TextSpan(text: code.substring(cursor)));
    return spans;
  }

  /// 글 > 조각 (한글 덩어리만 [hangulStyle], 나머지는 부모 스타일)
  static List<TextSpan> _toHangulAwareSpans(String text, TextStyle hangulStyle) {
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in _hangulRunRe.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans.add(TextSpan(text: match.group(0), style: hangulStyle));
      cursor = match.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
    return spans;
  }

  /// 따로 칠할 덩어리: 주석 줄(선택) 또는 문자열(선택) 또는 키워드(단어 경계) 또는 한글 음절 덩어리
  RegExp _segmentPattern() {
    final alternatives = [
      if (shouldColorCommentLines) _commentLinePattern,
      if (shouldColorStringLiterals) _stringLiteralRe.pattern,
      if (highlightedKeywords.isNotEmpty)
        '\\b(?:${highlightedKeywords.map(RegExp.escape).join('|')})\\b',
      _hangulRunRe.pattern,
    ];
    if (alternatives.length == 1) return _hangulRunRe;
    return RegExp(alternatives.join('|'), multiLine: true);
  }
}
