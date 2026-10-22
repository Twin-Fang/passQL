import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../flows/random_practice_flow.dart';
import '../../providers/plan_providers.dart';
import '../pro/pro_access_feedback.dart';
import '../pro/pro_offer_sheet.dart';

/// 홈 랜덤 풀기 진입 카드: 탭 > 랜덤 풀기 풀이, 무료(결제 켜짐)면 제목 줄 오른쪽에 오늘 랜덤 n / 10
/// 사용량은 제목 줄에 둠 (부제 폭 확보, 한 글자 줄바꿈 방지)
/// 무료 한도 소진: 부제 > 다시 열리는 때, 화살표 없음, 탭 > 프로 안내 시트 (§4-4 11번째 문제)
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
    final isDailyLimitReached =
        hasDailyUsage && knownPlan.isDailyFreeLimitReached;
    return PassqlCard(
      onTap: () => isDailyLimitReached
          ? _openAfterUsageSync(context, ref)
          : context.push(AppRoutes.randomPractice),
      child: Row(
        children: [
          PassqlIconTile(icon: CupertinoIcons.shuffle, color: colors.accent),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        RandomPracticeFlow.displayName,
                        style: PassqlTypography.subheadlineSemibold.copyWith(
                          color: colors.label,
                        ),
                      ),
                    ),
                    if (hasDailyUsage)
                      Text(
                        '오늘 랜덤 ${knownPlan.todayRandomSolvedCount} / '
                        '${knownPlan.dailyFreeLimit}',
                        style: PassqlTypography.footnoteSemibold.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: PassqlSpacing.hairlineGap),
                Text(
                  isDailyLimitReached
                      ? freeDailyLimitResetNotice
                      : RandomPracticeFlow.summary,
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          if (!isDailyLimitReached) ...[
            const SizedBox(width: PassqlSpacing.xs),
            Icon(
              CupertinoIcons.chevron_forward,
              size: PassqlIconSize.xs,
              color: colors.tertiaryLabel,
            ),
          ],
        ],
      ),
    );
  }

  /// 한도 소진으로 보일 때 탭: 등급 다시 받기(날짜 변경·구매 반영) > 여전히 한도면 시트, 아니면 풀이 진입
  Future<void> _openAfterUsageSync(BuildContext context, WidgetRef ref) async {
    await ref.read(planProvider.notifier).refresh();
    if (!context.mounted) return;
    final latestPlan = ref.read(knownPlanProvider);
    final isStillLimited =
        ref.read(shouldShowProUiProvider) &&
        latestPlan?.isDailyFreeLimitReached == true;
    if (isStillLimited) {
      await showProOfferSheet(context, ref, reason: freeDailyLimitSheetReason);
      return;
    }
    context.push(AppRoutes.randomPractice);
  }
}
