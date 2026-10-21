import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/widgets/question/result_rows_table.dart';
import 'package:passql_app/presentation/widgets/question/stem_text.dart';

void main() {
  test('stripCodeFences: 펜스 표시를 지우고 한 줄로 합친다', () {
    expect(
      stripCodeFences('다음 SQL은?\n```sql\nSELECT 1\nFROM t;\n```'),
      '다음 SQL은? SELECT 1 FROM t;',
    );
    // 80자에서 잘려 닫는 펜스가 없는 미리보기
    expect(stripCodeFences('설명 ```sql\nSELECT'), '설명 SELECT');
  });

  testWidgets('StemText: 펜스 글자는 보이지 않고 코드 내용은 보인다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StemText('다음 SQL의 결과는?\n\n```sql\nSELECT NAME\nFROM EMP;\n```'),
        ),
      ),
    );
    expect(find.textContaining('```'), findsNothing);
    expect(find.text('다음 SQL의 결과는?'), findsOneWidget);
    expect(find.textContaining('SELECT NAME'), findsOneWidget);
  });

  testWidgets('StemText: 마크다운 표는 파이프 원문이 아니라 표로, NULL 칸은 NULL 로 보인다 (#550)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.light,
        home: const Scaffold(
          body: StemText('[EMP]\n| ID | BONUS |\n| --- | --- |\n| 1 | NULL |\n| 2 | 50 |\n\n결과는?'),
        ),
      ),
    );
    expect(find.textContaining('|'), findsNothing);
    expect(find.textContaining('---'), findsNothing);
    expect(find.byType(ResultRowsTable), findsOneWidget);
    expect(find.text('BONUS'), findsOneWidget);
    expect(find.text(sqlNullCellLabel), findsOneWidget);
    expect(find.text('결과는?'), findsOneWidget);
  });

  testWidgets('InlineCodeText: 백틱은 숨기고 키워드는 남긴다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: InlineCodeText('`PIVOT`과 `UNPIVOT`에 대한 설명')),
      ),
    );
    expect(find.textContaining('`', findRichText: true), findsNothing);
    expect(
      find.textContaining('PIVOT과 UNPIVOT에 대한 설명', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('StemText: 펜스 없는 지문의 인라인 백틱도 숨긴다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StemText('`PIVOT`과 `UNPIVOT`에 대한 설명 중 옳지 않은 것은?')),
      ),
    );
    expect(find.textContaining('`', findRichText: true), findsNothing);
  });
}
