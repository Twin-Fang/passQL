import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
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
    this.loading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final PassqlButtonVariant variant;
  final PassqlButtonSize size;
  final bool loading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final enabled = onPressed != null && !loading;
    final (Color bg, Color fg) = switch (variant) {
      _ when !enabled && variant != PassqlButtonVariant.plain => (
        colors.fill,
        colors.tertiaryLabel,
      ),
      _ when !enabled => (Colors.transparent, colors.tertiaryLabel),
      PassqlButtonVariant.filled => (colors.accent, colors.onAccent),
      PassqlButtonVariant.tinted => (colors.accentTint, colors.accent),
      PassqlButtonVariant.plain => (Colors.transparent, colors.accent),
      PassqlButtonVariant.destructive => (colors.wrongTint, colors.wrong),
    };
    final minHeight = switch (size) {
      PassqlButtonSize.large => PassqlSize.buttonLarge,
      PassqlButtonSize.regular => PassqlSize.buttonRegular,
      PassqlButtonSize.small => PassqlSize.buttonSmall,
    };
    final text =
        (size == PassqlButtonSize.small
                ? PassqlTypography.subheadlineSemibold
                : PassqlTypography.headline)
            .copyWith(color: fg);
    final content = loading
        ? CupertinoActivityIndicator(color: fg)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: PassqlSpacing.xs),
              ],
              Flexible(
                child: Text(label, style: text, textAlign: TextAlign.center),
              ),
            ],
          );
    return PassqlPressable(
      onTap: enabled ? onPressed : null,
      semanticLabel: label,
      child: ConstrainedBox(
        // 글자 크기가 커지면 높이가 늘어나도록 최소 높이만 정한다.
        constraints: BoxConstraints(
          minHeight: minHeight,
          minWidth: expand ? double.infinity : 0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(
              size == PassqlButtonSize.small ? PassqlRadius.capsule : PassqlRadius.md,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PassqlSpacing.md,
              vertical: PassqlSpacing.xs,
            ),
            // heightFactor 가 없으면 Center 가 세로로 가득 차 버튼이 화면 높이만큼 늘어난다.
            child: Center(
              widthFactor: expand ? null : 1,
              heightFactor: 1,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
