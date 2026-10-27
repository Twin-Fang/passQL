import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/design.dart';

/// SQL NULL 셀 표시 문구 (스키마 표, 실행 결과, 결과형 보기 공통)
const String sqlNullCellLabel = 'NULL';

/// 한글 음절 포함 여부 판별
final RegExp _hangulRe = RegExp(r'[\uAC00-\uD7A3]');

/// 표 칸 글자 스타일: 한글이 섞이면 본문 글꼴(고정폭 공백이 넓어 보임 방지, #554), 아니면 코드 글꼴
TextStyle toTableCellTextStyle(String text, {required Color color}) =>
    _hangulRe.hasMatch(text)
    ? PassqlTypography.footnote.copyWith(color: color)
    : PassqlTypography.codeCompact.copyWith(color: color);

/// 선택지 본문이 결과 행 JSON 배열(`[{"COL": 값, ...}]`)이면 행 목록을, 아니면 null 을 돌려준다.
/// 웹(ResultMatchTable)과 같은 판별 기준을 쓴다.
List<Map<String, dynamic>>? parseResultRows(String body) {
  final text = body.trim();
  if (!text.startsWith('[')) return null;
  try {
    final decoded = jsonDecode(text);
    if (decoded is! List) return null;
    if (decoded.any((row) => row is! Map)) return null;
    return [for (final row in decoded) Map<String, dynamic>.from(row as Map)];
  } catch (_) {
    return null;
  }
}

/// 실행 결과형 선택지 표. 열이 많아도 잘리지 않게 가로로 스크롤한다.
/// shouldWrapCells: 화면 폭 안에서 칸 글을 단어 단위로 줄바꿈 (개념 설명 표), 단어 폭 합이 카드보다 넓을 때만 가로 스크롤
class ResultRowsTable extends StatelessWidget {
  /// 열 이름이 유일한 Map 행(선택지 JSON)용.
  ResultRowsTable({
    super.key,
    required List<Map<String, dynamic>> rows,
    this.shouldWrapCells = false,
  }) : columns = rows.isEmpty ? const [] : rows.first.keys.toList(),
       _rows = [
         for (final row in rows)
           [for (final column in rows.first.keys) row[column]],
       ];

  /// 열 목록과 위치 기준 행(SQL 실행 결과용). 같은 이름의 열이 있어도 값이 사라지지 않는다.
  const ResultRowsTable.positional({
    super.key,
    required this.columns,
    required List<List<Object?>> rows,
    this.shouldWrapCells = false,
  }) : _rows = rows;

  final List<String> columns;
  final List<List<Object?>> _rows;
  final bool shouldWrapCells;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    // 열도 행도 없는 결과: 정당한 보기 하나로 보이게 다른 결과 표와 같은 틀 안에 표시
    if (columns.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: PassqlSpacing.sm,
          vertical: PassqlSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colors.card,
          border: Border.all(color: colors.separator),
          borderRadius: const BorderRadius.all(
            Radius.circular(PassqlRadius.sm),
          ),
        ),
        child: Text(
          '결과 없음 · 0행',
          textAlign: TextAlign.center,
          style: PassqlTypography.subheadline.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
      );
    }
    final headerStyle = PassqlTypography.captionSemibold.copyWith(
      color: colors.secondaryLabel,
    );
    // NULL 은 흐린 색 문구로 빈 문자열('')과 구분
    final nullCellStyle = PassqlTypography.codeCompact.copyWith(
      color: colors.secondaryLabel,
    );

    // 값 칸: NULL > 흐린 NULL 문구, 그 외 > 글자 종류별 글꼴
    _TableCellContent toValueCellContent(Object? value) => value == null
        ? (text: sqlNullCellLabel, style: nullCellStyle)
        : (
            text: '$value',
            style: toTableCellTextStyle('$value', color: colors.label),
          );

    // 머리 줄 + 값 줄 (모자란 칸은 NULL 이 아니라 빈칸)
    final cellRows = <List<_TableCellContent>>[
      [for (final column in columns) (text: column, style: headerStyle)],
      for (final row in _rows)
        [
          for (var i = 0; i < columns.length; i++)
            toValueCellContent(i < row.length ? row[i] : ''),
        ],
    ];

    // 줄바꿈 표는 단어 중간에서 줄이 바뀌지 않게
    Widget buildCell(_TableCellContent content) => Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cellHorizontalPaddingPixels,
        vertical: PassqlSpacing.xs,
      ),
      child: shouldWrapCells
          ? PassqlKeepAllText(content.text, style: content.style)
          : Text(content.text, style: content.style),
    );

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(PassqlRadius.sm)),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          border: Border.all(color: colors.separator),
          borderRadius: const BorderRadius.all(
            Radius.circular(PassqlRadius.sm),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final table = Table(
              // 줄바꿈 표: 열 폭을 직접 계산 (_toWrappedColumnWidths)
              columnWidths: shouldWrapCells
                  ? _toWrappedColumnWidths(
                      cellRows,
                      availableWidth: constraints.maxWidth,
                      textScaler: MediaQuery.textScalerOf(context),
                    )
                  : null,
              defaultColumnWidth: const IntrinsicColumnWidth(),
              border: TableBorder(
                horizontalInside: BorderSide(color: colors.separator),
              ),
              children: [
                for (final (index, cells) in cellRows.indexed)
                  TableRow(
                    decoration: index == 0
                        ? BoxDecoration(color: colors.fill)
                        : null,
                    children: [for (final cell in cells) buildCell(cell)],
                  ),
              ],
            );
            return PassqlHorizontalScrollView(
              child: shouldWrapCells
                  ? table
                  // 열이 적어 표가 카드보다 좁으면 오른쪽이 비어 보이므로, 최소 폭을 카드 폭에 맞춰 남는 폭을 열에 나눠 준다.
                  : ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: table,
                    ),
            );
          },
        ),
      ),
    );
  }
}

