import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import 'concept_lesson_block.dart';

/// 행 거르기 그림 (#853): 모든 행이 보인 뒤 빠지는 행은 흐려지며 줄이 그어지고, 묶이는 행은 같은 색 이름표가 붙음
/// 끝에 남은 행 수·묶음 수 한 줄
class ConceptRowFilterDiagram extends StatelessWidget {
  const ConceptRowFilterDiagram({super.key, required this.filter});

  final ConceptRowFilterBlock filter;

  // 전체 연출 시간과 구간 (앞 구간은 그대로 보여 주고, 뒤 구간에서 빠지기·묶기)
  static const Duration _duration = Duration(milliseconds: 1600);
  static const double _removeStart = 0.25;
  static const double _groupStart = 0.45;
  static const double _summaryStart = 0.85;
  // 빠진 행의 최종 불투명도 (지워진 줄도 읽을 수 있게)
  static const double _removedOpacity = 0.35;

  @override
  Widget build(BuildContext context) {
    final rows = filter.rows;
    final groupNames = filter.groupNames;
    final keptCount = rows.where((row) => !row.isRemoved).length;
    return Semantics(
      label: '행 ${rows.length}개 중 $keptCount개 남음',
      child: PassqlScrollProgress(
        duration: _duration,
        builder: (context, progress) {
          final colors = context.passqlColors;
          final removeT = _segment(progress, _removeStart, _groupStart);
          final groupT = _segment(progress, _groupStart, _summaryStart);
          final summaryT = _segment(progress, _summaryStart, 1);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, row) in rows.indexed) ...[
                if (index > 0) const SizedBox(height: PassqlSpacing.xxs),
                _RowLine(
                  row: row,
                  removeT: removeT,
                  groupT: row.groupName != null ? groupT : 0,
                  groupColor: row.groupName == null
                      ? null
                      : _groupColorOf(
                          colors,
                          groupNames.indexOf(row.groupName!),
                        ),
                ),
              ],
              const SizedBox(height: PassqlSpacing.sm),
              Opacity(
                opacity: summaryT,
                child: Text(
                  groupNames.isEmpty
                      ? '${rows.length}행 중 $keptCount행이 남아요'
                      : '$keptCount행이 ${groupNames.length}개 묶음이 돼요',
                  style: PassqlTypography.subheadlineSemibold.copyWith(
                    color: colors.accentText,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 전체 진행 값 > 한 구간 안의 진행 (0~1)
  static double _segment(double progress, double start, double end) =>
      ((progress - start) / (end - start)).clamp(0.0, 1.0);

  /// 묶음 순서 > 색 (의미색을 돌려 씀, 색만으로 구분하지 않게 이름표 글자도 함께)
  static Color _groupColorOf(PassqlColors colors, int groupIndex) {
    final palette = [
      colors.accent,
      colors.correct,
      colors.warning,
      colors.wrong,
    ];
    return palette[groupIndex % palette.length];
  }
}

/// 행 한 줄: 행 글 + (빠짐) 줄 긋기·흐림 + (묶음) 색 이름표
class _RowLine extends StatelessWidget {
  const _RowLine({
    required this.row,
    required this.removeT,
    required this.groupT,
    required this.groupColor,
  });

  final ConceptRowOutcome row;

  /// 빠지기 구간 진행 (모든 행 공통, 빠지는 행만 흐려짐)
  final double removeT;
  final double groupT;
  final Color? groupColor;

  // 이름표 왼쪽 띠 두께
  static const double _groupBarWidth = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final rowRemoveT = row.isRemoved ? removeT : 0.0;
    final isStruck = rowRemoveT > 0.5;
    final groupName = row.groupName;
    return Opacity(
      opacity: 1 - (1 - ConceptRowFilterDiagram._removedOpacity) * rowRemoveT,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PassqlSpacing.sm,
          vertical: PassqlSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(PassqlRadius.sm),
          border: groupColor == null
              ? null
              : Border(
                  left: BorderSide(
                    color: Color.lerp(colors.background, groupColor, groupT)!,
                    width: _groupBarWidth,
                  ),
                ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                row.row,
                style: PassqlTypography.codeCompact.copyWith(
                  color: colors.label,
                  decoration: isStruck ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (row.isRemoved && rowRemoveT > 0)
              Icon(
                CupertinoIcons.minus_circle_fill,
                size: PassqlIconSize.sm,
                color: colors.wrong,
              )
            else if (groupName != null && groupT > 0)
              Opacity(
                opacity: groupT,
                child: Text(
                  groupName,
                  style: PassqlTypography.captionSemibold.copyWith(
                    color: colors.label,
                  ),
                ),
              )
            else if (row.isKept && removeT > 0)
              Opacity(
                opacity: removeT,
                child: Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  size: PassqlIconSize.sm,
                  color: colors.correct,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
