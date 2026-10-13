import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pq_theme.dart';
import '../tokens/pq_metrics.dart';
import '../tokens/pq_type.dart';
import 'pq_pressable.dart';

/// iOS 설정 앱의 inset grouped 목록 묶음.
class PqGroupedSection extends StatelessWidget {
  const PqGroupedSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
    this.separatorIndent = PqSpace.md,
  });

  final String? header;
  final String? footer;
  final List<Widget> children;
  final double separatorIndent;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i < children.length - 1) {
        rows.add(
          Padding(
            padding: EdgeInsets.only(left: separatorIndent),
            child: Container(height: PqSize.hairline, color: c.separator),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(PqSpace.md, 0, PqSpace.md, 6),
            child: Text(
              header!,
              style: PqType.footnote.copyWith(color: c.secondaryLabel),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(PqRadius.lg),
          child: ColoredBox(
            color: c.card,
            child: Column(children: rows),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(PqSpace.md, 6, PqSpace.md, 0),
            child: Text(
              footer!,
              style: PqType.footnote.copyWith(color: c.secondaryLabel),
            ),
          ),
      ],
    );
  }
}

class PqListRow extends StatelessWidget {
  const PqListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.chevron = false,
    this.destructive = false,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool chevron;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: PqSize.rowMin),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PqSpace.md,
          vertical: 11,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: PqSpace.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: PqType.body.copyWith(
                      color: destructive ? c.wrong : c.label,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: PqType.footnote.copyWith(color: c.secondaryLabel),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: PqSpace.xs),
              DefaultTextStyle(
                style: PqType.body.copyWith(color: c.secondaryLabel),
                child: trailing!,
              ),
            ],
            if (chevron) ...[
              const SizedBox(width: PqSpace.xs),
              Icon(
                CupertinoIcons.chevron_forward,
                size: 14,
                color: c.tertiaryLabel,
              ),
            ],
          ],
        ),
      ),
    );
    return onTap == null
        ? row
        : PqPressable(onTap: onTap, semanticLabel: title, child: row);
  }
}

/// 행 왼쪽의 색 아이콘 타일(iOS 설정 앱 규격 29pt, 모서리 7).
class PqIconTile extends StatelessWidget {
  const PqIconTile({super.key, required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: PqSize.iconTile,
    height: PqSize.iconTile,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(PqRadius.iconTile),
    ),
    child: Icon(icon, size: 17, color: Colors.white),
  );
}
