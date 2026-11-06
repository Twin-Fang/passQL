import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/utils/word_wrap.dart';
import '../../design/design.dart';
import 'table_column_fit.dart';

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

/// 결과 행 표 (결과형 선택지 JSON·SQL 실행 결과 공통): 열이 많으면 가로 스크롤, 지정 행은 배경 강조
class ResultRowsTable extends StatelessWidget {
  /// 열 이름이 유일한 Map 행(선택지 JSON)용.
  ResultRowsTable({super.key, required List<Map<String, dynamic>> rows})
    : columns = rows.isEmpty ? const [] : rows.first.keys.toList(),
      _rows = [
        for (final row in rows)
          [for (final column in rows.first.keys) row[column]],
      ],
      highlightedRowIndexes = const {},
      highlightColor = null,
      shouldWrapCellsToFit = false;

  /// 열 목록과 위치 기준 행(SQL 실행 결과용). 같은 이름의 열이 있어도 값이 사라지지 않는다.
  const ResultRowsTable.positional({
    super.key,
    required this.columns,
    required List<List<Object?>> rows,
    this.highlightedRowIndexes = const {},
    this.highlightColor,
    this.shouldWrapCellsToFit = false,
  }) : _rows = rows;

  final List<String> columns;
  final List<List<Object?>> _rows;

  /// 배경을 칠할 행 위치 (내 답 <-> 정답 비교에서 한쪽에만 있는 행, #727)
  final Set<int> highlightedRowIndexes;

  /// [highlightedRowIndexes] 행 배경색 (옅은 정답·오답 색)
  final Color? highlightColor;

  /// 넘치면 칸 안 줄바꿈으로 화면 폭에 맞춤 (개념 비교 표, #876). 낱말 폭 합도 넘치면 가로 스크롤
  final bool shouldWrapCellsToFit;

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

    // 칸 글자·스타일: 머리 줄 > 값 줄 (NULL > 흐린 NULL 문구, 그 외 > 글자 종류별 글꼴, 모자란 칸은 빈칸)
    final headerCells = [for (final column in columns) (column, headerStyle)];
    final valueCellsByRow = [
      for (final row in _rows)
        [
          for (var i = 0; i < columns.length; i++)
            _valueCellOf(i < row.length ? row[i] : '', colors, nullCellStyle),
        ],
    ];

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
        // 열이 적어 표가 카드보다 좁으면 오른쪽이 비어 보이므로, 최소 폭을 카드 폭에 맞춰 남는 폭을 열에 나눠 준다.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fittedWidths = shouldWrapCellsToFit
                ? _fittedColumnWidthsOf(
                    context,
                    [headerCells, ...valueCellsByRow],
                    constraints.maxWidth,
                  )
                : null;
            final table = _buildTable(
              colors,
              headerCells,
              valueCellsByRow,
              fittedWidths: fittedWidths,
            );
            if (fittedWidths != null) return table;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: table,
              ),
            );
          },
        ),
      ),
    );
  }

  // 칸 안 좌우 여백 (열 폭 계산에도 더함)
  static const double _cellHorizontalPadding = PassqlSpacing.sm;

  static (String, TextStyle) _valueCellOf(
    Object? value,
    PassqlColors colors,
    TextStyle nullCellStyle,
  ) => value == null
      ? (sqlNullCellLabel, nullCellStyle)
      : ('$value', toTableCellTextStyle('$value', color: colors.label));

  /// 칸 글자 > 열마다 (한 줄 폭, 가장 긴 낱말 폭) 측정 > 화면 폭 안 열 폭 (맞출 수 없거나 필요 없으면 null)
  static List<double>? _fittedColumnWidthsOf(
    BuildContext context,
    List<List<(String, TextStyle)>> cellsByRow,
    double availableWidth,
  ) {
    final textScaler = MediaQuery.textScalerOf(context);
    final columnCount = cellsByRow.first.length;
    final singleLineWidths = List<double>.filled(columnCount, 0);
    final longestWordWidths = List<double>.filled(columnCount, 0);
    for (final row in cellsByRow) {
      for (var column = 0; column < columnCount; column++) {
        final (text, style) = row[column];
        final painter = TextPainter(
          text: TextSpan(text: keepWordsTogether(text), style: style),
          textDirection: TextDirection.ltr,
          textScaler: textScaler,
        )..layout();
        const padding = _cellHorizontalPadding * 2;
        singleLineWidths[column] = math.max(
          singleLineWidths[column],
          painter.maxIntrinsicWidth.ceilToDouble() + padding,
        );
        longestWordWidths[column] = math.max(
          longestWordWidths[column],
          painter.minIntrinsicWidth.ceilToDouble() + padding,
        );
        painter.dispose();
      }
    }
    return fitColumnWidths(
      singleLineWidths: singleLineWidths,
      longestWordWidths: longestWordWidths,
      availableWidth: availableWidth,
    );
  }

  /// 표: 머리 줄(회색 바탕) + 값 줄 (지정 행 배경). 맞춘 열 폭이 있으면 그 폭에서 칸 안 줄바꿈
  Widget _buildTable(
    PassqlColors colors,
    List<(String, TextStyle)> headerCells,
    List<List<(String, TextStyle)>> valueCellsByRow, {
    required List<double>? fittedWidths,
  }) {
    final isWrapping = fittedWidths != null;
    Widget buildCell((String, TextStyle) cell) => Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cellHorizontalPadding,
        vertical: PassqlSpacing.xs,
      ),
      // 줄바꿈할 때는 한글 낱말 중간에서 끊기지 않게
      child: Text(isWrapping ? keepWordsTogether(cell.$1) : cell.$1, style: cell.$2),
    );

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      columnWidths: fittedWidths == null
          ? null
          : {
              for (final (column, width) in fittedWidths.indexed)
                column: FixedColumnWidth(width),
            },
      border: TableBorder(horizontalInside: BorderSide(color: colors.separator)),
      children: [
        TableRow(
          decoration: BoxDecoration(color: colors.fill),
          children: [for (final cell in headerCells) buildCell(cell)],
        ),
        for (final (rowIndex, row) in valueCellsByRow.indexed)
          TableRow(
            decoration:
                highlightedRowIndexes.contains(rowIndex) &&
                    highlightColor != null
                ? BoxDecoration(color: highlightColor)
                : null,
            children: [for (final cell in row) buildCell(cell)],
          ),
      ],
    );
  }
}
