import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// OX 퀴즈 머리 (#1083): 오늘 목표 진행 막대 + 묶음 진행(n/N) + 연속 정답 콤보(2개 이상일 때)
class OxQuizProgressHeader extends StatelessWidget {
  const OxQuizProgressHeader({
    super.key,
    required this.todayAnsweredCount,
    required this.dailyGoalCount,
    required this.cardNumber,
    required this.cardCount,
    required this.comboCount,
  });

  final int todayAnsweredCount;
  final int dailyGoalCount;

  /// 지금 카드 번호 (1부터)
  final int cardNumber;
  final int cardCount;
  final int comboCount;

  // 콤보 배지를 보이는 최소 연속 정답 수
  static const int _minimumVisibleComboCount = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final goalLabel = '오늘 $todayAnsweredCount / $dailyGoalCount장';
    final goalProgress = dailyGoalCount <= 0
        ? 0.0
        : (todayAnsweredCount / dailyGoalCount).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                goalLabel,
                style: PassqlTypography.subheadlineSemibold.copyWith(
                  color: colors.label,
                  fontFeatures: PassqlTypography.tabular,
                ),
              ),
            ),
            if (comboCount >= _minimumVisibleComboCount) ...[
              PassqlBadge(
                text: '$comboCount연속 정답',
                kind: PassqlBadgeKind.warning,
                icon: CupertinoIcons.flame_fill,
              ),
              const SizedBox(width: PassqlSpacing.xs),
            ],
            Text(
              '$cardNumber / $cardCount',
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
                fontFeatures: PassqlTypography.tabular,
              ),
            ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.xs),
        PassqlProgressBar(value: goalProgress, semanticValue: goalLabel),
      ],
    );
  }
}
