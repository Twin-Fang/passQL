import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import 'pro_discount_badge.dart';

/// 이용권 1칸 (결제 시트에서 하나 고름, #749): 라디오 > 기간 + 작은 할인 배지 + 만료일 > 가격 (#963)
/// 선택 칸 = 강조 테두리 + 옅은 강조 배경 (선택지 카드와 같은 규칙)
/// 스크린리더는 이름·가격·할인·만료일을 한 번에 읽음
class ProPassOptionTile extends StatelessWidget {
  const ProPassOptionTile({
    super.key,
    required this.label,
    required this.displayPrice,
    required this.isSelected,
    required this.onTap,
    this.discountPercent,
    this.expiryLabel,
  });

  /// 예: 3개월
  final String label;

  /// 스토어 가격 문자열 (못 읽으면 null > 가격 자리 비움)
  final String? displayPrice;
  final bool isSelected;
  final VoidCallback? onTap;

  /// 할인율(예: 25, null 이면 배지 없음)
  final int? discountPercent;

  /// 예: 2027.01.26까지
  final String? expiryLabel;

  // 선택 칸 테두리 두께 (선택 1.5 · 기본 1, 선택지 카드와 같은 규격)
  static const double _selectedBorderWidth = 1.5;
  static const double _idleBorderWidth = 1;

  String get _semanticLabel => [
    label,
    ?displayPrice,
    if (discountPercent != null) '$discountPercent% 할인',
    ?expiryLabel,
  ].join(', ');

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final displayPrice = this.displayPrice;
    final discountPercent = this.discountPercent;
    final expiryLabel = this.expiryLabel;
    final tile = AnimatedContainer(
      duration: PassqlMotion.durationOf(context, PassqlMotion.fast),
      curve: PassqlMotion.curve,
      padding: const EdgeInsets.all(PassqlSpacing.sm),
      decoration: BoxDecoration(
        color: isSelected
            ? Color.alphaBlend(colors.accentTint, colors.card)
            : colors.card,
        borderRadius: BorderRadius.circular(PassqlRadius.md),
        border: Border.all(
          color: isSelected ? colors.accent : colors.separator,
          width: isSelected ? _selectedBorderWidth : _idleBorderWidth,
        ),
      ),
      child: Row(
        children: [
          // 라디오 (선택 = 채운 원, 기본 = 빈 원)
          Icon(
            isSelected
                ? CupertinoIcons.largecircle_fill_circle
                : CupertinoIcons.circle,
            size: PassqlIconSize.xl,
            color: isSelected ? colors.accent : colors.iconSecondary,
          ),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 기간 옆 작은 할인 배지 (좁은 폭이면 줄바꿈)
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: PassqlSpacing.xs,
                  children: [
                    Text(
                      label,
                      style: PassqlTypography.headline.copyWith(
                        color: colors.label,
                      ),
                    ),
                    if (discountPercent != null)
                      ProDiscountBadge(discountPercent: discountPercent),
                  ],
                ),
                if (expiryLabel != null)
                  Text(
                    expiryLabel,
                    style: PassqlTypography.footnote.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
              ],
            ),
          ),
          if (displayPrice != null) ...[
            const SizedBox(width: PassqlSpacing.xs),
            Text(
              displayPrice,
              style: PassqlTypography.title3.copyWith(color: colors.label),
            ),
          ],
        ],
      ),
    );
    return PassqlSemanticButton(
      label: _semanticLabel,
      isSelected: isSelected,
      onTap: onTap,
      child: PassqlPressable(onTap: onTap, child: tile),
    );
  }
}
