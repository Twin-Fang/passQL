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

/// 시험까지 무료로 풀 수 있는 랜덤 문제 최대치 (남은 날 × 하루 한도)
/// 일정 없음·시험 당일 이후·한도 모름이면 null > 구매 시트가 기간 줄을 생략한다
int? freeCapUntilExam({required int? daysUntilExam, required int limit}) {
  if (daysUntilExam == null || daysUntilExam <= 0 || limit <= 0) return null;
  return daysUntilExam * limit;
}

/// 긴 이용권을 고르면 아끼는 금액(원). 짧은 이용권을 같은 기간만큼 산 값 - 긴 이용권 값
/// 가격을 못 읽었거나 아끼는 금액이 없으면 null > 1개월 권유 줄을 그리지 않는다
int? monthlySavingsOf({
  required double? longPrice,
  required int longMonths,
  required double? basePrice,
  required int baseMonths,
}) {
  if (longPrice == null || basePrice == null || baseMonths <= 0) return null;
  final savings = (basePrice * longMonths / baseMonths - longPrice).round();
  return savings > 0 ? savings : null;
}

// 월 환산 금액 반올림 단위 (이용권 할인 배지와 같은 100원)
const int _monthlyRoundingUnit = 100;

/// 아끼는 금액을 개월 수로 나눈 월 금액 (100원 단위 반올림)
int monthlyShareOf(int savings, int months) =>
    (savings / months / _monthlyRoundingUnit).round() * _monthlyRoundingUnit;
