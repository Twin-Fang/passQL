import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/question/choice_item.dart';
import 'package:passql_app/data/models/question/submit_result.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/widgets/question/choice_item_card.dart';
import 'package:passql_app/presentation/widgets/question/result_rows_table.dart';

import '../../helpers/pump_app.dart';

void main() {
  SubmitResult result({required bool isCorrect, required String correctKey}) =>
      SubmitResult(isCorrect: isCorrect, correctKey: correctKey);

  test('결과 행 JSON 배열만 표 데이터로 인식한다', () {
    expect(parseResultRows('[{"NAME":"홍길동","SAL":5000}]'), [
      {'NAME': '홍길동', 'SAL': 5000},
    ]);
    expect(parseResultRows('[]'), isEmpty);
    expect(parseResultRows('일반 텍스트 선택지'), isNull);
    expect(parseResultRows('[1, 2]'), isNull);
    expect(parseResultRows('[{"a":1}'), isNull);
  });

  test('채점 전에는 선택한 것만 selected', () {
    expect(resolveChoiceState(key: 'A', selectedKey: 'A'), PassqlChoiceState.selected);
    expect(resolveChoiceState(key: 'B', selectedKey: 'A'), PassqlChoiceState.idle);
  });

  test('오답 제출 후: 정답 correct, 내 선택 wrong, 나머지 dimmed', () {
    final r = result(isCorrect: false, correctKey: 'C');
    expect(resolveChoiceState(key: 'C', selectedKey: 'A', result: r), PassqlChoiceState.correct);
    expect(resolveChoiceState(key: 'A', selectedKey: 'A', result: r), PassqlChoiceState.wrong);
    expect(resolveChoiceState(key: 'B', selectedKey: 'A', result: r), PassqlChoiceState.dimmed);
  });

  test('정답 제출 후: 내 선택이 correct, 나머지 dimmed', () {
    final r = result(isCorrect: true, correctKey: 'A');
    expect(resolveChoiceState(key: 'A', selectedKey: 'A', result: r), PassqlChoiceState.correct);
    expect(resolveChoiceState(key: 'B', selectedKey: 'A', result: r), PassqlChoiceState.dimmed);
  });

  testWidgets('빈 결과 보기는 오류 글자가 아니라 결과 표와 같은 틀의 "결과 없음 · 0행"으로 보인다', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: PassqlTheme.light,
      home: Scaffold(
        body: ChoiceItemCard(
          item: const ChoiceItem(key: 'C', kind: 'RESULT', body: '[]'),
          displayLabel: 'C',
          state: PassqlChoiceState.idle,
          onTap: () {},
        ),
      ),
    ));
    expect(find.text('결과 없음 · 0행'), findsOneWidget);
    expect(find.text('(결과 없음)'), findsNothing);
  });

  testWidgets('결과 보기의 NULL 은 빈칸이 아니라 NULL 로, 빈 문자열은 빈칸으로 보인다 (#549)', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: PassqlTheme.light,
      home: Scaffold(
        body: ChoiceItemCard(
          item: const ChoiceItem(
            key: 'A',
            kind: 'RESULT',
            body: '[{"ID":1,"BONUS":null,"MEMO":""}]',
          ),
          displayLabel: 'A',
          state: PassqlChoiceState.idle,
          onTap: () {},
        ),
      ),
    ));
    expect(find.text(sqlNullCellLabel), findsOneWidget);
    expect(find.text(''), findsOneWidget);
  });

  testWidgets('SQL 선택지는 코드 블록으로, 글자 크기 2배에서도 넘치지 않는다', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: PassqlTheme.light,
      home: MediaQuery(
        data: const MediaQueryData(size: Size(390, 844), textScaler: TextScaler.linear(2)),
        child: Scaffold(
          body: ChoiceItemCard(
            item: const ChoiceItem(key: 'A', kind: 'SQL', body: 'SELECT ename FROM emp WHERE sal > 1000;'),
            displayLabel: 'A',
            state: PassqlChoiceState.idle,
            onTap: () {},
          ),
        ),
      ),
    ));
    expect(find.byType(PassqlCodeBlock), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('실행 결과형 선택지는 JSON 대신 열 이름과 값으로 된 표를 보여 준다', (tester) async {
    await pumpApp(
      tester,
      MaterialApp(
        home: Scaffold(
          body: ChoiceItemCard(
            item: const ChoiceItem(
              key: 'A',
              kind: 'TEXT',
              body: '[{"NAME":"홍길동","RNK":1},{"NAME":"김영희","RNK":1}]',
            ),
            displayLabel: 'A',
            state: PassqlChoiceState.idle,
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.byType(ResultRowsTable), findsOneWidget);
    expect(find.text('NAME'), findsOneWidget);
    expect(find.text('김영희'), findsOneWidget);
    expect(find.textContaining('{"NAME"'), findsNothing);
  });
}
