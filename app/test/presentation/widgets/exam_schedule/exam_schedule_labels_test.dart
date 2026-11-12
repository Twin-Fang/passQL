import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/push/push_link.dart';
import 'package:passql_app/data/models/exam/exam_schedule_response.dart';
import 'package:passql_app/presentation/widgets/exam_schedule/exam_schedule_labels.dart';
import 'package:passql_app/router/app_routes.dart';
import 'package:passql_app/router/push_link_routes.dart';

// 2026 제63회 SQLD 공식 일정
ExamScheduleResponse _round63(ExamSchedulePhase phase) => ExamScheduleResponse(
  examScheduleUuid: 'u',
  certType: 'SQLD',
  round: 63,
  examDate: '2026-11-14',
  isSelected: true,
  applicationStartDate: '2026-10-12',
  applicationEndDate: '2026-10-16',
  admissionTicketDate: '2026-10-30',
  resultAnnouncementDate: '2026-12-04',
  phase: phase,
);

void main() {
  test('접수 중: 칩은 마감까지 남은 날(주황), 홈 배지는 마감일', () {
    final schedule = _round63(ExamSchedulePhase.applicationOpen);
    final today = DateTime(2026, 10, 14);
    expect(examPhaseChipOf(schedule, today), (
      text: '접수 중 · 마감까지 2일',
      isUrgent: true,
    ));
    expect(examHomeBadgeTextOf(schedule, today), '접수 중 · 10.16 마감');
  });

  test('시험 대기: 홈 배지는 시험 D-day, 단계는 시험 칸', () {
    final schedule = _round63(ExamSchedulePhase.waitingExam);
    expect(examHomeBadgeTextOf(schedule, DateTime(2026, 11, 12)), '시험 D-2');
    expect(examHomeBadgeTextOf(schedule, DateTime(2026, 11, 14)), '시험 D-Day');
    expect(examStepProgressOf(ExamSchedulePhase.waitingExam), (
      completedStepCount: 2,
      currentStepIndex: 2,
    ));
  });

  test('타임라인: 접수 시작·시험·발표 날짜순', () {
    final events = examTimelineEventsOf([
      _round63(ExamSchedulePhase.waitingExam),
    ]);
    expect(events.map((event) => event.title), [
      '제63회 접수 시작',
      '제63회 시험',
      '제63회 합격 발표',
    ]);
  });

  test('푸시 EXAM_SCHEDULE > 시험 일정 화면', () {
    final link = PushLink.fromData({PushDataKeys.linkTarget: 'EXAM_SCHEDULE'});
    expect(toPushLinkLocation(link!), AppRoutes.examSchedule);
  });
}
