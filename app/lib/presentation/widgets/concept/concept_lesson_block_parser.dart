import '../question/result_rows_table.dart';
import '../question/stem_markdown_table.dart';
import 'concept_lesson_block.dart';

/// 문단 마크다운 > 레슨 블록 목록: 코드 펜스 분리 > 표 분리 > 표 머리글로 종류 판정
abstract final class ConceptLessonBlockParser {
  // 코드 펜스(```sql ... ```)
  static final RegExp _codeFenceRe = RegExp(r'```[A-Za-z]*\r?\n?([\s\S]*?)```');

  // 블록 종류를 정하는 표 머리글 (원본 작성 규칙: content/concepts/README.md)
  static const List<String> _termHeader = ['용어', '뜻'];
  static const List<String> _stepsHeader = ['단계', '내용'];
  static const List<String> _mnemonicHeader = ['외우기', '뜻'];
  static const List<String> _refutationHeader = ['헷갈리는 말', '실제로는'];
  static const List<String> _quickCheckHeader = ['바로 확인', '정답', '이유'];
  static const List<String> _joinHeader = ['왼쪽 행', '오른쪽 행'];
  static const List<String> _rowFilterHeader = ['행', '처리'];
  static const List<String> _setHeader = ['집합', '값'];
  // 집합 그림: 앞 두 줄이 두 집합 (나머지는 연산)
  static const int _setDefinitionRowCount = 2;
  // 집합 값 구분자
  static const String _setValueSeparator = ',';
  // 바로 확인 정답 칸: 참
  static const String _trueMark = 'O';

  static List<ConceptLessonBlock> parse(String markdown) {
    final blocks = <ConceptLessonBlock>[];
    var cursor = 0;
    for (final match in _codeFenceRe.allMatches(markdown)) {
      _addTextAndTables(markdown.substring(cursor, match.start), blocks);
      blocks.add(ConceptCodeBlock((match.group(1) ?? '').trimRight()));
      cursor = match.end;
    }
    _addTextAndTables(markdown.substring(cursor), blocks);
    return blocks;
  }

  // 글 조각 > 표 블록·글 블록 (빈 글은 건너뜀)
  static void _addTextAndTables(String raw, List<ConceptLessonBlock> blocks) {
    for (final segment in splitStemMarkdownTables(raw)) {
      if (segment is StemMarkdownTable) {
        blocks.add(_toTableBlock(segment));
        continue;
      }
      final text = (segment as String).trim();
      if (text.isNotEmpty) blocks.add(ConceptTextBlock(text));
    }
  }

  /// 표 > 머리글이 약속된 모양이면 그 블록, 아니면 일반 표
  static ConceptLessonBlock _toTableBlock(StemMarkdownTable table) {
    final header = table.columns.map((column) => column.trim()).toList();
    // 칸이 모자란 행은 빈 글로 채움 (머리글 칸 수 기준), 표 해석이 null 로 바꾼 NULL 글자는 되돌림
    final rows = [
      for (final row in table.rows)
        [
          for (var column = 0; column < header.length; column++)
            column < row.length
                ? row[column]?.toString().trim() ?? sqlNullCellLabel
                : '',
        ],
    ];
    if (_isHeader(header, _termHeader)) {
      return ConceptTermCardsBlock([
        for (final row in rows) ConceptTerm(term: row[0], meaning: row[1]),
      ]);
    }
    if (_isHeader(header, _stepsHeader)) {
      return ConceptStepsBlock([
        for (final row in rows) ConceptStep(title: row[0], detail: row[1]),
      ]);
    }
    if (_isHeader(header, _mnemonicHeader)) {
      return ConceptMnemonicBlock([
        for (final row in rows) ConceptTerm(term: row[0], meaning: row[1]),
      ]);
    }
    if (_isHeader(header, _refutationHeader)) {
      return ConceptRefutationBlock([
        for (final row in rows) ConceptRefutation(myth: row[0], fact: row[1]),
      ]);
    }
    if (_isHeader(header, _quickCheckHeader)) {
      return ConceptQuickCheckBlock([
        for (final row in rows)
          ConceptQuickCheck(
            statement: row[0],
            isTrue: row[1].toUpperCase() == _trueMark,
            reason: row[2],
          ),
      ]);
    }
    if (_isHeader(header, _joinHeader)) {
      return ConceptJoinBlock([
        for (final row in rows) ConceptJoinPair(left: row[0], right: row[1]),
      ]);
    }
    if (_isHeader(header, _rowFilterHeader)) {
      return ConceptRowFilterBlock([
        for (final row in rows) ConceptRowOutcome(row: row[0], outcome: row[1]),
      ]);
    }
    if (_isHeader(header, _setHeader) && rows.length > _setDefinitionRowCount) {
      return ConceptSetBlock(
        leftName: rows[0][0],
        leftValues: _splitSetValues(rows[0][1]),
        rightName: rows[1][0],
        rightValues: _splitSetValues(rows[1][1]),
        operations: [
          for (final row in rows.skip(_setDefinitionRowCount))
            ConceptSetOperation(name: row[0], result: row[1]),
        ],
      );
    }
    return ConceptTableBlock(columns: table.columns, rows: table.rows);
  }

  static List<String> _splitSetValues(String raw) => [
    for (final value in raw.split(_setValueSeparator))
      if (value.trim().isNotEmpty) value.trim(),
  ];

  static bool _isHeader(List<String> header, List<String> expected) {
    if (header.length != expected.length) return false;
    for (var index = 0; index < expected.length; index++) {
      if (header[index] != expected[index]) return false;
    }
    return true;
  }
}
