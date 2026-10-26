import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_loading_indicator.dart';
import 'passql_pressable.dart';

enum PassqlButtonVariant { filled, tinted, plain, destructive }

enum PassqlButtonSize { large, regular, small }

/// 앱의 모든 버튼. 화면에서 ElevatedButton 등을 직접 꾸미지 않는다.
class PassqlButton extends StatelessWidget {
  const PassqlButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PassqlButtonVariant.filled,
    this.size = PassqlButtonSize.large,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final PassqlButtonVariant variant;
  final PassqlButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  /// 모양·활성 > (배경, 글자색). 비활성 글자는 대비 기준 예외(WCAG)라 tertiaryLabel
  static (Color backgroundColor, Color foregroundColor) colorsOf(
    PassqlButtonVariant variant,
    PassqlColors colors, {
    required bool isEnabled,
  }) => switch (variant) {
    _ when !isEnabled && variant != PassqlButtonVariant.plain => (
      colors.fill,
      colors.tertiaryLabel,
    ),
    _ when !isEnabled => (Colors.transparent, colors.tertiaryLabel),
    PassqlButtonVariant.filled => (colors.accent, colors.onAccent),
    PassqlButtonVariant.tinted => (colors.accentTint, colors.accentText),
    PassqlButtonVariant.plain => (Colors.transparent, colors.accentText),
    PassqlButtonVariant.destructive => (colors.wrongTint, colors.wrongText),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isEnabled = onPressed != null && !isLoading;
    final (backgroundColor, foregroundColor) = colorsOf(
      variant,
      colors,
      isEnabled: isEnabled,
    );
    final minHeight = switch (size) {
      PassqlButtonSize.large => PassqlSize.buttonLarge,
      PassqlButtonSize.regular => PassqlSize.buttonRegular,
      PassqlButtonSize.small => PassqlSize.buttonSmall,
    };
    final labelStyle =
        (size == PassqlButtonSize.small
                ? PassqlTypography.subheadlineSemibold
                : PassqlTypography.headline)
            .copyWith(color: foregroundColor);
    final content = isLoading
        ? PassqlLoadingIndicator(color: foregroundColor)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: PassqlIconSize.md, color: foregroundColor),
                const SizedBox(width: PassqlSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  style: labelStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
    return PassqlPressable(
      onTap: isEnabled ? onPressed : null,
      semanticLabel: label,
      // small(34)도 누르는 영역은 44
      hasMinimumTouchTarget: size == PassqlButtonSize.small,
      child: ConstrainedBox(
        // 글자 크기가 커지면 높이가 늘어나도록 최소 높이만 정한다.
        constraints: BoxConstraints(
          minHeight: minHeight,
          minWidth: isFullWidth ? double.infinity : 0,
        ),
        // 활성·비활성 전환 때 배경색이 부드럽게 바뀌게 한다
        child: AnimatedContainer(
          duration: PassqlMotion.durationOf(context, PassqlMotion.fast),
          curve: PassqlMotion.curve,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(
              size == PassqlButtonSize.small
                  ? PassqlRadius.capsule
                  : PassqlRadius.md,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PassqlSpacing.md,
              vertical: PassqlSpacing.xs,
            ),
            // heightFactor 가 없으면 Center 가 세로로 가득 차 버튼이 화면 높이만큼 늘어난다.
            child: Center(
              widthFactor: isFullWidth ? null : 1,
              heightFactor: 1,
              // 라벨 <-> 로딩 표시 교체
              child: AnimatedSwitcher(
                duration: PassqlMotion.durationOf(context, PassqlMotion.fast),
                child: KeyedSubtree(key: ValueKey(isLoading), child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
