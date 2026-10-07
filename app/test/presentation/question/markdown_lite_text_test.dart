import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/widgets/question/markdown_lite_text.dart';

void main() {
  testWidgets('MarkdownLiteText: 마크다운 기호는 숨기고 목록은 • 로 바꾼다', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => const MaterialApp(
          home: Scaffold(
            body: MarkdownLiteText(
              '**기억할 포인트**\n* **C번**: `PIVOT`은 집계가 필요\n- 열 → 행 변환',
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('**', findRichText: true), findsNothing);
    expect(find.textContaining('`', findRichText: true), findsNothing);
    expect(find.text('•'), findsNWidgets(2));
    expect(
      find.textContaining('C번: PIVOT은 집계가 필요', findRichText: true),
      findsOneWidget,
    );
  });
}
