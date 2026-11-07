import 'package:flutter/material.dart';

import '../../../data/models/question/question_schema_table.dart';
import '../../design/design.dart';
import 'question_data_table.dart';
import 'stem_blocks.dart';

/// 목록 미리보기용: 코드 펜스(```sql, ```)와 인라인 백틱을 걷어내고 내용은 한 줄로 합친다.
/// 잘린 미리보기는 닫는 펜스가 없을 수 있어 남은 ``` 도 함께 지운다.
String stripCodeFences(String text) {
  return text
      .replaceAll(RegExp(r'```[A-Za-z]*'), '')
      .replaceAll('`', '')
      .replaceAll(RegExp(r'\s*\n\s*'), ' ')
      .trim();
}

/// 문제 지문 (#903): 블록(단락·보조 설명·질문·목록·표·코드)으로 나눠 그림
/// 스키마 표는 지문 카드 안 표 자리에 (같은 컬럼 지문 표는 한 번만), 표 행은 접지 않음
class StemText extends StatelessWidget {
  const StemText(this.stem, {super.key, this.schemaTables = const []});

  final String stem;
  final List<QuestionSchemaTable> schemaTables;

  @override
  Widget build(BuildContext context) {
    final blocks = parseStemBlocks(stem, schemaTables: schemaTables);
    if (blocks.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < blocks.length; index++) ...[
            if (index > 0) SizedBox(height: _gapBefore(blocks[index])),
            _StemBlockView(block: blocks[index]),
          ],
        ],
      ),
    );
  }

  /// 블록 사이 간격 (질문 앞은 한 단계 넓게)
  static double _gapBefore(StemBlock block) =>
      block is StemQuestion ? PassqlSpacing.md : PassqlSpacing.sm;
}

/// 블록 1개 > 위젯
class _StemBlockView extends StatelessWidget {
  const _StemBlockView({required this.block});

  final StemBlock block;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return switch (block) {
      StemParagraph(:final text) => InlineCodeText(text),
      StemNote(:final text) => InlineCodeText(
        text,
        style: PassqlTypography.footnote.copyWith(color: colors.secondaryLabel),
      ),
      StemQuestion(:final text) => InlineCodeText(
        text,
        style: PassqlTypography.headline.copyWith(color: colors.label),
      ),
      StemList(:final items) => _StemListView(items: items),
      final StemTable table => _StemTableView(table: table),
      StemCode(:final caption, :final code) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (caption != null) ...[
            _CodeCaption(caption: caption),
            const SizedBox(height: PassqlSpacing.xxs),
          ],
          PassqlCodeBlock(code: code),
        ],
      ),
    };
  }
}

/// 목록 상자: 연한 배경, 항목 사이 구분선, 용어는 굵게 한 줄 + 설명 다음 줄
class _StemListView extends StatelessWidget {
  const _StemListView({required this.items});

  final List<StemListItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.sm),
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(PassqlRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < items.length; index++)
            DecoratedBox(
              decoration: BoxDecoration(
                border: index == 0
                    ? null
                    : Border(top: BorderSide(color: colors.separator)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.xs),
                child: _StemListItemView(listItem: items[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _StemListItemView extends StatelessWidget {
  const _StemListItemView({required this.listItem});

  final StemListItem listItem;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final term = listItem.term;
    if (term == null) return InlineCodeText(listItem.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InlineCodeText(
          term,
          style: PassqlTypography.subheadlineSemibold.copyWith(color: colors.label),
        ),
        const SizedBox(height: PassqlSpacing.xxs),
        InlineCodeText(
          listItem.text,
          style: PassqlTypography.subheadline.copyWith(color: colors.label),
        ),
      ],
    );
  }
}

/// 표: 이름(있으면) + 데이터 표 (행 전부, 자료형 숨김)
class _StemTableView extends StatelessWidget {
  const _StemTableView({required this.table});

  final StemTable table;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final name = table.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (name != null) ...[
          Text(
            name,
            style: PassqlTypography.codeEmphasis.copyWith(color: colors.label),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
        ],
        QuestionDataTable(columns: table.columns, rows: table.rows),
      ],
    );
  }
}

/// 코드 캡션: `SQL 2 (결과 행 수를 C4 라 한다)` > 굵은 강조색 라벨 + 괄호 안 설명은 보통 굵기
class _CodeCaption extends StatelessWidget {
  const _CodeCaption({required this.caption});

  final String caption;

  /// 라벨 + 끝 괄호 설명
  static final RegExp _labelWithNoteRe = RegExp(r'^(.*?)\s*\((.+)\)$');

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final match = _labelWithNoteRe.firstMatch(caption);
    final label = match?.group(1)?.trim();
    final hasNote = match != null && label != null && label.isNotEmpty;
    return Text.rich(
      TextSpan(
        text: hasNote ? label : caption,
        style: PassqlTypography.footnoteSemibold.copyWith(color: colors.accentText),
        children: [
          if (hasNote)
            TextSpan(
              text: '  ${match.group(2)!.trim()}',
              style: PassqlTypography.footnote.copyWith(color: colors.secondaryLabel),
            ),
        ],
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
