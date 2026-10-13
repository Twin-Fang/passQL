import 'package:flutter/material.dart';

import '../pq_theme.dart';
import '../tokens/pq_metrics.dart';
import '../tokens/pq_type.dart';

/// SQL 표시 공통 블록. 긴 줄은 가로로 스크롤하고 길게 눌러 복사할 수 있다.
class PqCodeBlock extends StatelessWidget {
  const PqCodeBlock({super.key, required this.code, this.selectable = true});
  final String code;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    final style = PqType.code.copyWith(color: c.label);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.fill,
        borderRadius: BorderRadius.circular(PqRadius.sm),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(PqSpace.sm),
        child: selectable
            ? SelectableText(code, style: style)
            : Text(code, style: style),
      ),
    );
  }
}
