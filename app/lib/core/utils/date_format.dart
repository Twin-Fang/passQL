/// "10월 2일 15:05" 형태로 표기한다. 날짜 라이브러리 없이 필요한 만큼만 쓴다.
String formatMonthDayTime(DateTime time) {
  final hh = time.hour.toString().padLeft(2, '0');
  final mm = time.minute.toString().padLeft(2, '0');
  return '${time.month}월 ${time.day}일 $hh:$mm';
}

/// 날짜 > "2026.10.18" (공지 게시일 등 날짜만 보이는 자리)
String formatDottedDate(DateTime time) {
  final month = time.month.toString().padLeft(2, '0');
  final day = time.day.toString().padLeft(2, '0');
  return '${time.year}.$month.$day';
}
