import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pq_theme.dart';
import '../tokens/pq_metrics.dart';
import '../tokens/pq_type.dart';
import 'pq_pressable.dart';

enum PqButtonVariant { filled, tinted, plain, destructive }

enum PqButtonSize { large, regular, small }

/// 앱의 모든 버튼. 화면에서 ElevatedButton 등을 직접 꾸미지 않는다.
class PqButton extends StatelessWidget {
  const PqButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PqButtonVariant.filled,
    this.size = PqButtonSize.large,
    this.loading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final PqButtonVariant variant;
  final PqButtonSize size;
  final bool loading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    final enabled = onPressed != null && !loading;
    final (Color bg, Color fg) = switch (variant) {
      _ when !enabled && variant != PqButtonVariant.plain => (
        c.fill,
        c.tertiaryLabel,
      ),
      _ when !enabled => (Colors.transparent, c.tertiaryLabel),
      PqButtonVariant.filled => (c.accent, c.onAccent),
      PqButtonVariant.tinted => (c.accentTint, c.accent),
      PqButtonVariant.plain => (Colors.transparent, c.accent),
      PqButtonVariant.destructive => (c.wrongTint, c.wrong),
    };
    final minHeight = switch (size) {
      PqButtonSize.large => PqSize.buttonLarge,
      PqButtonSize.regular => PqSize.buttonRegular,
      PqButtonSize.small => PqSize.buttonSmall,
    };
    final text =
        (size == PqButtonSize.small
                ? PqType.subheadlineSemibold
                : PqType.headline)
            .copyWith(color: fg);
    final content = loading
        ? CupertinoActivityIndicator(color: fg)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: PqSpace.xs),
              ],
              Flexible(
                child: Text(label, style: text, textAlign: TextAlign.center),
              ),
            ],
          );
    return PqPressable(
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
              size == PqButtonSize.small ? PqRadius.capsule : PqRadius.md,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PqSpace.md,
              vertical: PqSpace.xs,
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
