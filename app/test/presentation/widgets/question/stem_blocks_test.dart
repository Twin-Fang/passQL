import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/question/question_schema_column.dart';
import 'package:passql_app/data/models/question/question_schema_table.dart';
import 'package:passql_app/presentation/widgets/question/stem_blocks.dart';

// 지문 블록 나누기 판정 (#903): 웹 stemBlocks 테스트와 같은 입력
void main() {
  test('목록·용어, 보조 설명, 질문 문장을 나눈다', () {
    const stem =
        "도서관 '대출' 엔터티의 속성 일부가 다음과 같다.\n"
        '(반납예정일과 반납일은 별도 속성으로 있다)\n'
        '- 대출번호: 직전 번호에 1을 더해 붙이는 번호\n'
        '- 연체일수: 반납일에서 반납예정일을 뺀 일수\n'
        '속성과 특성에 따른 분류를 짝지은 것으로 옳은 것은?';
    final blocks = parseStemBlocks(stem);

    expect(blocks.map((block) => block.runtimeType).toList(), [
      StemParagraph,
      StemNote,
      StemList,
      StemQuestion,
    ]);
    expect((blocks[1] as StemNote).text, '(반납예정일과 반납일은 별도 속성으로 있다)');
    final list = blocks[2] as StemList;
    expect(list.items.first.term, '대출번호');
    expect(list.items.first.text, '직전 번호에 1을 더해 붙이는 번호');
  });

  test('한 줄 안 질문 문장만 떼고 용어 형식이 아닌 목록은 글 그대로', () {
    const stem =
        '성립하는 함수 종속은 아래 2개뿐이다. 이 관계가 만족하는 가장 높은 정규형은?\n'
        '- (학번, 과목) → 교수\n'
        '- 교수 → 과목';
    final blocks = parseStemBlocks(stem);

    expect((blocks[0] as StemParagraph).text, '성립하는 함수 종속은 아래 2개뿐이다.');
    expect((blocks[1] as StemQuestion).text, '이 관계가 만족하는 가장 높은 정규형은?');
    final list = blocks[2] as StemList;
    expect(list.items.first.term, isNull);
    expect(list.items.first.text, '(학번, 과목) → 교수');
  });

  test('표 이름 줄과 코드 라벨 캡션, 같은 컬럼 스키마 표는 지문 표 자리에 한 번만', () {
    const stem =
        '다음 두 SQL 의 실행 결과로 옳은 것은?\n'
        '[EMP]\n'
        '| EMP_ID | NAME |\n'
        '| --- | --- |\n'
        '| 1 | KIM |\n'
        '```sql\n'
        '-- SQL 1\n'
        'SELECT COUNT(*) FROM EMP;\n'
        '\n'
        '-- SQL 2 (결과 행 수를 C4 라 한다)\n'
        'SELECT DISTINCT NAME FROM EMP;\n'
        '```';
    const schemaTable = QuestionSchemaTable(
      tableName: 'EMP',
      columns: [
        QuestionSchemaColumn(name: 'EMP_ID', isPrimaryKey: true),
        QuestionSchemaColumn(name: 'NAME'),
      ],
      sampleRows: [
        [1, 'KIM'],
      ],
    );
    final blocks = parseStemBlocks(stem, schemaTables: [schemaTable]);

    final tables = blocks.whereType<StemTable>().toList();
    expect(tables, hasLength(1));
    expect(tables.single.columns.first.isPrimaryKey, isTrue);
    final codes = blocks.whereType<StemCode>().toList();
    expect(codes.map((code) => code.caption), [
      'SQL 1',
      'SQL 2 (결과 행 수를 C4 라 한다)',
    ]);
    expect(codes.last.code, 'SELECT DISTINCT NAME FROM EMP;');
  });

  test('번호 목록은 번호를 남긴다 (보기가 번호를 가리킴)', () {
    final blocks = parseStemBlocks('1. 기본키는 NULL 일 수 없다\n2. 외래키는 NULL 일 수 있다');
    final items = (blocks.single as StemList).items;
    expect(items.map((item) => item.ordinal), ['1.', '2.']);
    expect(items.first.text, '기본키는 NULL 일 수 없다');
  });

  test('겹치는 지문 표가 없으면 스키마 표는 첫 코드 앞에', () {
    const stem = '다음 SQL 의 실행 결과로 옳은 것은?\n```sql\nSELECT ID FROM T;\n```';
    const schemaTable = QuestionSchemaTable(
      tableName: 'T',
      columns: [QuestionSchemaColumn(name: 'ID')],
    );
    final blocks = parseStemBlocks(stem, schemaTables: [schemaTable]);

    expect(blocks.map((block) => block.runtimeType).toList(), [
      StemQuestion,
      StemTable,
      StemCode,
    ]);
  });

  test('컬럼이 같아도 이름이 다른 지문 표는 스키마 표로 바꾸지 않는다', () {
    const stem =
        '[EMP]\n'
        '| ID | DEPT_NO |\n'
        '| --- | --- |\n'
        '| 1 | 10 |\n'
        '\n'
        '[PROJ]\n'
        '| ID | DEPT_NO |\n'
        '| --- | --- |\n'
        '| 1 | 10 |';
    const projSchemaTable = QuestionSchemaTable(
      tableName: 'PROJ',
      columns: [
        QuestionSchemaColumn(name: 'ID', isPrimaryKey: true),
        QuestionSchemaColumn(name: 'DEPT_NO', isForeignKey: true),
      ],
    );
    final blocks = parseStemBlocks(stem, schemaTables: [projSchemaTable]);

    final tables = blocks.whereType<StemTable>().toList();
    expect(tables.map((table) => table.name), ['EMP', 'PROJ']);
    expect(tables.first.columns.first.isPrimaryKey, isFalse);
    expect(tables.last.columns.first.isPrimaryKey, isTrue);
    expect(tables.last.rows, [
      ['1', '10'],
    ]);
  });

  test('제약 설명 주석은 캡션이 아니라 코드 안 주석으로 남긴다', () {
    const stem =
        '```sql\n'
        '-- EMP.DEPT_NO : REFERENCES DEPT(DEPT_NO) ON DELETE SET NULL\n'
        'DELETE FROM DEPT WHERE DEPT_NO = 10;\n'
        '```';
    final code = parseStemBlocks(stem).single as StemCode;

    expect(code.caption, isNull);
    expect(code.code, startsWith('-- EMP.DEPT_NO : REFERENCES'));
  });
}
