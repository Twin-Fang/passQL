import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/question/choice_item.dart';
import 'package:passql_app/presentation/widgets/question/choice_card.dart';

import '../../helpers/pump_app.dart';

void main() {
  test('결과 행 JSON 배열만 표 데이터로 인식한다', () {
    expect(parseResultRows('[{"NAME":"홍길동","SAL":5000}]'), [
      {'NAME': '홍길동', 'SAL': 5000},
    ]);
    expect(parseResultRows('[]'), isEmpty);
    expect(parseResultRows('일반 텍스트 선택지'), isNull);
    expect(parseResultRows('[1, 2]'), isNull);
    expect(parseResultRows('[{"a":1}'), isNull);
  });

  testWidgets('실행 결과형 선택지는 JSON 대신 열 이름과 값으로 된 표를 보여 준다', (tester) async {
    await pumpApp(
      tester,
      MaterialApp(
        home: Scaffold(
          body: ChoiceCard(
            item: const ChoiceItem(
              key: 'A',
              kind: 'TEXT',
              body: '[{"NAME":"홍길동","RNK":1},{"NAME":"김영희","RNK":1}]',
            ),
            isSelected: false,
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
