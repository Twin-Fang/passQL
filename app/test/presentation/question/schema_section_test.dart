import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/question/choice_item.dart';
import 'package:passql_app/data/models/question/question_detail.dart';
import 'package:passql_app/data/models/question/question_schema_column.dart';
import 'package:passql_app/data/models/question/question_schema_table.dart';
import 'package:passql_app/data/models/question/submit_result.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/providers/question_providers.dart';
import 'package:passql_app/presentation/widgets/question/question_solving_body.dart';
import 'package:passql_app/presentation/widgets/question/schema_section.dart';
import 'package:passql_app/presentation/widgets/question/schema_table_preview.dart';

/// 문제 테이블 영역 (#520): 기본 펼침, 컬럼·키·샘플 행, 접기·펼치기(제출 후 포함), 더 보기, 원문 대체, 개념형 미표시

const _empTable = QuestionSchemaTable(
  tableName: 'EMP',
  columns: [
    QuestionSchemaColumn(name: 'EMP_ID', type: 'INT', isPrimaryKey: true),
    QuestionSchemaColumn(name: 'ENAME', type: 'VARCHAR(20)'),
    QuestionSchemaColumn(name: 'DEPT_ID', type: 'INT', isForeignKey: true),
  ],
  sampleRows: [
    ['1', 'SCOTT', '10'],
    ['2', 'KING', null],
  ],
);

Future<void> _pumpSection(
  WidgetTester tester,
  SchemaSection section, {
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? PassqlTheme.light,
      home: Scaffold(body: SingleChildScrollView(child: section)),
    ),
  );
}

void main() {
  testWidgets('기본 펼침으로 컬럼 이름·타입·키와 샘플 행(NULL 포함)을 보여 준다', (tester) async {
    await _pumpSection(tester, const SchemaSection(tables: [_empTable]));

    expect(find.text('테이블 1개'), findsOneWidget);
    expect(find.text('EMP'), findsOneWidget);
    expect(find.text('샘플 2행'), findsOneWidget);
    expect(find.text('VARCHAR(20)'), findsOneWidget);
    expect(find.textContaining('EMP_ID PK', findRichText: true), findsOneWidget);
    expect(find.textContaining('DEPT_ID FK', findRichText: true), findsOneWidget);
    expect(find.text('SCOTT'), findsOneWidget);
    expect(find.text(SchemaTablePreview.nullCellLabel), findsOneWidget);
  });

  testWidgets('머리를 누르면 접히고 다시 누르면 펼쳐진다', (tester) async {
    await _pumpSection(tester, const SchemaSection(tables: [_empTable]));

    await tester.tap(find.text('테이블 1개'));
    await tester.pumpAndSettle();
    expect(find.text('SCOTT'), findsNothing);

    await tester.tap(find.text('테이블 1개'));
    await tester.pumpAndSettle();
    expect(find.text('SCOTT'), findsOneWidget);
  });

  testWidgets('샘플 행이 많으면 일부만 보이고 더 보기로 전부 펼친다', (tester) async {
    final extraRowCount = 2;
    final manyRowsTable = _empTable.copyWith(
      sampleRows: [
        for (var index = 0; index < SchemaTablePreview.initialSampleRowCount + extraRowCount; index++)
          ['$index', '이름$index', '10'],
      ],
    );
    await _pumpSection(tester, SchemaSection(tables: [manyRowsTable]));

    final lastRowName = '이름${SchemaTablePreview.initialSampleRowCount + extraRowCount - 1}';
    expect(find.text(lastRowName), findsNothing);
    await tester.tap(find.text('$extraRowCount행 더 보기'));
    await tester.pumpAndSettle();
    expect(find.text(lastRowName), findsOneWidget);
  });

  testWidgets('해석된 테이블이 없으면 DDL·INSERT 원문을 보여 준다', (tester) async {
    await _pumpSection(
      tester,
      const SchemaSection(
        tables: [],
        schemaDdl: 'CREATE TABLE T (A INT);',
        schemaSampleData: 'INSERT INTO T VALUES (1);',
      ),
    );

    expect(find.text('테이블'), findsOneWidget);
    expect(find.text('CREATE TABLE T (A INT);'), findsOneWidget);
    expect(find.text('INSERT INTO T VALUES (1);'), findsOneWidget);
  });

  testWidgets('스키마 없는 문제는 영역을 그리지 않는다', (tester) async {
    await _pumpSection(tester, const SchemaSection(tables: []));

    expect(find.byType(PassqlCard), findsNothing);
  });

  testWidgets('다크 모드·큰 글자에서도 넘침 없이 그린다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.dark,
        home: MediaQuery(
          data: const MediaQueryData(size: Size(320, 640), textScaler: TextScaler.linear(2)),
          child: const Scaffold(
            body: SingleChildScrollView(child: SchemaSection(tables: [_empTable])),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('SCOTT'), findsOneWidget);
  });

  testWidgets('풀이 본문: 지문 아래에 펼쳐 보이고 제출 뒤에도 접고 펼 수 있다', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(questionInteractionProvider('q-1'), (_, _) {});
    const question = QuestionDetail(
      questionUuid: 'q-1',
      executionMode: 'EXECUTABLE',
      stem: 'EMP 에서 이름을 조회하는 SQL 은?',
      schemaDdl: 'CREATE TABLE EMP (EMP_ID INT);',
      schemaTables: [_empTable],
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.light,
        home: Scaffold(
          body: QuestionSolvingBody(
            questionUuid: 'q-1',
            question: question,
            interaction: const QuestionInteractionState(
              activeChoiceSetId: 'cs-1',
              activeChoices: [ChoiceItem(key: 'A', kind: 'SQL', body: 'SELECT ENAME FROM EMP')],
              selectedChoiceKey: 'A',
            ),
            notifier: container.read(questionInteractionProvider('q-1').notifier),
            submitResult: const SubmitResult(isCorrect: true, correctKey: 'A'),
            gradedSelectedKey: 'A',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final stemTop = tester.getTopLeft(find.text('EMP 에서 이름을 조회하는 SQL 은?')).dy;
    final tableHeaderTop = tester.getTopLeft(find.text('테이블 1개')).dy;
    expect(tableHeaderTop, greaterThan(stemTop));
    expect(find.text('SCOTT'), findsOneWidget);

    await tester.tap(find.text('테이블 1개'));
    await tester.pumpAndSettle();
    expect(find.text('SCOTT'), findsNothing);

    await tester.tap(find.text('테이블 1개'));
    await tester.pumpAndSettle();
    expect(find.text('SCOTT'), findsOneWidget);
  });
}
