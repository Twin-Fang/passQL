// 두 자리 숫자 (앞 0 채움)
String _twoDigits(int value) => value.toString().padLeft(2, '0');

/// 날짜 > "11월 14일" (화면 날짜 표기 기본형, #995)
String formatMonthDay(DateTime time) => '${time.month}월 ${time.day}일';

/// 날짜 > "11/14" (차트 축처럼 좁은 자리)
String formatSlashMonthDay(DateTime time) => '${time.month}/${time.day}';

/// 날짜 > "11.14" (탑승권 칸처럼 점 구분 짧은 자리)
String formatDottedMonthDay(DateTime time) =>
    '${_twoDigits(time.month)}.${_twoDigits(time.day)}';

/// 날짜 > "2026-11-14" (기기 저장 날짜 키·서버 날짜 대조)
String formatIsoDate(DateTime time) =>
    '${time.year}-${_twoDigits(time.month)}-${_twoDigits(time.day)}';

/// "10월 2일 15:05" 형태로 표기한다. 날짜 라이브러리 없이 필요한 만큼만 쓴다.
String formatMonthDayTime(DateTime time) =>
    '${formatMonthDay(time)} ${_twoDigits(time.hour)}:${_twoDigits(time.minute)}';

/// "10/07 08:48" (월/일 24시간제 시각, 의견 작성 시각처럼 좁은 줄에 넣는 자리, #741)
String formatSlashMonthDayTime(DateTime time) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(time.month)}/${twoDigits(time.day)} '
      '${twoDigits(time.hour)}:${twoDigits(time.minute)}';
}

/// 두 시각이 같은 달력 날짜인가
bool isSameCalendarDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

/// 날짜 > "오늘 / 어제 / 11월 10일" (날짜별 묶음 머리글, [today] 기준, #974)
String formatRecentDayTitle(DateTime day, {required DateTime today}) {
  if (isSameCalendarDay(day, today)) return '오늘';
  final yesterday = DateTime(today.year, today.month, today.day - 1);
  if (isSameCalendarDay(day, yesterday)) return '어제';
  return formatMonthDay(day);
}

/// 걸린 시간 > 'N분 N초' (1분 미만이면 'N초', 초 단위 반올림)
String formatElapsedMinutesSeconds(Duration elapsed) {
  final totalSeconds = (elapsed.inMilliseconds / 1000).round();
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return minutes > 0 ? '$minutes분 $seconds초' : '$seconds초';
}

/// 날짜 > "2026.10.18" (공지 게시일 등 날짜만 보이는 자리)
String formatDottedDate(DateTime time) {
  final month = time.month.toString().padLeft(2, '0');
  final day = time.day.toString().padLeft(2, '0');
  return '${time.year}.$month.$day';
}

/// 시각 > "2027.01.26 23:59" (이용권 만료 시각)
String formatDottedDateTime(DateTime time) =>
    '${formatDottedDate(time)} ${_twoDigits(time.hour)}:${_twoDigits(time.minute)}';

/// 시각 > ISO8601 + 로컬 오프셋 (2026-10-27T09:00:00.000+09:00), 로그·진단 정보 공통
String formatIso8601WithOffset(DateTime moment) {
  final offset = moment.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  return '${moment.toIso8601String()}$sign$hours:$minutes';
}

/// 시각 > "9:41" (잠금화면 작은 시계, 24시간제·시는 앞 0 없음)
String formatClockTime(DateTime time) =>
    '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

// 요일 짧은 이름 (DateTime.weekday 1=월 ~ 7=일)
const List<String> _koreanWeekdayNames = ['월', '화', '수', '목', '금', '토', '일'];

/// 날짜 > "11월 12일 수" (잠금화면 시계 옆)
String formatMonthDayWeekday(DateTime time) =>
    '${formatMonthDay(time)} ${_koreanWeekdayNames[time.weekday - 1]}';
