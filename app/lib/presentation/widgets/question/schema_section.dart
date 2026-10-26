import 'package:flutter/cupertino.dart';

import '../../../data/models/question/question_schema_table.dart';
import '../../design/design.dart';
import 'schema_table_preview.dart';

/// 문제 테이블 영역 (#520): 기본 펼침, 머리 눌러 접기·펼치기 (제출 전·후 공통)
/// 테이블 목록 있음 > 테이블별 컬럼·샘플 행 / 없음 + DDL 있음 > DDL·INSERT 원문 / 둘 다 없음 > 그리지 않음
class SchemaSection extends StatefulWidget {
  const SchemaSection({
    super.key,
    required this.tables,
    this.schemaDdl,
    this.schemaSampleData,
  });

  /// 서버가 해석한 테이블 목록
  final List<QuestionSchemaTable> tables;

  /// 해석 결과가 비었을 때만 원문으로 보여 줄 DDL·샘플 INSERT (구버전 서버 대비)
  final String? schemaDdl;
  final String? schemaSampleData;

  @override
  State<SchemaSection> createState() => _SchemaSectionState();
}

class _SchemaSectionState extends State<SchemaSection> {
  bool _isExpanded = true;

  bool get _hasRawSchemaFallback =>
      widget.tables.isEmpty && (widget.schemaDdl?.trim().isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    if (widget.tables.isEmpty && !_hasRawSchemaFallback) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.md,
        vertical: PassqlSpacing.xs,
      ),
      child: PassqlCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SchemaSectionHeader(
              tableCount: widget.tables.length,
              isExpanded: _isExpanded,
              onTap: () => setState(() => _isExpanded = !_isExpanded),
            ),
            if (_isExpanded) ...[
              const SizedBox(height: PassqlSpacing.sm),
              ..._buildExpandedContent(),
            ],
          ],
        ),
      ),
    );
  }

  /// 펼친 내용: 테이블 미리보기 목록 또는 원문 코드 블록
  List<Widget> _buildExpandedContent() {
    final contents = _hasRawSchemaFallback
        ? <Widget>[
            PassqlCodeBlock(code: widget.schemaDdl!),
            if (widget.schemaSampleData?.trim().isNotEmpty ?? false)
              PassqlCodeBlock(code: widget.schemaSampleData!),
          ]
        : <Widget>[
            for (final table in widget.tables)
              SchemaTablePreview(key: ValueKey(table.tableName), table: table),
          ];
    return [
      for (var index = 0; index < contents.length; index++) ...[
        if (index > 0) const SizedBox(height: PassqlSpacing.md),
        contents[index],
      ],
    ];
  }
}

/// 영역 머리: 아이콘 + '테이블 N개' + 접힘 방향 표시 (줄 전체가 누름 영역)
class _SchemaSectionHeader extends StatelessWidget {
  const _SchemaSectionHeader({
    required this.tableCount,
    required this.isExpanded,
    required this.onTap,
  });

  final int tableCount;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final title = tableCount > 0 ? '테이블 $tableCount개' : '테이블';
    return PassqlPressable(
      onTap: onTap,
      semanticLabel: '$title ${isExpanded ? '접기' : '펼치기'}',
      child: Row(
        children: [
          Icon(CupertinoIcons.table, size: PassqlIconSize.xs, color: colors.secondaryLabel),
          const SizedBox(width: PassqlSpacing.xxs),
          Expanded(
            child: Text(
              title,
              style: PassqlTypography.subheadlineSemibold.copyWith(color: colors.label),
            ),
          ),
          Icon(
            isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
            size: PassqlIconSize.xs,
            color: colors.tertiaryLabel,
          ),
        ],
      ),
    );
  }
}
