import '../../../data/models/progress/weekly_wrong_count.dart';

/// 요일 이름 (서버 weekdayAttemptCounts·busiestWeekdayIndex 순서: 월 0 ~ 일 6)
const List<String> weekdayShortNames = ['월', '화', '수', '목', '금', '토', '일'];

/// 시각(0~23) > 읽는 말 (0 > 밤 12시, 3 > 새벽 3시, 10 > 오전 10시, 12 > 낮 12시, 15 > 오후 3시, 21 > 밤 9시)
String toSpokenHourLabel(int hour) {
  if (hour == 0) return '밤 12시';
  if (hour < 6) return '새벽 $hour시';
  if (hour < 12) return '오전 $hour시';
  if (hour == 12) return '낮 12시';
  if (hour < 18) return '오후 ${hour - 12}시';
  return '밤 ${hour - 12}시';
}

/// 'yyyy-MM-dd' > 'M/d' (형식이 다르면 원문)
String toMonthDayLabel(String isoDate) {
  final parsed = DateTime.tryParse(isoDate);
  if (parsed == null) return isoDate;
  return '${parsed.month}/${parsed.day}';
}

/// 정답률 % (반올림, 풀이 없으면 0)
int toCorrectPercent(int correctCount, int attemptCount) =>
    attemptCount == 0 ? 0 : (correctCount * 100 / attemptCount).round();

/// 지난주 대비 이번 주 남은 오답 변화 (늘면 양수, 두 주가 안 되면 null)
int? weeklyRemainingWrongChange(List<WeeklyWrongCount> trend) {
  if (trend.length < 2) return null;
  return trend.last.remainingWrongCount -
      trend[trend.length - 2].remainingWrongCount;
}
