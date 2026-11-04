import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../flows/random_practice_flow.dart';
import '../../providers/plan_providers.dart';
import '../pro/pro_access_feedback.dart';
import '../pro/pro_offer_sheet.dart';

/// 홈 오늘의 세트 구간 안 랜덤 풀기 행: 탭 > 랜덤 풀기 풀이, 무료(결제 켜짐)면 오른쪽에 오늘 랜덤 n / 10
/// 무료 한도 소진: 부제 > 다시 열리는 때, 화살표 없음, 탭 > 프로 안내 시트 (§4-4 11번째 문제)
class RandomPracticeRow extends ConsumerWidget {
  const RandomPracticeRow({super.key});

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
    return PassqlListRow(
      title: RandomPracticeFlow.displayName,
      subtitle: isDailyLimitReached
          ? freeDailyLimitResetNotice
          : RandomPracticeFlow.summary,
      leading: PassqlIconTile(
        icon: CupertinoIcons.shuffle,
        color: colors.accent,
      ),
      trailing: hasDailyUsage
          ? Text(
              '오늘 랜덤 ${knownPlan.todayRandomSolvedCount} / '
              '${knownPlan.effectiveTodayFreeLimit}',
              style: PassqlTypography.footnoteSemibold.copyWith(
                color: colors.secondaryLabel,
              ),
            )
          : null,
      hasChevron: !isDailyLimitReached,
      hasHorizontalPadding: false,
      onTap: () => isDailyLimitReached
          ? _openAfterUsageSync(context, ref)
          : context.push(AppRoutes.randomPractice),
    );
  }

  /// 한도 소진으로 보일 때 탭: 등급 다시 받기(날짜 변경·구매 반영) > 여전히 한도면 시트, 아니면 풀이 진입
  /// 시트에서 광고 보너스·구매로 한도가 풀렸으면 이어서 풀이 진입 (#808)
  Future<void> _openAfterUsageSync(BuildContext context, WidgetRef ref) async {
    await ref.read(planProvider.notifier).refresh();
    if (!context.mounted) return;
    final latestPlan = ref.read(knownPlanProvider);
    final isStillLimited =
        ref.read(shouldShowProUiProvider) &&
        latestPlan?.isDailyFreeLimitReached == true;
    if (isStillLimited) {
      final sheetOutcome = await showProOfferSheet(
        context,
        ref,
        reason: freeDailyLimitSheetReason,
        isDailyLimitEntry: true,
      );
      if (!context.mounted ||
          sheetOutcome == ProOfferSheetOutcome.dismissed) {
        return;
      }
    }
    context.push(AppRoutes.randomPractice);
  }
}
