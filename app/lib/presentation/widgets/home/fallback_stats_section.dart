import 'package:flutter/material.dart';
import '../../design/design.dart';

/// readiness 없을 때 표시하는 통계 2열 카드.
class FallbackStatsSection extends StatelessWidget {
  final int solvedCount;
  final double correctRate; // 0.0~1.0

  const FallbackStatsSection({
    super.key,
    required this.solvedCount,
    required this.correctRate,
  });

  /// 큰 숫자 + 작은 단위 한 줄.
  Widget _value(BuildContext context, String number, String unit) {
    final colors = context.passqlColors;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: number,
            style: PassqlTypography.title1.copyWith(color: colors.label),
          ),
          TextSpan(
            text: ' $unit',
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = PassqlTypography.headline.copyWith(
      color: context.passqlColors.label,
    );
    // 두 값을 나란히 (면은 홈이 감싼다, 인사말과 같은 첫 구간)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('푼 문제', style: labelStyle),
              const SizedBox(height: PassqlSpacing.sm),
              _value(context, '$solvedCount', '개'),
            ],
          ),
        ),
        const SizedBox(width: PassqlSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('정답률', style: labelStyle),
              const SizedBox(height: PassqlSpacing.sm),
              _value(context, '${(correctRate * 100).round()}', '%'),
              const SizedBox(height: PassqlSpacing.xs),
              PassqlProgressBar(value: correctRate),
            ],
          ),
        ),
      ],
    );
  }
}
