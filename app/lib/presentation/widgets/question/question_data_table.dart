import 'package:flutter/material.dart';

import '../../../data/models/question/question_schema_column.dart';
import '../../design/design.dart';
import 'result_rows_table.dart';

/// 문제 데이터 표 (지문 표·스키마 표 공통, #903): 컬럼 머리글(이름 + PK·FK, 선택: 자료형) + 행 전부
/// 카드보다 좁으면 카드 폭까지 늘리고, 넓으면 가로 스크롤
class QuestionDataTable extends StatelessWidget {
  const QuestionDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.isShowingColumnTypes = false,
  });

  final List<QuestionSchemaColumn> columns;
  final List<List<Object?>> rows;

  /// 자료형 줄 표시 (SQL 연습 참고 영역만, 풀이 지문은 숨김)
  final bool isShowingColumnTypes;

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
                    children: [
                      for (final column in columns)
                        _ColumnHeaderCell(
                          column: column,
                          isShowingType: isShowingColumnTypes,
                        ),
                    ],
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
          ? Text(sqlNullCellLabel, style: nullCellStyle)
          : Text('$value', style: toTableCellTextStyle('$value', color: cellColor)),
    );
  }
}

/// 컬럼 머리글: 이름 + 키 표시(PK, FK) / (선택) 자료형
class _ColumnHeaderCell extends StatelessWidget {
  const _ColumnHeaderCell({required this.column, required this.isShowingType});

  final QuestionSchemaColumn column;
  final bool isShowingType;

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
          if (isShowingType && column.type.isNotEmpty)
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
