import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// iOS 설정 앱의 inset grouped 목록 묶음.
class PassqlGroupedSection extends StatelessWidget {
  const PassqlGroupedSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
    this.separatorIndent = PassqlSpacing.md,
  });

  final String? header;
  final String? footer;
  final List<Widget> children;
  final double separatorIndent;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i < children.length - 1) {
        rows.add(
          Padding(
            padding: EdgeInsets.only(left: separatorIndent),
            child: Container(height: PassqlSize.hairline, color: colors.separator),
          ),
        );
      }
    }
    // 내용 높이만 차지한다. 기본(max)이면 시트처럼 높이 제한이 있는 곳에서 남은 공간을 다 채운다.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(PassqlSpacing.md, 0, PassqlSpacing.md, 6),
            child: Text(
              header!,
              style: PassqlTypography.footnote.copyWith(color: colors.secondaryLabel),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(PassqlRadius.lg),
          child: ColoredBox(
            color: colors.card,
            child: Column(children: rows),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(PassqlSpacing.md, 6, PassqlSpacing.md, 0),
            child: Text(
              footer!,
              style: PassqlTypography.footnote.copyWith(color: colors.secondaryLabel),
            ),
          ),
      ],
    );
  }
}
