import 'pass_discount.dart';
import 'pro_purchase_port.dart';

/// 이용권 목록 가격 계산: 기준(가장 짧은) 이용권, 할인, 할인 전 값, 하루 가격
/// 이용권 모델은 상품 ID·이용 일수 읽는 함수로만 받음 (core 는 data 모델 import 금지)
/// 할인율은 통화와 무관(같은 통화끼리), 원 금액(할인 전 값·하루 가격)은 원화 가격일 때만 (#867)
class PassOptionPricing<Option> {
  const PassOptionPricing({
    required this.options,
    required this.priceByProductId,
    required this.productIdOf,
    required this.durationDaysOf,
  });

  /// 서버 순서 이용권 목록
  final List<Option> options;

  /// 상품 ID별 스토어 가격 (못 읽은 상품은 없음)
  final Map<String, PassPrice> priceByProductId;
  final String Function(Option option) productIdOf;
  final int Function(Option option) durationDaysOf;

  double? _rawPriceOf(Option option) =>
      priceByProductId[productIdOf(option)]?.rawPrice;

  /// 원 금액으로 보여도 되는 가격인가 (해외 스토어 계정이면 $5.99 같은 값이라 `원`·원 반올림이 틀림)
  bool _isKoreanWonPriced(Option option) =>
      priceByProductId[productIdOf(option)]?.isKoreanWon ?? false;

  /// 두 이용권 가격이 같은 통화인가 (할인율 비교 조건)
  bool _hasSameCurrency(Option option, Option other) =>
      priceByProductId[productIdOf(option)]?.currencyCode ==
      priceByProductId[productIdOf(other)]?.currencyCode;

  int _monthsOf(Option option) => toPassMonths(durationDaysOf(option));

  /// 가격을 읽은 이용권 중 가장 짧은 것 (할인·권유 계산 기준, 없으면 null)
  Option? get baseOption {
    final pricedOptions = options.where(
      (candidate) => priceByProductId.containsKey(productIdOf(candidate)),
    );
    if (pricedOptions.isEmpty) return null;
    return pricedOptions.reduce(
      (shorter, candidate) =>
          durationDaysOf(candidate) < durationDaysOf(shorter)
          ? candidate
          : shorter,
    );
  }

  /// 가장 짧은 이용권 대비 할인 (가격 없음·통화 다름·할인 없음·기준 칸 자신이면 null)
  PassDiscount? discountOf(Option option) {
    final base = baseOption;
    if (base == null || !_hasSameCurrency(option, base)) return null;
    return calculatePassDiscount(
      longPassPrice: _rawPriceOf(option),
      longPassMonths: _monthsOf(option),
      basePassPrice: _rawPriceOf(base),
      basePassMonths: _monthsOf(base),
    );
  }

  /// 할인 전 값(원, 반올림): 기준 이용권을 같은 기간만큼 샀을 때 (할인이 있고 원화일 때만)
  int? undiscountedPriceOf(Option option) {
    final base = baseOption;
    final basePrice = base == null ? null : _rawPriceOf(base);
    if (base == null || basePrice == null) return null;
    if (!_isKoreanWonPriced(option)) return null;
    if (discountOf(option) == null) return null;
    final total = basePrice * _monthsOf(option) / _monthsOf(base);
    return total.round();
  }

  /// 하루 가격(원, 1원 단위 반올림): 스토어 가격 / 이용 일수 (가격 없음·원화 아님 > null)
  int? dailyPriceOf(Option option) => _isKoreanWonPriced(option)
      ? calculateDailyPassPrice(
          passPrice: _rawPriceOf(option),
          durationDays: durationDaysOf(option),
        )
      : null;

  /// 할인이 가장 큰 이용권 (가격을 읽은 것 중, 할인 없음 > null): 배너·리본 강조 대상
  Option? get bestDiscountOption {
    Option? bestOption;
    var bestPercent = 0;
    for (final candidate in options) {
      final percent = discountOf(candidate)?.discountPercent ?? 0;
      if (percent > bestPercent) {
        bestOption = candidate;
        bestPercent = percent;
      }
    }
    return bestOption;
  }
}
