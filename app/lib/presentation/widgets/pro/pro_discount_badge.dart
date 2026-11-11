import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 할인 배지 `25%` (#816, #963): 옅은 강조 바탕 + 강조 글자 캡슐 (이용권 칸·프로필 배너·연장 카드 공통)
class ProDiscountBadge extends StatelessWidget {
  const ProDiscountBadge({super.key, required this.discountPercent});

  final int discountPercent;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.xs,
        vertical: PassqlSpacing.hairlineGap,
      ),
      decoration: BoxDecoration(
        color: colors.accentTint,
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
      ),
      child: Text(
        '$discountPercent%',
        style: PassqlTypography.captionSemibold.copyWith(
          color: colors.accentText,
        ),
      ),
    );
  }
}
