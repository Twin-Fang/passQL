import 'package:flutter/material.dart';

import '../../../data/models/question/question_schema_column.dart';
import '../../../data/models/question/question_schema_table.dart';
import '../../design/design.dart';
import 'result_rows_table.dart';

/// 테이블 1개 미리보기: 이름·샘플 행 수 > 컬럼 머리글(이름, PK·FK, 타입) + 샘플 행 표 (처음 5행 + 더 보기)
/// 열이 많거나 글자가 커도 잘리지 않게 가로 스크롤
class SchemaTablePreview extends StatefulWidget {
  const SchemaTablePreview({super.key, required this.table});

  final QuestionSchemaTable table;

  /// 처음에 보여 줄 샘플 행 수 (웹 SchemaViewer 와 같은 값)
  static const int initialSampleRowCount = 5;

  /// SQL NULL 셀 표시 문구 (실행 결과 표와 같은 표기)
  static const String nullCellLabel = sqlNullCellLabel;

  @override
  State<SchemaTablePreview> createState() => _SchemaTablePreviewState();
}

class _SchemaTablePreviewState extends State<SchemaTablePreview> {
  bool _isShowingAllRows = false;

  @override
  Widget build(BuildContext context) {
    final table = widget.table;
    final visibleRows = _isShowingAllRows
        ? table.sampleRows
        : table.sampleRows.take(SchemaTablePreview.initialSampleRowCount).toList();
    final hiddenRowCount = table.sampleRows.length - visibleRows.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TableTitle(table: table),
        const SizedBox(height: PassqlSpacing.xxs),
        _SampleRowsTable(columns: table.columns, rows: visibleRows),
        if (hiddenRowCount > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: PassqlButton(
              label: '$hiddenRowCount행 더 보기',
              variant: PassqlButtonVariant.plain,
              size: PassqlButtonSize.small,
              isFullWidth: false,
              onPressed: () => setState(() => _isShowingAllRows = true),
            ),
          ),
      ],
    );
  }
}

/// 테이블 이름 + 샘플 행 수 (없으면 '샘플 데이터 없음')
class _TableTitle extends StatelessWidget {
  const _TableTitle({required this.table});

  final QuestionSchemaTable table;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final sampleRowCount = table.sampleRows.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            table.tableName,
            style: PassqlTypography.codeEmphasis.copyWith(color: colors.label),
          ),
        ),
        const SizedBox(width: PassqlSpacing.xs),
        Text(
          sampleRowCount > 0 ? '샘플 $sampleRowCount행' : '샘플 데이터 없음',
          style: PassqlTypography.caption.copyWith(color: colors.secondaryLabel),
        ),
      ],
    );
  }
}

/// 컬럼 머리글 1줄 + 샘플 행 표 (카드보다 좁으면 카드 폭까지 늘림)
class _SampleRowsTable extends StatelessWidget {
  const _SampleRowsTable({required this.columns, required this.rows});

  final List<QuestionSchemaColumn> columns;
  final List<List<dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final nullCellStyle = PassqlTypography.codeCompact.copyWith(color: colors.secondaryLabel);

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(PassqlRadius.sm)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colors.separator),
          borderRadius: const BorderRadius.all(Radius.circular(PassqlRadius.sm)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                border: TableBorder(horizontalInside: BorderSide(color: colors.separator)),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: colors.fill),
                    children: [for (final column in columns) _ColumnHeaderCell(column: column)],
                  ),
                  for (final row in rows)
                    TableRow(
                      children: [
                        for (var columnIndex = 0; columnIndex < columns.length; columnIndex++)
                          _buildValueCell(
                            columnIndex < row.length ? row[columnIndex] : null,
                            cellColor: colors.label,
                            nullCellStyle: nullCellStyle,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 셀 값 > 글자 (null 이면 흐린 NULL)
  Widget _buildValueCell(Object? value, {required Color cellColor, required TextStyle nullCellStyle}) {
    return _TableCellPadding(
      child: value == null
          ? Text(SchemaTablePreview.nullCellLabel, style: nullCellStyle)
          : Text('$value', style: toTableCellTextStyle('$value', color: cellColor)),
    );
  }
}

/// 컬럼 머리글: 이름 + 키 표시(PK, FK) / 타입
class _ColumnHeaderCell extends StatelessWidget {
  const _ColumnHeaderCell({required this.column});

  final QuestionSchemaColumn column;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final keyLabels = [if (column.isPrimaryKey) 'PK', if (column.isForeignKey) 'FK'];
    return _TableCellPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: column.name,
              style: PassqlTypography.codeCompact.copyWith(
                color: colors.label,
                fontWeight: FontWeight.w700,
              ),
              children: [
                for (final keyLabel in keyLabels)
                  TextSpan(
                    text: ' $keyLabel',
                    style: PassqlTypography.captionSemibold.copyWith(color: colors.accentText),
                  ),
              ],
            ),
          ),
          if (column.type.isNotEmpty)
            Text(
              column.type,
              style: PassqlTypography.codeCompact.copyWith(color: colors.secondaryLabel),
            ),
        ],
      ),
    );
  }
}

/// 표 칸 안쪽 여백 (머리글·값 공통)
class _TableCellPadding extends StatelessWidget {
  const _TableCellPadding({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.sm,
        vertical: PassqlSpacing.xs,
      ),
      child: child,
    );
  }
}
