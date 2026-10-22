import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../flows/random_practice_flow.dart';
import '../../providers/plan_providers.dart';

/// 홈 랜덤 풀기 진입 카드: 탭 > 랜덤 풀기 풀이, 무료(결제 켜짐)면 오른쪽에 오늘 랜덤 n / 10
class RandomPracticeCard extends ConsumerWidget {
  const RandomPracticeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final knownPlan = ref.watch(knownPlanProvider);
    final hasDailyUsage =
        ref.watch(shouldShowProUiProvider) &&
        knownPlan != null &&
        knownPlan.dailyFreeLimit > 0;
    return PassqlCard(
      onTap: () => context.push(AppRoutes.randomPractice),
      child: Row(
        children: [
          PassqlIconTile(icon: CupertinoIcons.shuffle, color: colors.accent),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  RandomPracticeFlow.displayName,
                  style: PassqlTypography.subheadlineSemibold.copyWith(
                    color: colors.label,
                  ),
                ),
                const SizedBox(height: PassqlSpacing.hairlineGap),
                Text(
                  RandomPracticeFlow.summary,
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          if (hasDailyUsage) ...[
            const SizedBox(width: PassqlSpacing.xs),
            Text(
              '오늘 랜덤 ${knownPlan.todayRandomSolvedCount} / '
              '${knownPlan.dailyFreeLimit}',
              style: PassqlTypography.footnoteSemibold.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
          const SizedBox(width: PassqlSpacing.xs),
          Icon(
            CupertinoIcons.chevron_forward,
            size: PassqlIconSize.xs,
            color: colors.tertiaryLabel,
          ),
        ],
      ),
    );
  }
}
