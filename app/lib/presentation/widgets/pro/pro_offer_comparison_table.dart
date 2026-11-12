import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import 'pro_comparison_rows.dart';

// 표 칸 폭 비율: 제목 : FREE : PRO
const int _labelColumnFlex = 5;
const int _freeColumnFlex = 4;
const int _proColumnFlex = 5;
// 표 한 줄 높이 (8줄이 스크롤 없이 한 화면에 들어가는 높이)
const double _rowHeight = 32;
const double _headerHeight = 30;
// 구분선 두께
const double _separatorWidth = 0.5;

/// 무료·프로 비교표 (#966): 회색 카드 안 3칸 표, PRO 칸만 흰 카드 + 강조색 머리
/// 접기 없이 모든 줄을 한 번에 보임
class ProOfferComparisonTable extends StatelessWidget {
  const ProOfferComparisonTable({super.key, required this.rows});

  final List<ProComparisonRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.sm,
        PassqlSpacing.xs,
        PassqlSpacing.xs,
        PassqlSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(PassqlRadius.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _HeaderRow(),
          for (var index = 0; index < rows.length; index++)
            _ComparisonRow(
              row: rows[index],
              isLast: index == rows.length - 1,
            ),
        ],
      ),
    );
  }
}

/// 머리 줄: 빈 칸 · FREE · PRO(강조색 바탕)
class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return SizedBox(
      height: _headerHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: _labelColumnFlex),
          Expanded(
            flex: _freeColumnFlex,
            child: Center(
              child: Text(
                'FREE',
                style: PassqlTypography.captionSemibold.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ),
          ),
          Expanded(
            flex: _proColumnFlex,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(PassqlRadius.sm),
                ),
              ),
              child: Center(
                child: Text(
                  'PRO',
                  style: PassqlTypography.captionSemibold.copyWith(
                    color: colors.onAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 표 한 줄: 제목 · 무료 값(없으면 —) · 프로 값(없으면 체크)
/// 스크린리더는 `문제, 무료 하루 10개, 프로 제한 없음` 한 문장으로 읽음
class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({required this.row, required this.isLast});

  final ProComparisonRow row;
  final bool isLast;

  String get _semanticLabel =>
      '${row.label}, 무료 ${row.free ?? '없음'}, 프로 ${row.pro ?? '포함'}';

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final free = row.free;
    final pro = row.pro;
    final separator = isLast
        ? null
        : Border(
            bottom: BorderSide(
              color: colors.separator,
              width: _separatorWidth,
            ),
          );
    return Semantics(
      label: _semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        height: _rowHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: _labelColumnFlex,
              child: DecoratedBox(
                decoration: BoxDecoration(border: separator),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _SingleLineText(
                    row.label,
                    style: PassqlTypography.footnoteSemibold.copyWith(
                      color: colors.label,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: _freeColumnFlex,
              child: DecoratedBox(
                decoration: BoxDecoration(border: separator),
                child: Center(
                  child: free == null
                      ? Icon(
                          CupertinoIcons.minus,
                          size: PassqlIconSize.xs,
                          color: colors.tertiaryLabel,
                        )
                      : _SingleLineText(
                          free,
                          style: PassqlTypography.footnote.copyWith(
                            color: colors.secondaryLabel,
                          ),
                        ),
                ),
              ),
            ),
            Expanded(
              flex: _proColumnFlex,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.card,
                  border: separator,
                  borderRadius: isLast
                      ? const BorderRadius.vertical(
                          bottom: Radius.circular(PassqlRadius.sm),
                        )
                      : null,
                ),
                child: Center(
                  child: pro == null
                      ? Icon(
                          CupertinoIcons.checkmark_circle_fill,
                          size: PassqlIconSize.md,
                          color: colors.accent,
                        )
                      : _SingleLineText(
                          pro,
                          style: PassqlTypography.footnoteSemibold.copyWith(
                            color: colors.accentText,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 한 줄 글자: 칸보다 길면 줄바꿈 대신 줄여 그림 (큰 글자·좁은 폭에서도 표 높이 유지)
class _SingleLineText extends StatelessWidget {
  const _SingleLineText(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text, maxLines: 1, style: style),
    );
  }
}
