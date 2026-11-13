import '../../../core/utils/date_format.dart';
import '../../../core/utils/exam_dday.dart';
import '../../../data/models/exam/exam_schedule_response.dart';

/// 시험 일정 문구·단계 판정 공통 (#991): 시험 일정 화면·홈 D-day 배지가 같은 기준으로 씀

/// 일정 날짜 문자열(yyyy-MM-dd) > 날짜 (없거나 못 읽으면 null)
DateTime? parseExamScheduleDate(String? date) =>
    date == null ? null : DateTime.tryParse(date);

/// 단계 칩 문구와 강조 여부 (접수 중만 주황 강조)
typedef ExamPhaseChip = ({String text, bool isUrgent});

/// 단계 > 칩 문구: "접수 중 · 마감까지 2일", "시험 대기 · 수험표 발급됨" (모르는 단계 > null)
ExamPhaseChip? examPhaseChipOf(ExamScheduleResponse schedule, DateTime today) {
  final applicationStart = parseExamScheduleDate(schedule.applicationStartDate);
  final applicationEnd = parseExamScheduleDate(schedule.applicationEndDate);
  final admissionTicket = parseExamScheduleDate(schedule.admissionTicketDate);
  final resultAnnouncement = parseExamScheduleDate(
    schedule.resultAnnouncementDate,
  );
  return switch (schedule.phase) {
    ExamSchedulePhase.beforeApplication => (
      text: applicationStart == null
          ? '접수 전'
          : '접수 전 | ${formatCompactDottedMonthDay(applicationStart)} 접수 시작',
      isUrgent: false,
    ),
    ExamSchedulePhase.applicationOpen => (
      text: _applicationOpenChipText(applicationEnd, today),
      isUrgent: true,
    ),
    ExamSchedulePhase.waitingAdmissionTicket => (
      text: admissionTicket == null
          ? '수험표 대기'
          : '수험표 대기 | ${formatCompactDottedMonthDay(admissionTicket)} 발급',
      isUrgent: false,
    ),
    ExamSchedulePhase.waitingExam => (
      text: daysUntilExam(schedule.examDate, now: today) == 0
          ? '오늘 시험 | 수험표 확인'
          : '시험 대기 | 수험표 발급됨',
      isUrgent: false,
    ),
    ExamSchedulePhase.waitingResult => (
      text: resultAnnouncement == null
          ? '발표 대기'
          : '발표 대기 | ${formatCompactDottedMonthDay(resultAnnouncement)} 발표',
      isUrgent: false,
    ),
    ExamSchedulePhase.finished => (text: '끝 | 합격 발표됨', isUrgent: false),
    ExamSchedulePhase.unknown => null,
  };
}

/// 접수 중 칩: 마감까지 N일 / 오늘 마감 (마감일 모르면 "접수 중")
String _applicationOpenChipText(DateTime? applicationEnd, DateTime today) {
  if (applicationEnd == null) return '접수 중';
  final daysLeft = daysUntilDate(applicationEnd, now: today);
  return daysLeft <= 0 ? '접수 중 | 오늘 마감' : '접수 중 | 마감까지 $daysLeft일';
}

/// 홈 D-day 배지 한 줄: "접수 중 · 10.16 마감", "시험 D-2", "발표 12.4" (모르는 단계·끝 > 기존 D-day 표기)
String examHomeBadgeTextOf(ExamScheduleResponse schedule, DateTime today) {
  final dday = examDdayLabel(daysUntilExam(schedule.examDate, now: today));
  final applicationEnd = parseExamScheduleDate(schedule.applicationEndDate);
  final resultAnnouncement = parseExamScheduleDate(
    schedule.resultAnnouncementDate,
  );
  return switch (schedule.phase) {
    ExamSchedulePhase.applicationOpen =>
      applicationEnd == null
          ? '접수 중'
          : '접수 중 | ${formatCompactDottedMonthDay(applicationEnd)} 마감',
    ExamSchedulePhase.beforeApplication ||
    ExamSchedulePhase.waitingAdmissionTicket ||
    ExamSchedulePhase.waitingExam => '시험 $dday',
    ExamSchedulePhase.waitingResult when resultAnnouncement != null =>
      '발표 ${formatCompactDottedMonthDay(resultAnnouncement)}',
    _ => dday,
  };
}

