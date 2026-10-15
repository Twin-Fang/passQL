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

  /// 한 줄 제목일 때 행 높이가 44pt 가 되는 위아래 여백 (iOS 설정 앱 규격)
  static const double _verticalPadding = 11;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: PassqlSize.rowMin),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PassqlSpacing.md,
          vertical: _verticalPadding,
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
                size: PassqlIconSize.xs,
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
