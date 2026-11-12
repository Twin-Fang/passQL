import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import 'pro_discount_badge.dart';

/// 이용권 카드 1장 (결제 시트에서 하나 고름, #749, #966): 기간 + 선택 표시 > 큰 가격 > 줄 그은 정가 + 할인율 > 만료일
/// 선택 카드 = 강조 테두리 + 옅은 강조 배경 (선택지 카드와 같은 규칙)
/// 스크린리더는 이름·가격·할인·만료일을 한 번에 읽음
class ProPassOptionTile extends StatelessWidget {
  const ProPassOptionTile({
    super.key,
    required this.label,
    required this.displayPrice,
    required this.isSelected,
    required this.onTap,
    this.originalPriceLabel,
    this.discountPercent,
    this.expiryLabel,
  });

  /// 예: 3개월
  final String label;

  /// 스토어 가격 문자열 (못 읽으면 null > 가격 자리 비움)
  final String? displayPrice;
  final bool isSelected;
  final VoidCallback? onTap;

  /// 할인 전 값 (예: ₩13,200, 줄 그어 보임. 할인 없음·원화 아님 > null)
  final String? originalPriceLabel;

  /// 할인율(예: 25, null 이면 배지 없음)
  final int? discountPercent;

  /// 예: 2027.01.26까지
  final String? expiryLabel;

  // 선택 카드 테두리 두께 (선택 1.5 · 기본 1, 선택지 카드와 같은 규격)
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기간 + 선택 표시 (선택 = 채운 체크, 기본 = 빈 원)
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: PassqlTypography.subheadlineSemibold.copyWith(
                    color: isSelected ? colors.accentText : colors.secondaryLabel,
                  ),
                ),
              ),
              Icon(
                isSelected
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.circle,
                size: PassqlIconSize.xl,
                color: isSelected ? colors.accent : colors.iconSecondary,
              ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.hairlineGap),
          // 가격 (좁은 폭·큰 글자에서는 줄여 한 줄 유지)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              displayPrice ?? ' ',
              maxLines: 1,
              style: PassqlTypography.title2.copyWith(color: colors.label),
            ),
          ),
          const SizedBox(height: PassqlSpacing.hairlineGap),
          _buildDiscountLine(context),
          if (expiryLabel != null) ...[
            const SizedBox(height: PassqlSpacing.xxs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                expiryLabel,
                maxLines: 1,
                style: PassqlTypography.caption.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
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

  /// 줄 그은 정가 + 할인율 배지 (할인 없는 카드도 같은 높이를 차지해 두 카드 줄이 맞음)
  Widget _buildDiscountLine(BuildContext context) {
    final colors = context.passqlColors;
    final originalPriceLabel = this.originalPriceLabel;
    final discountPercent = this.discountPercent;
    final footnote = PassqlTypography.footnote;
    return SizedBox(
      height: (footnote.fontSize ?? 0) * (footnote.height ?? 1) +
          PassqlSpacing.xxs,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (originalPriceLabel != null) ...[
              Text(
                originalPriceLabel,
                maxLines: 1,
                style: footnote.copyWith(
                  color: colors.secondaryLabel,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: colors.secondaryLabel,
                ),
              ),
              const SizedBox(width: PassqlSpacing.xs),
            ],
            if (discountPercent != null)
              ProDiscountBadge(
                discountPercent: discountPercent,
                isOnTint: isSelected,
              ),
          ],
        ),
      ),
    );
  }
}
