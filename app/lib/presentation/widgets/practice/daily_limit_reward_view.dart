import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../ads/rewarded_ad_bonus_button.dart';
import '../pro/pro_offer_sheet.dart';

// 등급 응답에 값이 없을 때의 수치 (DEC-0239: 기본 한도 10, 보너스 1회 5문제)
const int _fallbackDailyFreeLimit = 10;
const int _fallbackBonusQuestionCount = 5;

/// 무료 하루 한도 오류인지 (이 화면이 본문·시트로 맡음 > 자동 이용권 시트 대상 아님)
bool isFreeDailyLimitError(Object error) =>
    error.asAppException.code == ErrorCode.freeDailyLimitReached;

/// 무료 하루 한도 화면 (A안, #963): 제목 > 광고 보고 더 풀기(주 버튼) > 오늘의 세트 보너스 > 이용권 한 줄
/// 막다른 길 없음: 광고·세트·이용권 모두 갈 곳이 있고, 광고 보상·구매로 풀리면 [onUnlocked]
class DailyLimitRewardView extends ConsumerWidget {
  const DailyLimitRewardView({
    super.key,
    required this.onUnlocked,
    this.onOpenDailySet,
    this.onAdBonusAttemptStarted,
  });

  /// 광고 보상 연출을 닫았거나 이용권을 샀을 때 (같은 문제 다시 받기, 시트면 닫기)
  final VoidCallback onUnlocked;

  /// 오늘의 세트로 가기 (없으면 세트 화면을 쌓고 돌아오면 [onUnlocked])
  final VoidCallback? onOpenDailySet;

  /// 광고 시청·확인 시작 (시트를 닫아도 결과를 기다릴 때)
  final void Function(Future<bool> isBonusGranted)? onAdBonusAttemptStarted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final knownPlan = ref.watch(knownPlanProvider);
    final dailyBonus = knownPlan?.dailyBonus;
    final dailyFreeLimit = (knownPlan?.dailyFreeLimit ?? 0) > 0
        ? knownPlan!.dailyFreeLimit
        : _fallbackDailyFreeLimit;
    final bonusQuestionCount = (dailyBonus?.bonusQuestionCount ?? 0) > 0
        ? dailyBonus!.bonusQuestionCount
        : _fallbackBonusQuestionCount;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          PassqlSpacing.lg,
          PassqlSpacing.md,
          PassqlSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                '오늘 무료 문제를\n다 풀었어요',
                style: PassqlTypography.title2.copyWith(color: colors.label),
              ),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            PassqlKeepAllText(
              '아래 방법으로 더 풀 수 있어요. 내일 0시에는 $dailyFreeLimit문제가 새로 열려요.',
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            const SizedBox(height: PassqlSpacing.md),
            _AdBonusCard(
              bonusQuestionCount: bonusQuestionCount,
              onBonusGranted: () =>
                  _celebrateAdBonus(context, ref, bonusQuestionCount),
              onBonusAttemptStarted: onAdBonusAttemptStarted,
            ),
            const SizedBox(height: PassqlSpacing.md),
            _DailySetBonusCard(
              dailyBonus: dailyBonus,
              bonusQuestionCount: bonusQuestionCount,
              onOpenDailySet: () => _openDailySet(context),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            PassqlButton(
              label: '광고 없이 제한 없이 풀기 (PRO) ›',
              variant: PassqlButtonVariant.plain,
              size: PassqlButtonSize.regular,
              onPressed: () => _openPassSheet(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  /// 광고 보상 반영 > 보상 연출(+N문제, 남은 수 차오름) > 닫으면 [onUnlocked]
  Future<void> _celebrateAdBonus(
    BuildContext context,
    WidgetRef ref,
    int bonusQuestionCount,
  ) async {
    final knownPlan = ref.read(knownPlanProvider);
    await showPassqlRewardCelebration(
      context,
      bonusQuestionCount: bonusQuestionCount,
      reasonText: PassqlRewardReason.adWatched,
      remainingAfter:
          ref.read(freeRemainingSolvesProvider) ?? bonusQuestionCount,
      totalQuestionCount: knownPlan?.effectiveTodayFreeLimit,
    );
    if (context.mounted) onUnlocked();
  }

  /// 오늘의 세트: 호출부 이동이 있으면 그것, 없으면 세트 화면 쌓기 > 돌아오면 다시 받기 (세트 보너스로 풀렸을 수 있음)
  Future<void> _openDailySet(BuildContext context) async {
    final onOpenDailySet = this.onOpenDailySet;
    if (onOpenDailySet != null) return onOpenDailySet();
    await context.push<void>(AppRoutes.dailySet);
    if (context.mounted) onUnlocked();
  }

  /// 이용권 시트 (한도 사유 없이) > 구매·복원으로 프로가 되면 [onUnlocked]
  Future<void> _openPassSheet(BuildContext context, WidgetRef ref) async {
    final sheetOutcome = await showProOfferSheet(context, ref);
    if (sheetOutcome == ProOfferSheetOutcome.purchased && context.mounted) {
      onUnlocked();
    }
  }
}

/// 광고 카드: 아이콘 + 제목·길이 안내 > 광고 보기 버튼(상태 한 줄 포함)
class _AdBonusCard extends StatelessWidget {
  const _AdBonusCard({
    required this.bonusQuestionCount,
    required this.onBonusGranted,
    required this.onBonusAttemptStarted,
  });

  final int bonusQuestionCount;
  final VoidCallback onBonusGranted;
  final void Function(Future<bool> isBonusGranted)? onBonusAttemptStarted;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PassqlIconTile(
                icon: CupertinoIcons.play_fill,
                color: colors.accent,
              ),
              const SizedBox(width: PassqlSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '광고 보고 $bonusQuestionCount문제 더',
                      style: PassqlTypography.headline.copyWith(
                        color: colors.label,
                      ),
                    ),
                    Text(
                      '15~30초, 끝까지 보면 받아요',
                      style: PassqlTypography.footnote.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.md),
          RewardedAdBonusButton(
            onBonusGranted: onBonusGranted,
            onBonusAttemptStarted: onBonusAttemptStarted,
          ),
        ],
      ),
    );
  }
}