/// 가로 단계 4개(접수·수험표·시험·발표) 진행: 지난 단계 수, 지금 단계 위치(없으면 null)
typedef ExamStepProgress = ({int completedStepCount, int? currentStepIndex});

/// 단계 > 가로 단계 진행 (접수 전·모르는 단계는 모두 비움, 끝은 모두 채움)
ExamStepProgress examStepProgressOf(ExamSchedulePhase phase) => switch (phase) {
  ExamSchedulePhase.applicationOpen => (
    completedStepCount: 0,
    currentStepIndex: 0,
  ),
  ExamSchedulePhase.waitingAdmissionTicket => (
    completedStepCount: 1,
    currentStepIndex: 1,
  ),
  ExamSchedulePhase.waitingExam => (completedStepCount: 2, currentStepIndex: 2),
  ExamSchedulePhase.waitingResult => (
    completedStepCount: 3,
    currentStepIndex: 3,
  ),
  ExamSchedulePhase.finished => (completedStepCount: 4, currentStepIndex: null),
  ExamSchedulePhase.beforeApplication ||
  ExamSchedulePhase.unknown => (completedStepCount: 0, currentStepIndex: null),
};

/// 세로 타임라인 이벤트 1건: 날짜, 문구, 시험 이벤트 여부(굵게·큰 점)
typedef ExamTimelineEvent = ({DateTime date, String title, bool isExam});

/// 회차들 > 타임라인 이벤트(접수 시작·시험·합격 발표) 날짜순 (날짜 모르는 이벤트는 뺌)
List<ExamTimelineEvent> examTimelineEventsOf(
  List<ExamScheduleResponse> schedules,
) {
  final events = <ExamTimelineEvent>[];
  for (final schedule in schedules) {
    final roundName = '제${schedule.round}회';
    final applicationStart = parseExamScheduleDate(
      schedule.applicationStartDate,
    );
    final examDate = parseExamScheduleDate(schedule.examDate);
    final resultAnnouncement = parseExamScheduleDate(
      schedule.resultAnnouncementDate,
    );
    if (applicationStart != null) {
      events.add((
        date: applicationStart,
        title: '$roundName 접수 시작',
        isExam: false,
      ));
    }
    if (examDate != null) {
      events.add((date: examDate, title: '$roundName 시험', isExam: true));
    }
    if (resultAnnouncement != null) {
      events.add((
        date: resultAnnouncement,
        title: '$roundName 합격 발표',
        isExam: false,
      ));
    }
  }
  // 날짜순 (같은 날이면 넣은 순서 유지)
  return _sortByDateKeepingOrder(events);
}

/// 안정 정렬 (List.sort 는 같은 값 순서를 보장하지 않음)
List<ExamTimelineEvent> _sortByDateKeepingOrder(
  List<ExamTimelineEvent> events,
) {
  final indexed = [for (var index = 0; index < events.length; index++) index];
  indexed.sort((first, second) {
    final byDate = events[first].date.compareTo(events[second].date);
    return byDate != 0 ? byDate : first.compareTo(second);
  });
  return [for (final index in indexed) events[index]];
}

/// 하단 출처 줄: "출처 데이터자격검정 · 오늘 06:00 갱신" (수집 시각 모르면 출처만)
String examScheduleSourceTextOf(DateTime? lastCollectedAt, DateTime today) {
  const source = '출처 데이터자격검정';
  if (lastCollectedAt == null) return source;
  final collectedText = isSameCalendarDay(lastCollectedAt, today)
      ? '오늘 ${formatHourMinute(lastCollectedAt)}'
      : formatMonthDayTime(lastCollectedAt);
  return '$source | $collectedText 갱신';
}
