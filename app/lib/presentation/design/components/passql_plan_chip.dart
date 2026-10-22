import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_pressable.dart';

/// 등급 칩: 무료는 회색 FREE (누르면 [onTap]), 프로는 보라 PRO (누를 수 없음)
class PassqlPlanChip extends StatelessWidget {
  const PassqlPlanChip({super.key, required this.isPro, this.onTap});

  final bool isPro;

  /// 무료 칩을 눌렀을 때 (프로 칩은 무시)
  final VoidCallback? onTap;

  /// 칩 글자
  static const String freeLabel = 'FREE';
  static const String proLabel = 'PRO';

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final (String label, Color backgroundColor, Color foregroundColor) = isPro
        ? (proLabel, colors.accentTint, colors.accent)
        : (freeLabel, colors.fill, colors.secondaryLabel);
    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.xs,
        vertical: PassqlSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
      ),
      child: Text(
        label,
        style: PassqlTypography.captionSemibold.copyWith(
          color: foregroundColor,
        ),
      ),
    );
    final tapHandler = isPro ? null : onTap;
    if (tapHandler == null) return chip;
    return PassqlPressable(
      onTap: tapHandler,
      semanticLabel: label,
      // 작은 칩이라 터치 영역만 최소 크기로 넓힘
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: PassqlSize.minTouchTarget),
        child: Center(widthFactor: 1, child: chip),
      ),
    );
  }
}
