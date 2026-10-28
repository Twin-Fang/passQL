import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 입력 보조 칩 1개: 보이는 이름 + 넣을 글자 + 넣은 뒤 커서 위치(넣은 글자 시작 기준)
class SqlInsertToken {
  const SqlInsertToken(this.label, this.text, {int? caretOffset})
    : caretOffset = caretOffset ?? text.length;

  /// 키워드: 앞뒤 공백을 붙여 단어가 붙지 않게
  const SqlInsertToken.keyword(String keyword)
    : label = keyword,
      text = '$keyword ',
      caretOffset = keyword.length + 1;

  /// 함수: 괄호까지 넣고 커서는 괄호 안
  const SqlInsertToken.function(String name)
    : label = '$name()',
      text = '$name()',
      caretOffset = name.length + 1;

  final String label;
  final String text;
  final int caretOffset;
}

/// SQL 입력 보조 막대: 기호 · 키워드 · 이 문제의 표·열 이름과 함수 3줄 (#727)
/// 칩을 누르면 커서 자리에 넣음 (괄호·따옴표는 짝까지 넣고 커서는 안쪽) > 사용자는 숫자·영어만 입력
class SqlInputAssistBar extends StatelessWidget {
  const SqlInputAssistBar({
    super.key,
    required this.controller,
    required this.schemaNames,
    required this.onInserted,
  });

  final TextEditingController controller;

  /// 이 문제의 표 이름·열 이름 (중복 없이, 표 먼저)
  final List<String> schemaNames;

  /// 넣은 뒤 알림 (임시 SQL 저장 등)
  final VoidCallback onInserted;

  // 1줄: 기호 (괄호·따옴표는 짝으로)
  static const List<SqlInsertToken> _symbolTokens = [
    SqlInsertToken('( )', '()', caretOffset: 1),
    SqlInsertToken(',', ', '),
    SqlInsertToken("' '", "''", caretOffset: 1),
    SqlInsertToken('*', '*'),
    SqlInsertToken('=', ' = '),
    SqlInsertToken('<>', ' <> '),
    SqlInsertToken('>=', ' >= '),
    SqlInsertToken('<=', ' <= '),
    SqlInsertToken('>', ' > '),
    SqlInsertToken('<', ' < '),
    SqlInsertToken('.', '.'),
    SqlInsertToken('%', '%'),
    SqlInsertToken(';', ';'),
    SqlInsertToken('줄바꿈', '\n'),
  ];

  // 2줄: SQLD 범위 키워드 (자주 쓰는 순)
  static const List<SqlInsertToken> _keywordTokens = [
    SqlInsertToken.keyword('SELECT'),
    SqlInsertToken.keyword('FROM'),
    SqlInsertToken.keyword('WHERE'),
    SqlInsertToken.keyword('AND'),
    SqlInsertToken.keyword('OR'),
    SqlInsertToken.keyword('GROUP BY'),
    SqlInsertToken.keyword('HAVING'),
    SqlInsertToken.keyword('ORDER BY'),
    SqlInsertToken.keyword('DESC'),
    SqlInsertToken.keyword('JOIN'),
    SqlInsertToken.keyword('ON'),
    SqlInsertToken.keyword('AS'),
    SqlInsertToken.keyword('IN'),
    SqlInsertToken.keyword('IS NULL'),
    SqlInsertToken.keyword('LIKE'),
    SqlInsertToken.keyword('BETWEEN'),
    SqlInsertToken.keyword('DISTINCT'),
    SqlInsertToken.keyword('UNION'),
  ];

  // 3줄 뒤쪽: 집계·NULL 함수
  static const List<SqlInsertToken> _functionTokens = [
    SqlInsertToken.function('COUNT'),
    SqlInsertToken.function('SUM'),
    SqlInsertToken.function('AVG'),
    SqlInsertToken.function('MAX'),
    SqlInsertToken.function('MIN'),
    SqlInsertToken.function('COALESCE'),
  ];

  /// 커서 자리(선택 영역은 바꿈, 커서 없으면 끝)에 칩 글자 넣기
  void _insert(SqlInsertToken token) {
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    // 키워드 앞 글자가 붙어 있으면 공백 하나 (SELECTa 방지)
    final needsLeadingSpace =
        token.text.endsWith(' ') &&
        start > 0 &&
        !RegExp(r'[\s(]').hasMatch(text[start - 1]);
    final insertedText = needsLeadingSpace ? ' ${token.text}' : token.text;
    controller.value = TextEditingValue(
      text: text.replaceRange(start, end, insertedText),
      selection: TextSelection.collapsed(
        offset: start + token.caretOffset + (needsLeadingSpace ? 1 : 0),
      ),
    );
    onInserted();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AssistChipRow(tokens: _symbolTokens, onTap: _insert),
        _AssistChipRow(tokens: _keywordTokens, onTap: _insert),
        _AssistChipRow(
          tokens: [
            for (final name in schemaNames) SqlInsertToken(name, name),
            ..._functionTokens,
          ],
          onTap: _insert,
        ),
      ],
    );
  }
}

/// 칩 한 줄 (가로 스크롤)
class _AssistChipRow extends StatelessWidget {
  const _AssistChipRow({required this.tokens, required this.onTap});

  final List<SqlInsertToken> tokens;
  final ValueChanged<SqlInsertToken> onTap;

  // 칩 줄 높이 (칩 + 위아래 여백), 키보드 위 3줄이 화면을 덜 가리게 최소 터치 높이보다 낮춤
  static const double _rowHeight = 40;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: PassqlSpacing.md,
          vertical: PassqlSpacing.xxs,
        ),
        itemCount: tokens.length,
        separatorBuilder: (_, _) => const SizedBox(width: PassqlSpacing.xs),
        itemBuilder: (context, index) =>
            _AssistChip(token: tokens[index], onTap: onTap),
      ),
    );
  }
}

class _AssistChip extends StatelessWidget {
  const _AssistChip({required this.token, required this.onTap});

  final SqlInsertToken token;
  final ValueChanged<SqlInsertToken> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlPressable(
      onTap: () => onTap(token),
      semanticLabel: '${token.label} 넣기',
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.sm),
        decoration: BoxDecoration(
          color: colors.fill,
          borderRadius: BorderRadius.circular(PassqlRadius.sm),
        ),
        child: Text(
          token.label,
          style: PassqlTypography.codeCompact.copyWith(color: colors.label),
        ),
      ),
    );
  }
}
