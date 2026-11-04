import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 할인 배지 `25% 할인` (#816): 빨간 바탕 + 흰 글자 캡슐 (이용권 시트 리본과 같은 색, 프로필 배너·연장 카드 공통)
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
        color: colors.wrong,
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
      ),
      child: Text(
        '$discountPercent% 할인',
        style: PassqlTypography.captionSemibold.copyWith(
          color: colors.onSemantic,
        ),
      ),
    );
  }
}
