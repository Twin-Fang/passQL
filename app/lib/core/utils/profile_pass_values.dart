import 'app_clock.dart';

// 내 프로필 탑승권·이용권 시트에 보이는 숫자 계산 (#749)
// 화면에 지어낸 숫자를 쓰지 않도록 모두 등급 응답·시험 일정·스토어 가격에서만 계산한다.

/// 오늘 남은 무료 랜덤 풀이 수 (한도를 넘겨 푼 경우에도 0 아래로 내려가지 않음)
int remainingFreeSolves({required int used, required int limit}) =>
    used >= limit ? 0 : limit - used;

/// 무료 하루 한도를 다 썼는지. 결제 꺼짐 응답은 한도가 0이라 "다 쓴 날"로 보지 않는다
bool isFreeLimitReached({required int used, required int limit}) =>
    limit > 0 && used >= limit;

/// 프로가 무료 한도보다 더 푼 문제 수. 한도 이하로 푼 날은 null (정보 시트가 다른 문장을 쓴다)
int? extraSolvedToday({required int used, required int limit}) {
  final extra = used - limit;
  return extra >= 1 ? extra : null;
}

/// AI 분석 아래 작은 시각 문구 (#749): 오늘이면 "오늘 오전 9:12 분석", 다른 날이면 "10월 27일 분석"
/// 서버 generatedAt(ISO 문자열)이 없거나 읽지 못하면 null > 줄을 그리지 않는다
String? aiAnalyzedLabel(String? generatedAt, {DateTime? now}) {
  if (generatedAt == null) return null;
  final parsed = DateTime.tryParse(generatedAt);
  if (parsed == null) return null;
  // 오프셋이 붙은 값은 기기 시각으로, 오프셋 없는 값은 서버(KST) 시각 그대로 본다
  final at = parsed.isUtc ? parsed.toLocal() : parsed;
  final today = now ?? AppClock.now();
  final isToday =
      at.year == today.year && at.month == today.month && at.day == today.day;
  if (!isToday) return '${at.month}월 ${at.day}일 분석';
  final period = at.hour < 12 ? '오전' : '오후';
  final hour = at.hour % 12 == 0 ? 12 : at.hour % 12;
  return '오늘 $period $hour:${at.minute.toString().padLeft(2, '0')} 분석';
}
