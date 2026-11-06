import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 번호판 칸 모양 6가지: 풀이 중(안 푼·답함), 결과(정답·오답·안 푼)
enum MockExamNumberCellKind { unanswered, answered, correct, wrong, skipped }

/// 문항 번호 칸 1개 (풀이 번호판·결과 정오 번호판 공용): 번호 + 모양 + 표시 점 + 현재 테두리
class MockExamNumberCell extends StatelessWidget {
  const MockExamNumberCell({
    super.key,
    required this.questionNumber,
    required this.kind,
    required this.onTap,
    this.isFlagged = false,
    this.isCurrent = false,
  });

  final int questionNumber;
  final MockExamNumberCellKind kind;
  final VoidCallback onTap;
  final bool isFlagged;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final (Color background, Color foreground) = switch (kind) {
      MockExamNumberCellKind.unanswered => (colors.fill, colors.secondaryLabel),
      MockExamNumberCellKind.answered => (colors.accent, colors.onAccent),
      MockExamNumberCellKind.correct => (
        colors.correctTint,
        colors.correctText,
      ),
      MockExamNumberCellKind.wrong => (colors.wrongTint, colors.wrongText),
      MockExamNumberCellKind.skipped => (colors.fill, colors.wrongText),
    };
    return PassqlPressable(
      onTap: onTap,
      semanticLabel: _semanticLabelOf(),
      hasMinimumTouchTarget: true,
      child: Container(
        height: PassqlSize.minTouchTarget,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(PassqlRadius.sm),
          border: isCurrent
              ? Border.all(color: colors.label, width: _currentBorderWidth)
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Text(
              '$questionNumber',
              style: PassqlTypography.subheadlineSemibold.copyWith(
                fontFeatures: PassqlTypography.tabular,
                color: foreground,
              ),
            ),
            if (isFlagged)
              Positioned(
                top: -PassqlSpacing.xxs,
                right: -PassqlSpacing.xs,
                child: Icon(
                  CupertinoIcons.flag_fill,
                  size: PassqlIconSize.xxs,
                  color: colors.warningText,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 스크린리더: "12번, 답함, 표시함, 현재 문항"
  String _semanticLabelOf() {
    final kindLabel = switch (kind) {
      MockExamNumberCellKind.unanswered => '안 푼 문항',
      MockExamNumberCellKind.answered => '답함',
      MockExamNumberCellKind.correct => '정답',
      MockExamNumberCellKind.wrong => '오답',
      MockExamNumberCellKind.skipped => '안 풀어 오답',
    };
    return [
      '$questionNumber번',
      kindLabel,
      if (isFlagged) '표시함',
      if (isCurrent) '현재 문항',
    ].join(', ');
  }
}

// 현재 문항 테두리 두께 (논리 픽셀)
const double _currentBorderWidth = 2;
