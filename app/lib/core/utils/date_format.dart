/// "10월 2일 15:05" 형태로 표기한다. 날짜 라이브러리 없이 필요한 만큼만 쓴다.
String formatMonthDayTime(DateTime time) {
  final hh = time.hour.toString().padLeft(2, '0');
  final mm = time.minute.toString().padLeft(2, '0');
  return '${time.month}월 ${time.day}일 $hh:$mm';
}

/// "10/07 08:48" (월/일 24시간제 시각, 의견 작성 시각처럼 좁은 줄에 넣는 자리, #741)
String formatSlashMonthDayTime(DateTime time) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(time.month)}/${twoDigits(time.day)} '
      '${twoDigits(time.hour)}:${twoDigits(time.minute)}';
}

/// 날짜 > "2026.10.18" (공지 게시일 등 날짜만 보이는 자리)
String formatDottedDate(DateTime time) {
  final month = time.month.toString().padLeft(2, '0');
  final day = time.day.toString().padLeft(2, '0');
  return '${time.year}.$month.$day';
}

/// 시각 > ISO8601 + 로컬 오프셋 (2026-10-27T09:00:00.000+09:00), 로그·진단 정보 공통
String formatIso8601WithOffset(DateTime moment) {
  final offset = moment.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  return '${moment.toIso8601String()}$sign$hours:$minutes';
}
