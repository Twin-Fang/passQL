import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/utils/word_wrap.dart';
import 'package:passql_app/data/models/exam/exam_schedule_response.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/widgets/home/exam_schedule_card.dart';

import '../../helpers/pump_app.dart';

Future<void> _pumpCard(WidgetTester tester, ExamScheduleResponse? schedule) =>
    pumpApp(
      tester,
      MaterialApp(
        theme: PassqlTheme.light,
        home: Scaffold(body: ExamScheduleCard(schedule: schedule)),
      ),
    );

String _dateAfterDays(int days) {
  final date = DateTime.now().add(Duration(days: days));
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
}

void main() {
  testWidgets('일정이 없으면 누르는 척하는 강조 문구 없이 안내만 보인다', (tester) async {
    await _pumpCard(tester, null);

    expect(find.textContaining('일정 선택하기'), findsNothing);
    expect(find.text(keepWordsTogether('시험 일정 준비 중')), findsOneWidget);
  });

  testWidgets('D-day 는 화면에 D-N, 스크린리더에는 시험까지 N일로 읽힌다', (tester) async {
    await _pumpCard(
      tester,
      ExamScheduleResponse(
        examScheduleUuid: 'e1',
        certType: 'SQLD',
        round: 62,
        examDate: _dateAfterDays(24),
        isSelected: true,
      ),
    );

    expect(find.text('D-24'), findsOneWidget);
    expect(find.bySemanticsLabel('시험까지 24일'), findsOneWidget);
  });
}
