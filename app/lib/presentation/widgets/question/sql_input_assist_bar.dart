import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 입력 보조 칩 1개: 보이는 이름 + 넣을 글자 + 넣은 뒤 커서 위치(넣은 글자 시작 기준)
/// [caretStep] 이 0 이 아니면 글자 없이 커서만 옮김 (-1 왼쪽, 1 오른쪽)
class SqlInsertToken {
  const SqlInsertToken(this.label, this.text, {int? caretOffset})
    : caretOffset = caretOffset ?? text.length,
      caretStep = 0;

  /// 커서 이동: 괄호 안에서 빠져나오기 등 (모바일에서 커서 끌기가 불편)
  const SqlInsertToken.caretMove(this.label, this.caretStep)
    : text = '',
      caretOffset = 0;

  /// 키워드: 앞뒤 공백을 붙여 단어가 붙지 않게
  const SqlInsertToken.keyword(String keyword)
    : label = keyword,
      text = '$keyword ',
      caretOffset = keyword.length + 1,
      caretStep = 0;

  /// 함수: 괄호까지 넣고 커서는 괄호 안
  const SqlInsertToken.function(String name)
    : label = '$name()',
      text = '$name()',
      caretOffset = name.length + 1,
      caretStep = 0;

  final String label;
  final String text;
  final int caretOffset;
  final int caretStep;
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

  // 1줄: 커서 이동 + 기호 (괄호·따옴표는 짝으로, 닫는 괄호는 바로 뒤에 있으면 건너뜀)
  static const List<SqlInsertToken> _symbolTokens = [
    SqlInsertToken.caretMove('◀', -1),
    SqlInsertToken.caretMove('▶', 1),
    SqlInsertToken('( )', '()', caretOffset: 1),
    SqlInsertToken(')', _closingParenthesis),
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

  static const String _closingParenthesis = ')';

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

  /// 칩 누름 3가지: 커서 이동 | 바로 뒤 닫는 괄호 건너뛰기 | 커서 자리에 글자 넣기 (선택 영역은 대체, 커서 없으면 끝)
  void _insert(SqlInsertToken token) {
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    // 커서만 이동 (글 범위 안으로 제한)
    if (token.caretStep != 0) {
      _moveCaretTo((end + token.caretStep).clamp(0, text.length));
      return;
    }
    // 닫는 괄호가 바로 뒤에 있으면 넣지 않고 건너뜀 (COUNT(*|) > COUNT(*)|)
    final isClosingParenthesisAhead =
        token.text == _closingParenthesis &&
        start == end &&
        end < text.length &&
        text[end] == _closingParenthesis;
    if (isClosingParenthesisAhead) {
      _moveCaretTo(end + 1);
      return;
    }
    // 앞 공백 맞추기: 키워드 앞 글자가 붙어 있으면 하나 더함 (SELECTa 방지), 이미 공백이면 기호 앞 공백 뺌 (COL1  >= 방지)
    final previousCharacter = start > 0 ? text[start - 1] : ' ';
    final hasSpaceBefore = RegExp(r'\s').hasMatch(previousCharacter);
    final needsLeadingSpace =
        token.text.endsWith(' ') &&
        !token.text.startsWith(' ') &&
        !hasSpaceBefore &&
        previousCharacter != '(';
    final shouldDropLeadingSpace = token.text.startsWith(' ') && hasSpaceBefore;
    final insertedText = needsLeadingSpace
        ? ' ${token.text}'
        : shouldDropLeadingSpace
        ? token.text.substring(1)
        : token.text;
    final caretShift = needsLeadingSpace
        ? 1
        : shouldDropLeadingSpace
        ? -1
        : 0;
    controller.value = TextEditingValue(
      text: text.replaceRange(start, end, insertedText),
      selection: TextSelection.collapsed(
        offset: start + token.caretOffset + caretShift,
      ),
    );
    onInserted();
  }

  void _moveCaretTo(int offset) {
    controller.selection = TextSelection.collapsed(offset: offset);
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
      semanticLabel: switch (token.caretStep) {
        < 0 => '커서 왼쪽으로',
        > 0 => '커서 오른쪽으로',
        _ => '${token.label} 넣기',
      },
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
