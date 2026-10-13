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
    final c = context.pq;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: number,
            style: PqType.title1.copyWith(color: c.label),
          ),
          TextSpan(
            text: ' $unit',
            style: PqType.subheadline.copyWith(color: c.secondaryLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: PqCard(
            title: '푼 문제',
            child: _value(context, '$solvedCount', '개'),
          ),
        ),
        const SizedBox(width: PqSpace.sm),
        Expanded(
          child: PqCard(
            title: '정답률',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _value(context, '${(correctRate * 100).round()}', '%'),
                const SizedBox(height: PqSpace.xs),
                PqProgressBar(value: correctRate),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
