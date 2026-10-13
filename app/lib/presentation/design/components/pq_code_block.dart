import 'package:flutter/material.dart';

import '../pq_theme.dart';
import '../tokens/pq_metrics.dart';
import '../tokens/pq_type.dart';

/// SQL 표시 공통 블록. 기본은 줄바꿈해 전체가 보이게 하고, 정렬이 중요한 곳만
/// `wrap: false`로 가로 스크롤한다. 길게 눌러 복사할 수 있다.
class PqCodeBlock extends StatelessWidget {
  const PqCodeBlock({
    super.key,
    required this.code,
    this.selectable = true,
    this.wrap = true,
  });
  final String code;
  final bool selectable;

  /// true면 줄바꿈, false면 가로 스크롤.
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    final style = PqType.code.copyWith(color: c.label);
    final text = selectable
        ? SelectableText(code, style: style)
        : Text(code, style: style);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.fill,
        borderRadius: BorderRadius.circular(PqRadius.sm),
      ),
      child: wrap
          ? Padding(padding: const EdgeInsets.all(PqSpace.sm), child: text)
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(PqSpace.sm),
              child: text,
            ),
    );
  }
}
