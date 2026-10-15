import 'package:flutter/cupertino.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_pressable.dart';

class PassqlListRow extends StatelessWidget {
  const PassqlListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.hasChevron = false,
    this.isDestructive = false,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool hasChevron;
  final bool isDestructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: PassqlSize.rowMin),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PassqlSpacing.md,
          vertical: 11,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: PassqlSpacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: PassqlTypography.body.copyWith(
                      color: isDestructive ? colors.wrong : colors.label,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: PassqlTypography.footnote.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: PassqlSpacing.xs),
              DefaultTextStyle(
                style: PassqlTypography.body.copyWith(
                  color: colors.secondaryLabel,
                ),
                child: trailing!,
              ),
            ],
            if (hasChevron) ...[
              const SizedBox(width: PassqlSpacing.xs),
              Icon(
                CupertinoIcons.chevron_forward,
                size: 14,
                color: colors.tertiaryLabel,
              ),
            ],
          ],
        ),
      ),
    );
    return onTap == null
        ? row
        : PassqlPressable(onTap: onTap, semanticLabel: title, child: row);
  }
}
