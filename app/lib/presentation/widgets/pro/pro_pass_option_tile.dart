import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 이용권 1칸 (결제 시트에서 하나 고름, #749): 라디오 > 이름 + 아래 작은 글자(월 환산·만료일) > 원래 값 줄긋기 + 가격.
/// 할인이 있으면 왼쪽 위 빨간 리본. 선택 칸 = 강조 테두리 + 옅은 강조 배경 (선택지 카드와 같은 규칙)
/// 스크린리더는 이름·가격·할인·만료일을 한 번에 읽음
class ProPassOptionTile extends StatelessWidget {
  const ProPassOptionTile({
    super.key,
    required this.label,
    required this.displayPrice,
    required this.isSelected,
    required this.onTap,
    this.ribbonLabel,
    this.undiscountedPrice,
    this.monthlyLabel,
    this.expiryLabel,
  });

  /// 예: 3개월
  final String label;

  /// 스토어 가격 문자열 (못 읽으면 null > 가격 자리 비움)
  final String? displayPrice;
  final bool isSelected;
  final VoidCallback? onTap;

  /// 예: 25% 할인 (null 이면 리본 없음)
  final String? ribbonLabel;

  /// 할인 전 값 (예: 13,200원, 줄긋기)
  final String? undiscountedPrice;

  /// 예: 월 3,300원 (강조색)
  final String? monthlyLabel;

  /// 예: 2027.01.26까지
  final String? expiryLabel;

  // 선택 칸 테두리 두께 (선택 1.5 · 기본 1, 선택지 카드와 같은 규격)
  static const double _selectedBorderWidth = 1.5;
  static const double _idleBorderWidth = 1;
  // 리본이 칸 위 테두리에 걸치는 높이
  static const double _ribbonOverlap = 10;

  String get _semanticLabel => [
    label,
    ?displayPrice,
    ?ribbonLabel,
    ?monthlyLabel,
    ?expiryLabel,
  ].join(', ');

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final displayPrice = this.displayPrice;
    final ribbonLabel = this.ribbonLabel;
    final undiscountedPrice = this.undiscountedPrice;
    final monthlyLabel = this.monthlyLabel;
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
                Text(
                  label,
                  style: PassqlTypography.headline.copyWith(
                    color: colors.label,
                  ),
                ),
                if (monthlyLabel != null)
                  Text(
                    monthlyLabel,
                    style: PassqlTypography.footnoteSemibold.copyWith(
                      color: colors.accentText,
                    ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (undiscountedPrice != null)
                  Text(
                    undiscountedPrice,
                    style: PassqlTypography.caption.copyWith(
                      color: colors.secondaryLabel,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  displayPrice,
                  style: PassqlTypography.title3.copyWith(color: colors.label),
                ),
              ],
            ),
          ],
        ],
      ),
    );
    return PassqlSemanticButton(
      label: _semanticLabel,
      isSelected: isSelected,
      onTap: onTap,
      child: PassqlPressable(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(
            top: ribbonLabel == null ? 0 : _ribbonOverlap,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              tile,
              if (ribbonLabel != null)
                Positioned(
                  top: -_ribbonOverlap,
                  left: PassqlSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PassqlSpacing.xs,
                      vertical: PassqlSpacing.hairlineGap,
                    ),
                    decoration: BoxDecoration(
                      color: colors.wrong,
                      borderRadius: BorderRadius.circular(PassqlRadius.sm),
                    ),
                    child: Text(
                      ribbonLabel,
                      style: PassqlTypography.captionSemibold.copyWith(
                        color: colors.onSemantic,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
