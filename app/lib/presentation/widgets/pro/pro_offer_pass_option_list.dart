import 'package:flutter/material.dart';

import '../../../core/billing/pass_discount.dart';
import '../../../core/billing/pass_option_pricing.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import 'pro_pass_option_tile.dart';

/// 이용 일수 > 칸 이름 (90일 > 3개월)
String passMonthsLabelOf(PassOption option) =>
    '${toPassMonths(option.durationDays)}개월';

/// 이용권 고르기: 서버 순서대로 칸
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in pricing.options) ...[
          _buildOptionTile(option),
          const SizedBox(height: PassqlSpacing.xs),
        ],
      ],
    );
  }

  /// 이용권 1칸: 기간 + 할인율 작은 배지, 만료일, 가격만 (#963)
  Widget _buildOptionTile(PassOption option) {
    final discount = pricing.discountOf(option);
    final onSelect = this.onSelect;
    return ProPassOptionTile(
      label: passMonthsLabelOf(option),
      displayPrice: pricing.priceByProductId[option.productId]?.displayPrice,
      discountPercent: discount?.discountPercent,
      expiryLabel: '${formatDottedDate(option.expiresAtIfPurchased)}까지',
      isSelected: option == selectedOption,
      onTap: onSelect == null ? null : () => onSelect(option),
    );
  }
}
