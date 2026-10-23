/// 긴 이용권 할인: 할인율(정수 %) + 월 환산 가격(100원 단위 반올림)
class PassDiscount {
  const PassDiscount({
    required this.discountPercent,
    required this.monthlyPrice,
  });

  final int discountPercent;
  final int monthlyPrice;
}

// 월 환산 가격 반올림 단위 (100원)
const int _monthlyPriceRoundingUnit = 100;

/// 이용 일수 > 개월 수 (30일 = 1개월, 90일 = 3개월)
int toPassMonths(int durationDays) => (durationDays / 30).round();

/// 기준(짧은) 이용권 대비 할인: 1 - 긴 가격 / (개월 비 × 기준 가격) > %, 긴 가격 / 개월 수 > 월 환산
/// 9,900원(3개월) · 4,400원(1개월) > 25% · 월 3,300원. 가격·개월 수가 없거나 할인이 없으면 null
PassDiscount? calculatePassDiscount({
  required double? longPassPrice,
  required int longPassMonths,
  required double? basePassPrice,
  required int basePassMonths,
}) {
  // 계산 조건 확인 (가격 둘 다 있음, 개월 수 양수, 긴 쪽이 더 김)
  if (longPassPrice == null || basePassPrice == null) return null;
  if (basePassPrice <= 0 || basePassMonths <= 0) return null;
  if (longPassMonths <= basePassMonths) return null;
  final undiscountedPrice = basePassPrice * longPassMonths / basePassMonths;
  final discountPercent = ((1 - longPassPrice / undiscountedPrice) * 100)
      .round();
  if (discountPercent <= 0) return null;
  final monthlyPrice =
      (longPassPrice / longPassMonths / _monthlyPriceRoundingUnit).round() *
      _monthlyPriceRoundingUnit;
  return PassDiscount(
    discountPercent: discountPercent,
    monthlyPrice: monthlyPrice,
  );
}
