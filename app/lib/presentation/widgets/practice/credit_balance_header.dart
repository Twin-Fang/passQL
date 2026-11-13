import 'package:flutter/widgets.dart';

import '../../design/design.dart';
import 'credit_gauge.dart';

/// 크레딧 잔액 머리 (#971): 아이콘 + 큰 숫자 / 오늘 한도 > 게이지(보너스 구간은 초록)
/// 크레딧 시트와 프로필 오늘 크레딧이 같은 모양을 씀
class CreditBalanceHeader extends StatelessWidget {
  const CreditBalanceHeader({
    super.key,
    required this.remainingCount,
    required this.baseLimit,
    required this.totalLimit,
  });

  final int remainingCount;
  final int baseLimit;
  final int totalLimit;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final bonusCount = totalLimit - baseLimit;
    return Semantics(
      label: bonusCount > 0
          ? '크레딧 $remainingCount개 남음, 오늘 $totalLimit개 중, 보너스 $bonusCount개 포함'
          : '크레딧 $remainingCount개 남음, 오늘 $totalLimit개 중',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const PassqlCreditIcon(size: PassqlIconSize.xxl),
              const SizedBox(width: PassqlSpacing.xs),
              Expanded(
                // 남은 크레딧은 0에서 차오름, 값이 바뀌면 이전 값에서 이어짐 (#1041)
                child: PassqlCountUp(
                  value: remainingCount,
                  builder: (context, displayedCount) => Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$displayedCount',
                          style: PassqlTypography.largeTitle.copyWith(
                            color: colors.accentText,
                            fontFeatures: PassqlTypography.tabular,
                          ),
                        ),
                        TextSpan(
                          text: ' / $totalLimit',
                          style: PassqlTypography.subheadline.copyWith(
                            color: colors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 보너스로 늘어난 만큼 (게이지 초록 구간과 같은 색)
              if (bonusCount > 0)
                Text(
                  '보너스 +$bonusCount',
                  style: PassqlTypography.footnoteSemibold.copyWith(
                    color: colors.correctText,
                  ),
                ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.xs),
          CreditGauge(
            remainingCount: remainingCount,
            baseLimit: baseLimit,
            totalLimit: totalLimit,
          ),
        ],
      ),
    );
  }
}
