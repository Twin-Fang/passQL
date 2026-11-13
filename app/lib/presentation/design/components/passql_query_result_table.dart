import 'package:flutter/cupertino.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_badge.dart';
import 'passql_button.dart';
import 'passql_card.dart';
import 'passql_code_block.dart';
import 'passql_pressable.dart';
import 'passql_reveal.dart';

/// 결과 표 한 행: 이름(영역·문제) + 정답 여부 + 누르면 할 일
class PassqlQueryResultRow {
  const PassqlQueryResultRow({
    required this.label,
    required this.isCorrect,
    this.onTap,
  });

  final String label;
  final bool isCorrect;

  /// 행을 누르면 (문제 다시 풀기·해설). null 이면 누를 수 없음
  final VoidCallback? onTap;
}

/// 푼 문제를 SQL 실행 결과처럼 보이는 카드 (#999)
/// 코드 블록(SELECT) > 결과 표(이름 | 정답·오답 배지 | 오답만 `다시 ›`, 행 차례로 등장) > `N rows selected · 정답 M`
/// 행이 [collapsedRowLimit] 보다 많으면 앞 행만 보이고 `N행 더 보기`로 펼침
class PassqlQueryResultTable extends StatefulWidget {
  const PassqlQueryResultTable({
    super.key,
    required this.query,
    required this.rows,
    this.labelColumnTitle = '영역',
    this.collapsedRowLimit,
  });

  /// 표 위에 보이는 SQL (키워드 강조색, 문자열 정답색)
  final String query;
  final List<PassqlQueryResultRow> rows;

  /// 첫 열 머리 (영역·문제)
  final String labelColumnTitle;

  /// 접힌 상태에서 보일 행 수 (null 이면 접지 않음)
  final int? collapsedRowLimit;

  @override
  State<PassqlQueryResultTable> createState() => _PassqlQueryResultTableState();
}

class _PassqlQueryResultTableState extends State<PassqlQueryResultTable> {
  // 결과 열 폭 (정답·오답 배지 + 아이콘이 들어가는 만큼)
  static const double _resultColumnWidth = 72;
  // 다시 열 폭 (`다시 ›` 한 덩어리)
  static const double _retryColumnWidth = 52;

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final rows = widget.rows;
    final rowLimit = widget.collapsedRowLimit;
    final isFoldable = rowLimit != null && rows.length > rowLimit;
    final visibleRows = isFoldable && !_isExpanded
        ? rows.take(rowLimit).toList()
        : rows;
    final correctCount = rows.where((row) => row.isCorrect).length;
    final separator = Container(height: PassqlSize.hairline, color: colors.separator);
    return PassqlCard(
      isCardTapExposedToScreenReader: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PassqlCodeBlock(
            code: widget.query,
            isSelectable: false,
            highlightedKeywords: PassqlCodeBlock.sqlKeywords,
            shouldColorStringLiterals: true,
          ),
          const SizedBox(height: PassqlSpacing.xs),
          // 머리 행 (스크린리더는 행마다 이름·결과를 읽으므로 숨김)
          ExcludeSemantics(
            child: _cells(
              label: Text(
                widget.labelColumnTitle,
                style: PassqlTypography.captionSemibold.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
              result: Text(
                '결과',
                style: PassqlTypography.captionSemibold.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
              verticalPadding: PassqlSpacing.xs,
            ),
          ),
          separator,
          for (var rowIndex = 0; rowIndex < visibleRows.length; rowIndex++) ...[
            if (rowIndex > 0) separator,
            // 결과가 한 행씩 출력되는 느낌: 화면 전환 뒤 차례로 등장
            PassqlReveal(
              index: rowIndex + 1,
              delay: PassqlMotion.afterRouteTransitionDelay,
              child: _resultRow(visibleRows[rowIndex]),
            ),
          ],
          if (isFoldable) ...[
            separator,
            PassqlButton(
              label: _isExpanded ? '접기' : '${rows.length - rowLimit}행 더 보기',
              variant: PassqlButtonVariant.plain,
              size: PassqlButtonSize.small,
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
            ),
          ],
          const SizedBox(height: PassqlSpacing.xs),
          Text(
            '${rows.length} ${rows.length == 1 ? 'row' : 'rows'} selected | 정답 $correctCount',
            style: PassqlTypography.codeCompact.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  /// 결과 한 행: 이름 | 배지 | 오답만 `다시 ›` (행 전체 누름)
  Widget _resultRow(PassqlQueryResultRow row) {
    final colors = context.passqlColors;
    final cells = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: PassqlSize.rowMin),
      child: _cells(
        label: Text(
          row.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: PassqlTypography.subheadline.copyWith(color: colors.label),
        ),
        result: PassqlBadge(
          text: row.isCorrect ? '정답' : '오답',
          kind: row.isCorrect
              ? PassqlBadgeKind.success
              : PassqlBadgeKind.important,
          icon: row.isCorrect
              ? CupertinoIcons.checkmark_alt
              : CupertinoIcons.xmark,
        ),
        retry: row.isCorrect
            ? null
            : Text(
                '다시 ›',
                style: PassqlTypography.footnoteSemibold.copyWith(
                  color: colors.accentText,
                ),
              ),
        verticalPadding: PassqlSpacing.xs,
      ),
    );
    final onTap = row.onTap;
    if (onTap == null) return cells;
    return PassqlPressable(
      onTap: onTap,
      semanticLabel:
          '${row.label}, ${row.isCorrect ? '정답, 문제 보기' : '오답, 다시 풀기'}',
      child: cells,
    );
  }

  /// 세 칸 배치: 이름(남는 폭) | 결과(고정) | 다시(고정, 오른쪽 정렬)
  Widget _cells({
    required Widget label,
    required Widget result,
    Widget? retry,
    required double verticalPadding,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        children: [
          Expanded(child: label),
          SizedBox(
            width: _resultColumnWidth,
            child: Align(alignment: Alignment.centerLeft, child: result),
          ),
          SizedBox(
            width: _retryColumnWidth,
            child: Align(alignment: Alignment.centerRight, child: retry),
          ),
        ],
      ),
    );
  }
}