/// 오늘의 세트 카드: 보너스 2줄(받았으면 받았어요) > 세트를 끝내기 전이면 풀러 가기 버튼
class _DailySetBonusCard extends StatelessWidget {
  const _DailySetBonusCard({
    required this.dailyBonus,
    required this.bonusQuestionCount,
    required this.onOpenDailySet,
  });

  /// 오늘 받은 보너스 (등급을 모르면 null > 둘 다 안 받음으로 표시)
  final DailyFreeBonus? dailyBonus;
  final int bonusQuestionCount;
  final VoidCallback onOpenDailySet;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isCompletionEarned = dailyBonus?.isDailySetCompletionEarned ?? false;
    final isAccuracyEarned = dailyBonus?.isDailySetAccuracyEarned ?? false;
    return PassqlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '오늘의 세트로 더 열기',
            style: PassqlTypography.footnoteSemibold.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          _DailySetBonusRow(
            icon: CupertinoIcons.checkmark_alt,
            label: '세트 5문제 모두 풀기',
            bonusQuestionCount: bonusQuestionCount,
            isEarned: isCompletionEarned,
          ),
          const SizedBox(height: PassqlSpacing.sm),
          _DailySetBonusRow(
            icon: CupertinoIcons.star_fill,
            label: '세트 4문제 이상 맞히기',
            bonusQuestionCount: bonusQuestionCount,
            isEarned: isAccuracyEarned,
          ),
          // 세트를 끝냈으면 두 보너스 판정이 끝나 갈 곳 없음
          if (!isCompletionEarned) ...[
            const SizedBox(height: PassqlSpacing.md),
            PassqlButton(
              label: '오늘의 세트 풀러 가기',
              variant: PassqlButtonVariant.tinted,
              size: PassqlButtonSize.regular,
              onPressed: onOpenDailySet,
            ),
          ],
        ],
      ),
    );
  }
}

/// 세트 보너스 한 줄: 아이콘 + 조건 + 오른쪽 +N(받았으면 받았어요)
class _DailySetBonusRow extends StatelessWidget {
  const _DailySetBonusRow({
    required this.icon,
    required this.label,
    required this.bonusQuestionCount,
    required this.isEarned,
  });

  final IconData icon;
  final String label;
  final int bonusQuestionCount;
  final bool isEarned;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      children: [
        PassqlIconTile(
          icon: icon,
          color: isEarned ? colors.secondaryLabel : colors.correct,
        ),
        const SizedBox(width: PassqlSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: PassqlTypography.subheadline.copyWith(color: colors.label),
          ),
        ),
        const SizedBox(width: PassqlSpacing.xs),
        Text(
          isEarned ? '받았어요' : '+$bonusQuestionCount',
          style: PassqlTypography.footnoteSemibold.copyWith(
            color: isEarned ? colors.secondaryLabel : colors.correctText,
          ),
        ),
      ],
    );
  }
}
