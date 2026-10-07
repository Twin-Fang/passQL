import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/question/execute_result.dart';
import 'package:passql_app/presentation/widgets/question/execute_result_card.dart';

void main() {
  testWidgets('실행 결과 카드는 부모 폭을 모두 채운다', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MaterialApp(
          home: Scaffold(
            body: Column(
              // 선택지 화면처럼 start 정렬 Column 안에서도 줄지 않아야 한다
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExecuteResultCard(
                  result: ExecuteResult(
                    columns: ['count'],
                    rows: [
                      [1],
                    ],
                    rowCount: 1,
                    elapsedMs: 26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final card = tester.getSize(find.byType(ExecuteResultCard));
    final screen = tester.getSize(find.byType(Scaffold));
    // 좌우 margin(각 20.w)을 뺀 폭 전체를 쓴다
    expect(card.width, closeTo(screen.width, 0.1));
  });
}
