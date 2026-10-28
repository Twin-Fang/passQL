import 'package:flutter/cupertino.dart';

import '../../../data/models/question/question_schema_table.dart';
import '../../design/design.dart';
import 'schema_table_preview.dart';

/// 실습 시트의 테이블 안내: 표마다 이름(열 타입, ...) 한 줄 > 누르면 샘플 행 표 펼침 (#727)
/// 키보드가 올라와도 편집기가 보이게 기본은 접힌 한 줄, 펼친 표는 최대 높이 안에서 스크롤
class SqlPracticeSchemaReference extends StatefulWidget {
  const SqlPracticeSchemaReference({super.key, required this.tables});

  final List<QuestionSchemaTable> tables;

  // 펼친 샘플 표 최대 높이 (키보드 + 편집기 + 입력 보조가 함께 들어갈 만큼)
  static const double _expandedMaxHeight = 220;

  @override
  State<SqlPracticeSchemaReference> createState() =>
      _SqlPracticeSchemaReferenceState();
}

class _SqlPracticeSchemaReferenceState
    extends State<SqlPracticeSchemaReference> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.tables.isEmpty) return const SizedBox.shrink();
    final colors = context.passqlColors;
    return Container(
      padding: const EdgeInsets.all(PassqlSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: colors.separator),
        borderRadius: BorderRadius.circular(PassqlRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 접힌 상태: 표 이름(열 이름 타입, ...) + 펼치기
          PassqlPressable(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            semanticLabel: _isExpanded ? '샘플 행 접기' : '샘플 행 펼치기',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.table,
                  size: PassqlIconSize.sm,
                  color: colors.secondaryLabel,
                ),
                const SizedBox(width: PassqlSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final table in widget.tables)
                        _TableSignature(table: table),
                    ],
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xs),
                Text(
                  _isExpanded ? '접기' : '샘플 보기',
                  style: PassqlTypography.footnoteSemibold.copyWith(
                    color: colors.accentText,
                  ),
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: PassqlSpacing.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: SqlPracticeSchemaReference._expandedMaxHeight,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (index, table) in widget.tables.indexed) ...[
                      if (index > 0) const SizedBox(height: PassqlSpacing.sm),
                      SchemaTablePreview(table: table),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 표 1개 한 줄: T1(COL1 INT, COL2 VARCHAR) — 이름은 진하게, 타입은 흐리게
class _TableSignature extends StatelessWidget {
  const _TableSignature({required this.table});

  final QuestionSchemaTable table;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final nameStyle = PassqlTypography.codeEmphasis.copyWith(
      color: colors.label,
    );
    final typeStyle = PassqlTypography.codeCompact.copyWith(
      color: colors.secondaryLabel,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: table.tableName, style: nameStyle),
          TextSpan(text: '(', style: typeStyle),
          for (final (index, column) in table.columns.indexed) ...[
            if (index > 0) TextSpan(text: ', ', style: typeStyle),
            TextSpan(
              text: column.name,
              style: PassqlTypography.codeCompact.copyWith(color: colors.label),
            ),
            if (column.type.isNotEmpty)
              TextSpan(text: ' ${column.type}', style: typeStyle),
          ],
          TextSpan(text: ')', style: typeStyle),
        ],
      ),
    );
  }
}
