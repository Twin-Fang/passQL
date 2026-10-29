/// 시험일까지 남은 일수 (오늘 0, 지난 날 음수). 날짜를 읽지 못하면 null
/// 홈 시험 일정 카드와 온보딩 D-day 배지가 같은 기준으로 센다.
int? daysUntilExam(String examDate, {DateTime? now}) {
  try {
    return daysUntilDate(DateTime.parse(examDate), now: now);
  } catch (_) {
    return null;
  }
}

/// 날짜까지 남은 일수 (시각은 무시하고 날짜만 비교, 오늘 0)
/// 시험 D-day 와 이용권 남은 날(#749)이 같은 기준으로 센다
int daysUntilDate(DateTime target, {DateTime? now}) {
  final today = now ?? DateTime.now();
  return DateTime(target.year, target.month, target.day)
      .difference(DateTime(today.year, today.month, today.day))
      .inDays;
}

/// 화면 표기: D-24 / D-Day / D+3 (일수를 모르면 빈 문자열)
String examDdayLabel(int? daysUntilExam) {
  if (daysUntilExam == null) return '';
  if (daysUntilExam == 0) return 'D-Day';
  if (daysUntilExam > 0) return 'D-$daysUntilExam';
  return 'D+${daysUntilExam.abs()}';
}
