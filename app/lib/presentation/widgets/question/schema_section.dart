import 'package:flutter/material.dart';
import '../../design/design.dart';

/// 스키마 DDL 섹션. 접을 수 있는 ExpansionTile.
/// schemaDdl이 있을 때만 표시.
class SchemaSection extends StatelessWidget {
  final String? schemaDdl;
  final String? schemaSampleData;

  const SchemaSection({super.key, this.schemaDdl, this.schemaSampleData});

  @override
  Widget build(BuildContext context) {
    if (schemaDdl == null || schemaDdl!.isEmpty) return const SizedBox.shrink();
    final c = context.pq;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PqSpace.md,
        vertical: PqSpace.xs,
      ),
      child: PqCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: PqSpace.md),
            shape: const Border(),
            collapsedShape: const Border(),
            title: Text(
              '스키마 보기',
              style: PqType.subheadlineSemibold.copyWith(color: c.label),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PqSpace.sm,
                  0,
                  PqSpace.sm,
                  PqSpace.sm,
                ),
                child: PqCodeBlock(code: schemaDdl!),
              ),
              if (schemaSampleData != null && schemaSampleData!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PqSpace.sm,
                    0,
                    PqSpace.sm,
                    PqSpace.sm,
                  ),
                  child: Text(
                    '샘플 데이터',
                    style: PqType.caption.copyWith(color: c.secondaryLabel),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
