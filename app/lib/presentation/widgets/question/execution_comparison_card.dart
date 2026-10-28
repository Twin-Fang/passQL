import 'package:flutter/cupertino.dart';

import '../../../data/models/question/execute_result.dart';
import '../../../data/models/question/execute_result_comparison.dart';
import '../../design/design.dart';
import 'result_rows_table.dart';

/// 오답 채점 뒤 내 답 <-> 정답 실행 결과 비교 카드 (#727)
/// 한 줄 요약 > 내 답 표(정답에 없는 행 빨강) > 정답 표(내 답에 없는 행 초록)
class ExecutionComparisonCard extends StatelessWidget {
  const ExecutionComparisonCard({
    super.key,
    required this.myResult,
    required this.correctResult,
    this.myChoiceLabel,
    this.correctChoiceLabel,
    this.margin = const EdgeInsets.symmetric(
      horizontal: PassqlSpacing.md,
      vertical: PassqlSpacing.xxs,
    ),
  });

  final ExecuteResult myResult;
  final ExecuteResult correctResult;

  /// 화면 순서 라벨 (A~D), 없으면 '내 답'·'정답'만
  final String? myChoiceLabel;
  final String? correctChoiceLabel;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final comparison = ExecuteResultComparison.of(
      myResult: myResult,
      correctResult: correctResult,
    );
    final hasHighlightedRow =
        comparison.myOnlyRowIndexes.isNotEmpty ||
        comparison.correctOnlyRowIndexes.isNotEmpty;
    return Padding(
      padding: margin,
      child: PassqlCard(
        title: '내 답 vs 정답 실행 결과',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 무엇이 다른지 한 줄
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.arrow_right_arrow_left,
                  size: PassqlIconSize.sm,
                  color: colors.accentText,
                ),
                const SizedBox(width: PassqlSpacing.xs),
                Expanded(
                  child: Text(
                    comparison.summary,
                    style: PassqlTypography.subheadlineSemibold.copyWith(
                      color: colors.label,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PassqlSpacing.sm),
            _ComparedResultBlock(
              title: _titleOf(myChoiceLabel, '내 답'),
              titleColor: colors.wrongText,
              executeResult: myResult,
              highlightedRowIndexes: comparison.myOnlyRowIndexes,
              highlightColor: colors.wrongTint,
            ),
            const SizedBox(height: PassqlSpacing.sm),
            _ComparedResultBlock(
              title: _titleOf(correctChoiceLabel, '정답'),
              titleColor: colors.correctText,
              executeResult: correctResult,
              highlightedRowIndexes: comparison.correctOnlyRowIndexes,
              highlightColor: colors.correctTint,
            ),
            if (hasHighlightedRow) ...[
              const SizedBox(height: PassqlSpacing.xs),
              Text(
                '색칠한 행은 상대 결과에 없는 행이에요',
                style: PassqlTypography.caption.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 보기 라벨 + 역할 ("보기 B · 내 답")
  static String _titleOf(String? choiceLabel, String role) =>
      choiceLabel == null ? role : '보기 $choiceLabel · $role';
}

/// 비교 한쪽: 제목 + (오류면 오류 코드·문구, 아니면 행 수 + 표)
class _ComparedResultBlock extends StatelessWidget {
  const _ComparedResultBlock({
    required this.title,
    required this.titleColor,
    required this.executeResult,
    required this.highlightedRowIndexes,
    required this.highlightColor,
  });

  final String title;
  final Color titleColor;
  final ExecuteResult executeResult;
  final Set<int> highlightedRowIndexes;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final hasError = executeResult.errorCode?.isNotEmpty == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          hasError
              ? '$title · 실행 오류'
              : '$title · ${executeResult.rowCount ?? executeResult.rows.length}행',
          style: PassqlTypography.footnoteSemibold.copyWith(color: titleColor),
        ),
        const SizedBox(height: PassqlSpacing.xxs),
        if (hasError)
          Text(
            '${executeResult.errorCode} ${executeResult.errorMessage ?? ''}'
                .trim(),
            style: PassqlTypography.footnote.copyWith(color: colors.wrongText),
          )
        else
          ResultRowsTable.positional(
            columns: executeResult.columns,
            rows: [
              for (final row in executeResult.rows)
                [for (final cellValue in row) cellValue],
            ],
            highlightedRowIndexes: highlightedRowIndexes,
            highlightColor: highlightColor,
          ),
      ],
    );
  }
}
