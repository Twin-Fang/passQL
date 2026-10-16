/// 과거 시각을 "오늘 / 어제 / N일 전" 으로 표현한다.
///
/// [now] 는 테스트에서 기준 시각을 고정하기 위한 주입 지점이다.
String formatRelativeDay(DateTime? time, {DateTime? now}) {
  if (time == null) return '';
  final base = now ?? DateTime.now();
  final today = DateTime(base.year, base.month, base.day);
  final day = DateTime(time.year, time.month, time.day);
  final days = today.difference(day).inDays;
  if (days <= 0) return '오늘';
  if (days == 1) return '어제';
  return '$days일 전';
}

// 경과 시간 표기 경계: 1분 / 1시간 / 1일 / 7일
const Duration _justNowLimit = Duration(minutes: 1);
const Duration _minutesLimit = Duration(hours: 1);
const Duration _hoursLimit = Duration(days: 1);
const int _daysLimit = 7;

/// 알림 시각 > "방금 / N분 전 / N시간 전 / 어제 / N일 전 / M월 D일" (7일 넘으면 날짜)
String formatNotificationElapsed(DateTime? time, {DateTime? now}) {
  if (time == null) return '';
  final base = now ?? DateTime.now();
  final elapsed = base.difference(time);
  if (elapsed < _justNowLimit) return '방금';
  if (elapsed < _minutesLimit) return '${elapsed.inMinutes}분 전';
  if (elapsed < _hoursLimit) return '${elapsed.inHours}시간 전';
  final calendarDays = DateTime(base.year, base.month, base.day)
      .difference(DateTime(time.year, time.month, time.day))
      .inDays;
  if (calendarDays == 1) return '어제';
  if (calendarDays < _daysLimit) return '$calendarDays일 전';
  return '${time.month}월 ${time.day}일';
}
