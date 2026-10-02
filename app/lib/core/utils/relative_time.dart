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
