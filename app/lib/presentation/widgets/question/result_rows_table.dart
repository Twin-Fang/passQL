import 'dart:convert';

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
class ResultRowsTable extends StatelessWidget {
  /// 열 이름이 유일한 Map 행(선택지 JSON)용.
  ResultRowsTable({super.key, required List<Map<String, dynamic>> rows})
    : columns = rows.isEmpty ? const [] : rows.first.keys.toList(),
      _rows = [
        for (final row in rows)
          [for (final column in rows.first.keys) row[column]],
      ];

  /// 열 목록과 위치 기준 행(SQL 실행 결과용). 같은 이름의 열이 있어도 값이 사라지지 않는다.
  const ResultRowsTable.positional({
    super.key,
    required this.columns,
    required List<List<Object?>> rows,
  }) : _rows = rows;

  final List<String> columns;
  final List<List<Object?>> _rows;

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
      color: colors.tertiaryLabel,
    );

    Widget buildCell(String text, TextStyle style) => Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.sm,
        vertical: PassqlSpacing.xs,
      ),
      child: Text(text, style: style),
    );

    // 값 칸: NULL > 흐린 NULL 문구, 그 외 > 글자 종류별 글꼴
    Widget buildValueCell(Object? value) => value == null
        ? buildCell(sqlNullCellLabel, nullCellStyle)
        : buildCell(
            '$value',
            toTableCellTextStyle('$value', color: colors.label),
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
        // 열이 적어 표가 카드보다 좁으면 오른쪽이 비어 보이므로, 최소 폭을 카드 폭에 맞춰 남는 폭을 열에 나눠 준다.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                border: TableBorder(
                  horizontalInside: BorderSide(color: colors.separator),
                ),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: colors.fill),
                    children: [
                      for (final column in columns)
                        buildCell(column, headerStyle),
                    ],
                  ),
                  for (final row in _rows)
                    TableRow(
                      children: [
                        // 모자란 칸은 NULL 이 아니라 빈칸
                        for (var i = 0; i < columns.length; i++)
                          buildValueCell(i < row.length ? row[i] : ''),
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
}
