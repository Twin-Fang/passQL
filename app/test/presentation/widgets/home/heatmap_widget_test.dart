import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/progress/heatmap_response.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/widgets/home/heatmap_widget.dart';

void main() {
  group('히트맵 날짜 칸 정렬', () {
    test('첫 칸은 항상 일요일이라 머리글(일~토)과 열이 맞는다', () {
      // 2026-10-14 수요일, 2026-10-17 토요일, 2026-10-18 일요일
      for (final today in [
        DateTime(2026, 10, 14),
        DateTime(2026, 10, 17),
        DateTime(2026, 10, 18),
      ]) {
        final days = HeatmapWidget.buildGridDays(today);
        expect(days, hasLength(35));
        expect(days.first.weekday, DateTime.sunday, reason: '$today');
        expect(days.last.weekday, DateTime.saturday, reason: '$today');
        // 오늘은 마지막 주(5번째 줄) 안
        expect(days.indexOf(today), greaterThanOrEqualTo(28));
      }
    });

    test('월말을 넘어가도 하루씩 이어진다', () {
      final days = HeatmapWidget.buildGridDays(DateTime(2026, 11, 2));
      for (var index = 1; index < days.length; index++) {
        expect(days[index].difference(days[index - 1]).inHours, 24);
      }
    });
  });

  testWidgets('오늘 칸을 강조하고 스크린리더 요약은 오늘까지만 센다', (tester) async {
    // 수요일: 첫 칸(4주 전 일요일)부터 오늘까지 32일
    final today = DateTime(2026, 10, 14);
    await tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.light,
        home: Scaffold(
          // 정사각 칸이 화면 폭을 따라 커지므로 세로 스크롤 안에 둠
          body: SingleChildScrollView(
            child: HeatmapWidget(
              today: today,
              heatmap: const HeatmapResponse(
                entries: [
                  HeatmapEntry(
                    date: '2026-10-14',
                    solvedCount: 2,
                    correctCount: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('heatmap-today')), findsOneWidget);
    expect(
      find.bySemanticsLabel('최근 32일 학습 기록, 학습한 날 1일, 푼 문제 2개'),
      findsOneWidget,
    );
  });
}
