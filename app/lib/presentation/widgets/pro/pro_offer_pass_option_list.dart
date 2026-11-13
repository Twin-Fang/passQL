import 'package:flutter/material.dart';

import '../../../core/billing/pass_discount.dart';
import '../../../core/billing/pass_option_pricing.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/number_format.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import 'pro_pass_option_tile.dart';

/// 이용 일수 > 칸 이름 (90일 > 3개월)
String passMonthsLabelOf(PassOption option) =>
    '${toPassMonths(option.durationDays)}개월';

// 원화 기호 (스토어 가격 문자열이 이 기호로 시작하면 정가도 같은 모양으로)
const String _wonSign = '₩';

/// 이용권 고르기: 서버 순서대로 카드를 나란히 (#966)
class ProOfferPassOptionList extends StatelessWidget {
  const ProOfferPassOptionList({
    super.key,
    required this.pricing,
    required this.selectedOption,
    required this.onSelect,
  });

  /// 이용권 목록 + 스토어 가격 계산
  final PassOptionPricing<PassOption> pricing;
  final PassOption? selectedOption;

  /// 칸 탭 (결제 중이면 null > 바꿀 수 없음)
  final ValueChanged<PassOption>? onSelect;

  @override
  Widget build(BuildContext context) {
    final options = pricing.options;
    // 카드 높이를 가장 큰 카드에 맞춤
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < options.length; index++) ...[
            if (index > 0) const SizedBox(width: PassqlSpacing.sm),
            Expanded(child: _buildOptionTile(options[index])),
          ],
        ],
      ),
    );
  }

  /// 할인 전 값 문구: 스토어 가격과 같은 모양 (₩13,200 또는 13,200원)
  String? _originalPriceLabelOf(PassOption option, String? displayPrice) {
    final undiscountedPrice = pricing.undiscountedPriceOf(option);
    if (undiscountedPrice == null) return null;
    final amount = formatThousands(undiscountedPrice);
    return (displayPrice?.startsWith(_wonSign) ?? false)
        ? '$_wonSign$amount'
        : '$amount원';
  }

  /// 이용권 카드 1장: 기간, 가격, 줄 그은 정가 + 할인율, 만료일
  Widget _buildOptionTile(PassOption option) {
    final discount = pricing.discountOf(option);
    final onSelect = this.onSelect;
    final displayPrice =
        pricing.priceByProductId[option.productId]?.displayPrice;
    return ProPassOptionTile(
      label: passMonthsLabelOf(option),
      displayPrice: displayPrice,
      originalPriceLabel: _originalPriceLabelOf(option, displayPrice),
      discountPercent: discount?.discountPercent,
      expiryLabel: '${formatDottedDate(option.expiresAtIfPurchased)}까지',
      isSelected: option == selectedOption,
      onTap: onSelect == null ? null : () => onSelect(option),
    );
  }
}
