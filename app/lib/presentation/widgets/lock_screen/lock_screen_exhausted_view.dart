import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../practice/credit_gauge.dart';

// 등급 응답에 값이 없을 때의 하루 기본 크레딧 (DEC-0239)
const int _fallbackDailyFreeLimit = 10;

/// 잠금화면 크레딧 소진 화면 본문: 회색 동전 > 제목 > 두 줄 설명 > 빈 게이지 > 충전 시각
/// 광고·구매 버튼은 화면 하단 바(잠금 해제 후 앱에서 열기, Play 정책)
class LockScreenExhaustedView extends ConsumerWidget {
  const LockScreenExhaustedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final knownPlan = ref.watch(knownPlanProvider);
    final dailyFreeLimit = (knownPlan?.dailyFreeLimit ?? 0) > 0
        ? knownPlan!.dailyFreeLimit
        : _fallbackDailyFreeLimit;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 다 쓴 동전: 아이콘을 회색 실루엣으로
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                colors.tertiaryLabel,
                BlendMode.srcIn,
              ),
              child: const PassqlCreditIcon(size: PassqlSize.sheetHeroCircle),
            ),
            const SizedBox(height: PassqlSpacing.md),
            Semantics(
              header: true,
              child: PassqlKeepAllText(
                '오늘 크레딧을 다 썼어요',
                textAlign: TextAlign.center,
                style: PassqlTypography.title2.copyWith(color: colors.label),
              ),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            PassqlKeepAllText(
              '광고를 보면 5문제를 더 풀 수 있어요\nPRO는 크레딧 없이 계속 풀어요',
              textAlign: TextAlign.center,
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            const SizedBox(height: PassqlSpacing.lg),
            CreditGauge(
              remainingCount: 0,
              baseLimit: dailyFreeLimit,
              totalLimit: knownPlan?.effectiveTodayFreeLimit ?? dailyFreeLimit,
            ),
            const SizedBox(height: PassqlSpacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.clock_fill,
                  size: PassqlIconSize.xs,
                  color: colors.iconSecondary,
                ),
                const SizedBox(width: PassqlSpacing.xxs),
                Text(
                  '0시에 $dailyFreeLimit개 충전',
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
