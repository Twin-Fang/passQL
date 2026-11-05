import '../question/result_rows_table.dart';
import '../question/stem_markdown_table.dart';

/// 개념 레슨 블록 8종 (#848): 글, SQL, 비교 표, 용어 카드, 단계, 외우는 법, 헷갈리는 말, 바로 확인
/// 원본은 표준 마크다운 그대로 (옛 앱은 표·글로 보임), 표 머리글로 블록 종류를 정함
sealed class ConceptLessonBlock {
  const ConceptLessonBlock();
}

/// 일반 글 (굵게·인라인 코드·목록)
class ConceptTextBlock extends ConceptLessonBlock {
  const ConceptTextBlock(this.markdown);

  final String markdown;
}

/// SQL 코드 블록
class ConceptCodeBlock extends ConceptLessonBlock {
  const ConceptCodeBlock(this.code);

  final String code;
}

/// 머리글이 정해지지 않은 표 (비교·결과 표)
class ConceptTableBlock extends ConceptLessonBlock {
  const ConceptTableBlock({required this.columns, required this.rows});

  final List<String> columns;
  final List<List<Object?>> rows;
}

/// 용어 + 뜻 한 쌍
class ConceptTerm {
  const ConceptTerm({required this.term, required this.meaning});

  final String term;
  final String meaning;
}

/// 용어 카드 묶음 (머리글 `용어 | 뜻`)
class ConceptTermCardsBlock extends ConceptLessonBlock {
  const ConceptTermCardsBlock(this.terms);

  final List<ConceptTerm> terms;
}

/// 단계 하나: 이름 + 설명
class ConceptStep {
  const ConceptStep({required this.title, required this.detail});

  final String title;
  final String detail;
}

/// 단계 흐름 (머리글 `단계 | 내용`)
class ConceptStepsBlock extends ConceptLessonBlock {
  const ConceptStepsBlock(this.steps);

  final List<ConceptStep> steps;
}

/// 외우는 법 (머리글 `외우기 | 뜻`): 행마다 글자 하나 + 뜻, 두문자는 첫 칸을 이어 붙인 것
class ConceptMnemonicBlock extends ConceptLessonBlock {
  const ConceptMnemonicBlock(this.letters);

  final List<ConceptTerm> letters;

  /// 두문자 (예: 원부이결다조)
  String get phrase => letters.map((letter) => letter.term).join();
}

/// 헷갈리는 말 한 쌍: 오해 > 실제
class ConceptRefutation {
  const ConceptRefutation({required this.myth, required this.fact});

  final String myth;
  final String fact;
}

/// 헷갈리는 말 카드 묶음 (머리글 `헷갈리는 말 | 실제로는`)
class ConceptRefutationBlock extends ConceptLessonBlock {
  const ConceptRefutationBlock(this.refutations);

  final List<ConceptRefutation> refutations;
}

/// OX 문장 하나: 문장 + 참 여부 + 이유
class ConceptQuickCheck {
  const ConceptQuickCheck({
    required this.statement,
    required this.isTrue,
    required this.reason,
  });

  final String statement;
  final bool isTrue;
  final String reason;
}

/// 바로 확인 OX 묶음 (머리글 `바로 확인 | 정답 | 이유`, 정답 칸 O 또는 X)
class ConceptQuickCheckBlock extends ConceptLessonBlock {
  const ConceptQuickCheckBlock(this.checks);

  final List<ConceptQuickCheck> checks;
}

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
    return ConceptTableBlock(columns: table.columns, rows: table.rows);
  }

  static bool _isHeader(List<String> header, List<String> expected) {
    if (header.length != expected.length) return false;
    for (var index = 0; index < expected.length; index++) {
      if (header[index] != expected[index]) return false;
    }
    return true;
  }
}
