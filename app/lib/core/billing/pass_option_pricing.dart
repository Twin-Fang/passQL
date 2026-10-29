import '../utils/profile_pass_values.dart';
import 'pass_discount.dart';
import 'pro_purchase_port.dart';

/// 1개월 > 긴 이용권 권유 재료: 바꿀 이용권, 아끼는 금액(원), 월 환산 금액(원)
typedef PassUpgradeSuggestion<Option> = ({
  Option longOption,
  int savings,
  int monthlyShare,
});

/// 이용권 목록 가격 계산: 기준(가장 짧은) 이용권, 할인, 할인 전 값, 긴 이용권 권유
/// 이용권 모델은 상품 ID·이용 일수 읽는 함수로만 받음 (core 는 data 모델 import 금지)
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

  /// 가장 짧은 이용권 대비 할인 (가격 없음·할인 없음·기준 칸 자신이면 null)
  PassDiscount? discountOf(Option option) {
    final base = baseOption;
    if (base == null) return null;
    return calculatePassDiscount(
      longPassPrice: _rawPriceOf(option),
      longPassMonths: _monthsOf(option),
      basePassPrice: _rawPriceOf(base),
      basePassMonths: _monthsOf(base),
    );
  }

  /// 할인 전 값(원, 반올림): 기준 이용권을 같은 기간만큼 샀을 때 (할인이 있을 때만)
  int? undiscountedPriceOf(Option option) {
    final base = baseOption;
    final basePrice = base == null ? null : _rawPriceOf(base);
    if (base == null || basePrice == null) return null;
    if (discountOf(option) == null) return null;
    final total = basePrice * _monthsOf(option) / _monthsOf(base);
    return total.round();
  }

  /// 기준(가장 짧은) 칸을 골랐을 때 가장 긴 이용권 권유 (없으면 null)
  PassUpgradeSuggestion<Option>? upgradeSuggestionFor(Option? selectedOption) {
    final base = baseOption;
    if (selectedOption == null || selectedOption != base) return null;
    final longOption = options.reduce(
      (longer, candidate) => durationDaysOf(candidate) > durationDaysOf(longer)
          ? candidate
          : longer,
    );
    if (longOption == base) return null;
    final savings = monthlySavingsOf(
      longPrice: _rawPriceOf(longOption),
      longMonths: _monthsOf(longOption),
      basePrice: _rawPriceOf(base as Option),
      baseMonths: _monthsOf(base),
    );
    if (savings == null) return null;
    return (
      longOption: longOption,
      savings: savings,
      monthlyShare: monthlyShareOf(savings, _monthsOf(longOption)),
    );
  }
}