/// 표 칸 1개: 글자와 스타일
typedef _TableCellContent = ({String text, TextStyle style});

// 칸 좌우 여백
const double _cellHorizontalPaddingPixels = PassqlSpacing.sm;
// 단어 구분 (칸 글 > 단어, 단어 중간 줄바꿈 없음)
final RegExp _whitespaceRe = RegExp(r'\s+');

/// 줄바꿈 표 열 폭: 열마다 가장 긴 단어 폭은 보장 > 남는 폭을 더 필요한 열에 고르게 (물 채우기)
/// 단어 폭 합이 카드보다 넓으면 단어 폭 그대로 (표가 넓어져 가로 스크롤), 모두 한 줄에 들어가면 남는 폭을 열마다 똑같이 더함
Map<int, TableColumnWidth> _toWrappedColumnWidths(
  List<List<_TableCellContent>> cellRows, {
  required double availableWidth,
  required TextScaler textScaler,
}) {
  final columnCount = cellRows.first.length;
  double measureWidth(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout();
    final width =
        painter.width.ceilToDouble() + _cellHorizontalPaddingPixels * 2;
    painter.dispose();
    return width;
  }

  // 열별 한 줄 폭, 가장 긴 단어 폭 (칸 여백 포함)
  final oneLineWidths = List<double>.filled(columnCount, 0);
  final longestWordWidths = List<double>.filled(columnCount, 0);
  for (final cells in cellRows) {
    for (final (column, cell) in cells.indexed) {
      oneLineWidths[column] = math.max(
        oneLineWidths[column],
        measureWidth(cell.text, cell.style),
      );
      for (final word in cell.text.split(_whitespaceRe)) {
        longestWordWidths[column] = math.max(
          longestWordWidths[column],
          measureWidth(word, cell.style),
        );
      }
    }
  }

  // 단어 폭 보장 > 남는 폭을 모자란 열에 같은 몫씩 (덜 필요한 열부터 확정)
  final widths = [...longestWordWidths];
  var remainingWidth =
      availableWidth - widths.fold<double>(0, (sum, width) => sum + width);
  final openColumns = {
    for (var column = 0; column < columnCount; column++)
      if (oneLineWidths[column] > widths[column]) column,
  };
  while (remainingWidth > 0 && openColumns.isNotEmpty) {
    final share = remainingWidth / openColumns.length;
    final satisfiedColumns = [
      for (final column in openColumns)
        if (oneLineWidths[column] - widths[column] <= share) column,
    ];
    if (satisfiedColumns.isEmpty) {
      for (final column in openColumns) {
        widths[column] += share;
      }
      remainingWidth = 0;
      break;
    }
    for (final column in satisfiedColumns) {
      remainingWidth -= oneLineWidths[column] - widths[column];
      widths[column] = oneLineWidths[column];
      openColumns.remove(column);
    }
  }
  final extraWidthPerColumn = math.max(0.0, remainingWidth) / columnCount;
  return {
    for (final (column, width) in widths.indexed)
      column: FixedColumnWidth(width + extraWidthPerColumn),
  };
}
