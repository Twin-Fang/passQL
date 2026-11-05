/// 개념 레슨 블록 11종 (#848·#853): 글, SQL, 비교 표, 용어 카드, 단계, 외우는 법, 헷갈리는 말, 바로 확인, 조인 연결, 행 거르기, 집합 그림
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

/// 조인 결과 한 줄: 왼쪽 행 + 오른쪽 행 (짝 없는 쪽은 NULL)
class ConceptJoinPair {
  const ConceptJoinPair({required this.left, required this.right});

  final String left;
  final String right;

  bool get isLeftMissing => left.isEmpty || left == _missingRowLabel;

  bool get isRightMissing => right.isEmpty || right == _missingRowLabel;

  // 짝 없는 쪽 표시 (원본 표의 NULL 글자)
  static const String _missingRowLabel = 'NULL';
}

/// 조인 연결 그림 (머리글 `왼쪽 행 | 오른쪽 행`): 결과 한 줄 = 행 하나, 같은 행이 여러 번이면 선이 여러 개
class ConceptJoinBlock extends ConceptLessonBlock {
  const ConceptJoinBlock(this.pairs);

  final List<ConceptJoinPair> pairs;

  /// 왼쪽·오른쪽 표에 보일 행 (처음 나온 순서, 중복 제거, NULL 제외)
  List<String> get leftRows => _distinct(
    pairs.where((pair) => !pair.isLeftMissing).map((pair) => pair.left),
  );

  List<String> get rightRows => _distinct(
    pairs.where((pair) => !pair.isRightMissing).map((pair) => pair.right),
  );

  static List<String> _distinct(Iterable<String> rows) => rows.toSet().toList();
}

/// 행 하나의 처리: 이름 + 결과(남음·빠짐·묶음 이름)
class ConceptRowOutcome {
  const ConceptRowOutcome({required this.row, required this.outcome});

  final String row;
  final String outcome;

  bool get isRemoved => outcome == removedLabel;

  bool get isKept => outcome == keptLabel;

  /// 묶음 이름 (남음·빠짐이 아니면 그 글자가 묶음 이름)
  String? get groupName => isRemoved || isKept ? null : outcome;

  static const String removedLabel = '빠짐';
  static const String keptLabel = '남음';
}

/// 행 거르기 그림 (머리글 `행 | 처리`): 빠지는 행은 지워지고, 묶음은 같은 색으로
class ConceptRowFilterBlock extends ConceptLessonBlock {
  const ConceptRowFilterBlock(this.rows);

  final List<ConceptRowOutcome> rows;

  /// 묶음 이름 목록 (처음 나온 순서)
  List<String> get groupNames =>
      rows.map((row) => row.groupName).whereType<String>().toSet().toList();
}

/// 집합 연산 하나: 연산 이름 + 결과 값
class ConceptSetOperation {
  const ConceptSetOperation({required this.name, required this.result});

  final String name;
  final String result;
}

/// 집합 그림 (머리글 `집합 | 값`): 앞 두 줄 = 두 집합(쉼표 구분 값), 나머지 줄 = 연산과 결과
class ConceptSetBlock extends ConceptLessonBlock {
  const ConceptSetBlock({
    required this.leftName,
    required this.leftValues,
    required this.rightName,
    required this.rightValues,
    required this.operations,
  });

  final String leftName;
  final List<String> leftValues;
  final String rightName;
  final List<String> rightValues;
  final List<ConceptSetOperation> operations;

  /// 겹치는 값 / 한쪽에만 있는 값 (중복 제거, 처음 나온 순서)
  List<String> get sharedValues =>
      leftValues.toSet().where(rightValues.contains).toList();

  List<String> get leftOnlyValues => leftValues
      .toSet()
      .where((value) => !rightValues.contains(value))
      .toList();

  List<String> get rightOnlyValues => rightValues
      .toSet()
      .where((value) => !leftValues.contains(value))
      .toList();
}
