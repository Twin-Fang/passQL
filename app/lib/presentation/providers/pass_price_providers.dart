import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/billing/pass_option_pricing.dart';
import '../../core/billing/pro_purchase_port.dart';
import '../../data/models/member/member_plan_response.dart';
import 'plan_providers.dart';

// 상품 ID 목록을 한 값으로 비교하기 위한 구분자 (목록 select 는 매번 새 객체라 다시 계산됨)
const String _productIdSeparator = ',';

/// 판매 이용권 스토어 가격 (#816 프로필 배너·연장 카드): 등급 응답 passOptions 상품만 조회, 못 읽은 상품은 빠짐
/// 시뮬레이터·결제 없는 환경은 빈 값 > 화면이 가격 자리를 숨김
final passPricesProvider = FutureProvider.autoDispose<Map<String, PassPrice>>((
  ref,
) async {
  final productIdsText = ref.watch(
    knownPlanProvider.select(
      (plan) => [
        for (final option in plan?.passOptions ?? const <PassOption>[])
          option.productId,
      ].join(_productIdSeparator),
    ),
  );
  if (productIdsText.isEmpty) return const {};
  return ref
      .read(proPurchasePortProvider)
      .loadPassPrices(productIdsText.split(_productIdSeparator));
});

/// 판매 이용권 + 스토어 가격 계산 (할인·하루 가격·가장 큰 할인 이용권). 가격 조회 중·실패면 가격 없는 계산
final passOptionPricingProvider =
    Provider.autoDispose<PassOptionPricing<PassOption>>((ref) {
      return PassOptionPricing(
        options: ref.watch(
          knownPlanProvider.select(
            (plan) => plan?.passOptions ?? const <PassOption>[],
          ),
        ),
        priceByProductId: ref.watch(passPricesProvider).valueOrNull ?? const {},
        productIdOf: (option) => option.productId,
        durationDaysOf: (option) => option.durationDays,
      );
    });
