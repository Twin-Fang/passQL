import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pq_theme.dart';
import '../tokens/pq_metrics.dart';
import '../tokens/pq_type.dart';
import 'pq_pressable.dart';

/// 그림자 없이 배경 대비로만 구분되는 카드.
class PqCard extends StatelessWidget {
  const PqCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(PqSpace.md),
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    final body = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(PqRadius.lg),
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
                    style: PqType.headline.copyWith(color: c.label),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: PqSpace.sm),
          ],
          child,
        ],
      ),
    );
    return onTap == null ? body : PqPressable(onTap: onTap, child: body);
  }
}
