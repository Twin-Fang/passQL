import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 할인 배지 (#816, #963): 옅은 강조 바탕 + 강조 글자 캡슐 (이용권 칸·프로필 배너·연장 카드 공통)
/// 글자: 짧게 `-25%`(이용권 카드, 줄 그은 정가 옆) 또는 `25% 할인`(단독으로 보이는 곳)
/// 바탕: 일반 카드 위는 옅은 강조색, 옅은 강조 바탕(선택 카드) 위는 카드색, 강한 색 바탕(배너 그라데이션) 위는 흰 바탕 + 강조 글자 (대비 4.5:1)
class ProDiscountBadge extends StatelessWidget {
  const ProDiscountBadge({
    super.key,
    required this.discountPercent,
    this.isShortLabel = true,
    this.isOnStrongColor = false,
    this.isOnTint = false,
  });

  final int discountPercent;

  /// true 면 `-25%`, false 면 `25% 할인`
  final bool isShortLabel;

  /// 강조색 그라데이션 같은 진한 바탕 위에 놓는가
  final bool isOnStrongColor;

  /// 옅은 강조 바탕(선택된 이용권 카드) 위에 놓는가
  final bool isOnTint;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.xs,
        vertical: PassqlSpacing.hairlineGap,
      ),
      decoration: BoxDecoration(
        color: isOnStrongColor
            ? colors.onAccent
            : (isOnTint ? colors.card : colors.accentTint),
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
      ),
      child: Text(
        isShortLabel ? '-$discountPercent%' : '$discountPercent% 할인',
        style: PassqlTypography.captionSemibold.copyWith(
          color: isOnStrongColor ? colors.accent : colors.accentText,
        ),
      ),
    );
  }
}
