import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_pressable.dart';

/// 그림자 없이 배경 대비로만 구분되는 카드.
class PassqlCard extends StatelessWidget {
  const PassqlCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(PassqlSpacing.md),
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final body = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(PassqlRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: PassqlTypography.headline.copyWith(color: colors.label),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: PassqlSpacing.sm),
          ],
          child,
        ],
      ),
    );
    return onTap == null ? body : PassqlPressable(onTap: onTap, child: body);
  }
}
