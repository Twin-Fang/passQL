import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/exam/exam_schedule_response.dart';
import 'package:passql_app/presentation/widgets/home/exam_dday_bar_title.dart';

ExamScheduleResponse _schedule({required int round, required String examDate}) =>
    ExamScheduleResponse(
      examScheduleUuid: 'u',
      certType: 'SQLD',
      round: round,
      examDate: examDate,
      isSelected: true,
    );

void main() {
  test('examBarSubtitle: 회차와 월·일', () {
    expect(
      examBarSubtitle(_schedule(round: 63, examDate: '2026-11-14')),
      'SQLD 63회 · 11월 14일',
    );
  });

  test('examBarSubtitle: 한 자리 월·일은 0 없이', () {
    expect(
      examBarSubtitle(_schedule(round: 60, examDate: '2026-03-07')),
      'SQLD 60회 · 3월 7일',
    );
  });

  test('examBarSubtitle: 날짜를 읽지 못하면 회차만', () {
    expect(
      examBarSubtitle(_schedule(round: 63, examDate: '미정')),
      'SQLD 63회',
    );
  });

  test('examDdaySpokenLabel', () {
    expect(examDdaySpokenLabel(18), '시험까지 18일');
    expect(examDdaySpokenLabel(0), '오늘 시험일');
    expect(examDdaySpokenLabel(-3), '시험 3일 지남');
  });
}
