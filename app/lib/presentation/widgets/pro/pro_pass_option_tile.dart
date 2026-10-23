import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 이용권 1칸 (결제 시트에서 하나 고름): 선택 원 > 이름 + (할인 배지) > 스토어 가격
/// 선택 칸 = 강조 테두리 + 옅은 강조 배경, 스크린리더는 이름·가격·할인을 한 번에 읽음
class ProPassOptionTile extends StatelessWidget {
  const ProPassOptionTile({
    super.key,
    required this.label,
    required this.displayPrice,
    required this.discountLabel,
    required this.isSelected,
    required this.onTap,
  });

  /// 예: 3개월 이용권
  final String label;

  /// 스토어 가격 문자열 (못 읽으면 null > 가격 자리 비움)
  final String? displayPrice;

  /// 예: 25% 할인 · 월 3,300원 (null 이면 배지 없음)
  final String? discountLabel;

  final bool isSelected;
  final VoidCallback? onTap;

  // 선택 칸 테두리 두께 (선택 1.5 · 기본 1, 선택지 카드와 같은 규격)
  static const double _selectedBorderWidth = 1.5;
  static const double _idleBorderWidth = 1;

  String get _semanticLabel =>
      [label, ?displayPrice, ?discountLabel].join(', ');

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final discountLabel = this.discountLabel;
    final displayPrice = this.displayPrice;
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
          // 선택 원 (선택 = 채운 체크, 기본 = 빈 원)
          Icon(
            isSelected
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.circle,
            size: PassqlIconSize.xl,
            color: isSelected ? colors.accent : colors.iconSecondary,
          ),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: PassqlTypography.headline.copyWith(
                    color: colors.label,
                  ),
                ),
                if (discountLabel != null) ...[
                  const SizedBox(height: PassqlSpacing.xxs),
                  PassqlBadge(text: discountLabel),
                ],
              ],
            ),
          ),
          if (displayPrice != null) ...[
            const SizedBox(width: PassqlSpacing.xs),
            Text(
              displayPrice,
              style: PassqlTypography.headline.copyWith(color: colors.label),
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
