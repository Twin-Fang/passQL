import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/billing/pass_option_pricing.dart';
import 'package:passql_app/core/billing/pro_purchase_port.dart';

/// 이용권 칸: (상품 ID, 이용 일수)
typedef _Option = ({String productId, int durationDays});

const _Option _threeMonthPass = (productId: 'pro_pass_3m', durationDays: 90);
const _Option _oneMonthPass = (productId: 'pro_pass_1m', durationDays: 30);

PassOptionPricing<_Option> _pricingOf(
  Map<String, PassPrice> priceByProductId,
) => PassOptionPricing(
  options: const [_threeMonthPass, _oneMonthPass],
  priceByProductId: priceByProductId,
  productIdOf: (option) => option.productId,
  durationDaysOf: (option) => option.durationDays,
);

/// 원 금액 표시 규칙 (#867): 원화면 하루·할인 전·월 환산·권유, 원화가 아니면 할인율만
void main() {
  test('원화 가격은 하루 가격·할인 전 값·월 환산·권유를 계산한다', () {
    final pricing = _pricingOf(const {
      'pro_pass_3m': PassPrice(
        displayPrice: '₩9,900',
        rawPrice: 9900,
        currencyCode: koreanWonCurrencyCode,
      ),
      'pro_pass_1m': PassPrice(
        displayPrice: '₩4,400',
        rawPrice: 4400,
        currencyCode: koreanWonCurrencyCode,
      ),
    });

    expect(pricing.dailyPriceOf(_threeMonthPass), 110);
    expect(pricing.undiscountedPriceOf(_threeMonthPass), 13200);
  });

  test('원화가 아니면 원 금액은 모두 숨기고 할인율만 남긴다', () {
    final pricing = _pricingOf(const {
      'pro_pass_3m': PassPrice(
        displayPrice: r'$5.99',
        rawPrice: 5.99,
        currencyCode: 'USD',
      ),
      'pro_pass_1m': PassPrice(
        displayPrice: r'$2.99',
        rawPrice: 2.99,
        currencyCode: 'USD',
      ),
    });

    expect(pricing.dailyPriceOf(_threeMonthPass), isNull);
    expect(pricing.undiscountedPriceOf(_threeMonthPass), isNull);
    expect(pricing.discountOf(_threeMonthPass)?.discountPercent, 33);
  });
}
