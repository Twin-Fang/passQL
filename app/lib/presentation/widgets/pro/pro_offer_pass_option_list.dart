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

/// 이용권 고르기: 서버 순서대로 칸 > 기준(1개월) 칸을 골랐으면 긴 이용권 권유 줄
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

  /// 칸·권유 줄 탭 (결제 중이면 null > 바꿀 수 없음)
  final ValueChanged<PassOption>? onSelect;

  @override
  Widget build(BuildContext context) {
    final upgrade = pricing.upgradeSuggestionFor(selectedOption);
    final onSelect = this.onSelect;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in pricing.options) ...[
          _buildOptionTile(option),
          const SizedBox(height: PassqlSpacing.xs),
        ],
        if (upgrade != null)
          _UpgradeSuggestion(
            savings: upgrade.savings,
            monthlyShare: upgrade.monthlyShare,
            longLabel: passMonthsLabelOf(upgrade.longOption),
            onTap: onSelect == null ? null : () => onSelect(upgrade.longOption),
          ),
      ],
    );
  }

  /// 이용권 1칸: 할인 있으면 리본·할인 전 값·월 환산
  Widget _buildOptionTile(PassOption option) {
    final discount = pricing.discountOf(option);
    final undiscountedPrice = pricing.undiscountedPriceOf(option);
    final onSelect = this.onSelect;
    return ProPassOptionTile(
      label: passMonthsLabelOf(option),
      displayPrice: pricing.priceByProductId[option.productId]?.displayPrice,
      ribbonLabel: discount == null ? null : '${discount.discountPercent}% 할인',
      undiscountedPrice: undiscountedPrice == null
          ? null
          : '${formatThousands(undiscountedPrice)}원',
      monthlyLabel: discount == null
          ? null
          : '월 ${formatThousands(discount.monthlyPrice)}원',
      expiryLabel: '${formatDottedDate(option.expiresAtIfPurchased)}까지',
      isSelected: option == selectedOption,
      onTap: onSelect == null ? null : () => onSelect(option),
    );
  }
}

/// 1개월을 골랐을 때 긴 이용권 권유 한 줄 (막지 않고 아끼는 금액만 보여 준다)
class _UpgradeSuggestion extends StatelessWidget {
  const _UpgradeSuggestion({
    required this.savings,
    required this.monthlyShare,
    required this.longLabel,
    required this.onTap,
  });

  final int savings;
  final int monthlyShare;
  final String longLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final message =
        '$longLabel로 바꾸면 ${formatThousands(savings)}원 아껴요 (월 ${formatThousands(monthlyShare)}원씩)';
    return PassqlPressable(
      onTap: onTap,
      semanticLabel: '$message, $longLabel로 바꾸기',
      child: Container(
        padding: const EdgeInsets.all(PassqlSpacing.sm),
        decoration: BoxDecoration(
          color: colors.accentTint,
          borderRadius: BorderRadius.circular(PassqlRadius.md),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: PassqlTypography.footnote.copyWith(color: colors.label),
              ),
            ),
            const SizedBox(width: PassqlSpacing.xs),
            Text(
              '$longLabel로 바꾸기 ›',
              style: PassqlTypography.footnoteSemibold.copyWith(
                color: colors.accentText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
