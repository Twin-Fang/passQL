import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import '../../providers/mock_exam_countdown.dart';

/// 풀이 화면 남은 시간: 시계 아이콘 + mm:ss, 10분 이하 주황·5분 이하 빨강
/// 스크린리더는 분 단위 한 문장 (초마다 읽지 않게)
class MockExamTimerChip extends StatelessWidget {
  const MockExamTimerChip({super.key, required this.remainingSeconds});

  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final timeLevel = mockExamTimeLevelOf(remainingSeconds);
    final Color textColor = switch (timeLevel) {
      MockExamTimeLevel.relaxed => colors.label,
      MockExamTimeLevel.caution => colors.warningText,
      MockExamTimeLevel.urgent => colors.wrongText,
    };
    final Color backgroundColor = switch (timeLevel) {
      MockExamTimeLevel.relaxed => colors.fill,
      MockExamTimeLevel.caution => colors.warning.withValues(alpha: _tintAlpha),
      MockExamTimeLevel.urgent => colors.wrongTint,
    };
    final remainingMinutes = (remainingSeconds / 60).ceil();
    return Semantics(
      label: '남은 시간 $remainingMinutes분',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PassqlSpacing.sm,
          vertical: PassqlSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(PassqlRadius.capsule),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.timer,
              size: PassqlIconSize.xs,
              color: textColor,
            ),
            const SizedBox(width: PassqlSpacing.xxs),
            Text(
              formatMockExamRemaining(remainingSeconds),
              style: PassqlTypography.subheadlineSemibold.copyWith(
                fontFeatures: PassqlTypography.tabular,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 주의 단계 바탕 투명도 (warning 은 진한 채움색이라 옅게)
const double _tintAlpha = 0.16;
