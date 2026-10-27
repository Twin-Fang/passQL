import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 온보딩 SQL 카드: 실행한 SQL + 성공 표시 + (선택) 결과 표
/// 실제 풀이 화면과 같은 코드 블록·결과 마크로 그려, 첫 문제에 들어갔을 때 낯설지 않게 한다.
class OnboardingSqlCard extends StatelessWidget {
  const OnboardingSqlCard({
    super.key,
    required this.code,
    required this.statusLabel,
    this.columns,
    this.rows,
    this.highlightedRowIndex,
  });

  final String code;

  /// 결과 마크 옆 문구 (예: '1행 추가됨')
  final String statusLabel;

  /// 결과 표 머리. null 이면 표 없음
  final List<String>? columns;
  final List<List<String>>? rows;

  /// 방금 들어온 행처럼 강조할 행 번호 (등장 연출 포함)
  final int? highlightedRowIndex;

  @override
  Widget build(BuildContext context) {
    final columns = this.columns;
    final rows = this.rows;
    return PassqlCard(
      isCardTapExposedToScreenReader: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          PassqlCodeBlock(code: code, isSelectable: false),
          const SizedBox(height: PassqlSpacing.sm),
          PassqlResultMark(isCorrect: true, label: statusLabel),
          if (columns != null && rows != null) ...[
            const SizedBox(height: PassqlSpacing.sm),
            _ResultTable(
              columns: columns,
              rows: rows,
              highlightedRowIndex: highlightedRowIndex,
            ),
          ],
        ],
      ),
    );
  }
}

/// 결과 표: 머리 행 + 데이터 행, 강조 행은 강조색 옅은 배경
class _ResultTable extends StatelessWidget {
  const _ResultTable({
    required this.columns,
    required this.rows,
    required this.highlightedRowIndex,
  });

  final List<String> columns;
  final List<List<String>> rows;
  final int? highlightedRowIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(PassqlRadius.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.separator,
            width: PassqlSize.hairline,
          ),
          borderRadius: BorderRadius.circular(PassqlRadius.sm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TableRow(
              cells: columns,
              background: colors.fill,
              textStyle: PassqlTypography.footnoteSemibold.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            for (var rowIndex = 0; rowIndex < rows.length; rowIndex++)
              rowIndex == highlightedRowIndex
                  // 새 행이 들어오는 느낌: 표가 보인 뒤 한 박자 늦게 등장
                  ? PassqlReveal(
                      index: rowIndex + 1,
                      child: _TableRow(
                        cells: rows[rowIndex],
                        background: colors.accentTint,
                        textStyle: PassqlTypography.codeEmphasis.copyWith(
                          color: colors.label,
                        ),
                        firstCellColor: colors.accentText,
                      ),
                    )
                  : _TableRow(
                      cells: rows[rowIndex],
                      textStyle: PassqlTypography.codeCompact.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.cells,
    required this.textStyle,
    this.background,
    this.firstCellColor,
  });

  final List<String> cells;
  final TextStyle textStyle;
  final Color? background;
  final Color? firstCellColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.sm,
        vertical: PassqlSpacing.xs,
      ),
      child: Row(
        children: [
          for (var cellIndex = 0; cellIndex < cells.length; cellIndex++)
            Expanded(
              child: Text(
                cells[cellIndex],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: cellIndex == 0 && firstCellColor != null
                    ? textStyle.copyWith(color: firstCellColor)
                    : textStyle,
              ),
            ),
        ],
      ),
    );
  }
}
