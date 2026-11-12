import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../../router/app_routes.dart';
import '../../../router/solving_flow_exit.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../ads/rewarded_ad_bonus_button.dart';
import '../pro/pro_access_feedback.dart';
import '../pro/pro_offer_sheet.dart';
import 'credit_balance_header.dart';
import 'credit_exhausted_query.dart';
import 'daily_limit_daily_set_card.dart';

// 등급 응답에 값이 없을 때의 수치 (DEC-0239: 기본 한도 10, 보너스 1회 5문제)
const int _fallbackDailyFreeLimit = 10;
const int _fallbackBonusQuestionCount = 5;

/// 무료 하루 한도 오류인지 (이 화면이 본문·시트로 맡음 > 자동 이용권 시트 대상 아님)
bool isFreeDailyLimitError(Object error) =>
    error.asAppException.code == ErrorCode.freeDailyLimitReached;

/// 한도 화면에서 오늘의 세트 열기: 풀이 흐름 안이면 지금 흐름을 세트로 교체, 밖(홈·문제 탭 진입)이면 쌓기
/// 흐름 위에 쌓으면 세트를 나갈 때 원래 흐름까지 닫힘 (제출한 답은 서버에 저장돼 교체해도 잃지 않음)
void openDailySetFromDailyLimit(BuildContext context) {
  if (isTopScreenSolvingFlow(context)) {
    context.pushReplacement(AppRoutes.dailySet);
  } else {
    context.push(AppRoutes.dailySet);
  }
}

/// 크레딧 화면 (A안, #963): 제목·내역 링크(0개면 다 쓴 이유와 충전 시각) > 잔액 > PRO(주 버튼) > 광고 보너스 > 오늘의 세트 보너스
/// 막다른 길 없음: 광고·세트·이용권 모두 갈 곳이 있고, 광고 보상·구매로 풀리면 [onUnlocked]
/// 남은 수가 늦게 늘어도(광고 확인 지연 > 다음 등급 조회) 「이어서 풀기」 버튼으로 [onUnlocked]
/// 세트는 풀이 흐름 안이면 지금 흐름을 세트로 교체 ([openDailySetFromDailyLimit])
class DailyLimitRewardView extends ConsumerWidget {
  const DailyLimitRewardView({
    super.key,
    required this.onUnlocked,
    this.canContinueInPlace = false,
    this.onOpenDailySet,
    this.onAdBonusAttemptStarted,
  });

  /// 광고 보상 연출을 닫았거나 이용권을 샀을 때 (같은 문제 다시 받기, 시트면 닫기)
  final VoidCallback onUnlocked;

  /// 풀이 화면 본문에서 막힌 경우: 크레딧이 생기면 `이어서 풀기` 를 보임 (시트는 닫으면 되므로 false)
  final bool canContinueInPlace;

  /// 오늘의 세트로 가기 (없으면 [openDailySetFromDailyLimit], 시트는 닫은 뒤 호출 화면에서 열기)
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
    // 보너스가 등급에 반영돼 풀 문제가 생겼는가 (본문·시트 공통)
    final remainingSolves = ref.watch(freeRemainingSolvesProvider) ?? 0;
    final hasUnlockedSolves = remainingSolves > 0;
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
            _CreditSheetTitle(
              isCreditsExhausted: remainingSolves == 0,
              dailyFreeLimit: dailyFreeLimit,
            ),
            const SizedBox(height: PassqlSpacing.sm),
            // 잔액: 아이콘 + 큰 숫자 + 게이지 (보너스 구간은 초록)
            CreditBalanceHeader(
              remainingCount: remainingSolves,
              baseLimit: dailyFreeLimit,
              totalLimit: knownPlan?.effectiveTodayFreeLimit ?? dailyFreeLimit,
            ),
            const SizedBox(height: PassqlSpacing.xs),
            // 0개면 충전 시각은 제목 아래에 이미 있음
            PassqlKeepAllText(
              '랜덤 풀기 1문제에 크레딧 1개'
              '${remainingSolves == 0 ? '' : ' · 내일 0시에 $dailyFreeLimit개 충전'}',
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            // 풀이 화면 안에서 막혔다가 크레딧이 생긴 경우에만 그 자리에서 이어 풀기
            if (canContinueInPlace && hasUnlockedSolves) ...[
              const SizedBox(height: PassqlSpacing.md),
              PassqlButton(
                key: const Key('daily-limit-continue-solving'),
                label: '이어서 풀기',
                variant: PassqlButtonVariant.tinted,
                onPressed: onUnlocked,
              ),
            ],
            // 이용권이 주 버튼 (화면의 유일한 채운 버튼)
            const SizedBox(height: PassqlSpacing.md),
            PassqlButton(
              label: 'PRO로 광고 없이 제한 없이 풀기',
              onPressed: () => _openPassSheet(context, ref),
            ),
            const SizedBox(height: PassqlSpacing.md),
            _AdBonusCard(
              bonusQuestionCount: bonusQuestionCount,
              onBonusGranted: () =>
                  _celebrateAdBonus(context, ref, bonusQuestionCount),
              onBonusAttemptStarted: onAdBonusAttemptStarted,
            ),
            const SizedBox(height: PassqlSpacing.md),
            DailyLimitDailySetCard(
              dailyBonus: dailyBonus,
              bonusQuestionCount: bonusQuestionCount,
              onOpenDailySet:
                  onOpenDailySet ?? () => openDailySetFromDailyLimit(context),
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
      dailyBaseCreditCount: knownPlan?.dailyFreeLimit,
      todayBonusCreditCount: knownPlan?.todayBonusFreeLimit,
    );
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

/// 시트 제목 줄: 제목 + 내역 링크, 크레딧 0개면 다 쓴 이유 > SELECT 0 rows·충전 시각 (#993, #999)
class _CreditSheetTitle extends StatelessWidget {
  const _CreditSheetTitle({
    required this.isCreditsExhausted,
    required this.dailyFreeLimit,
  });

  final bool isCreditsExhausted;

  /// 0시에 채워지는 하루 기본 크레딧 수
  final int dailyFreeLimit;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  isCreditsExhausted ? freeDailyLimitReason : '오늘 크레딧',
                  style: PassqlTypography.headline.copyWith(
                    color: colors.label,
                  ),
                ),
              ),
            ),
            // 날짜별 받은·쓴 내역 (프로필 오늘 크레딧과 같은 링크, 루트 화면이라 시트 위에 열림)
            PassqlSectionLink(
              label: '내역',
              semanticLabel: '크레딧 내역 보기',
              onTap: () => context.push(AppRoutes.creditHistory),
            ),
          ],
        ),
        // 다 썼으면 SELECT 0 rows 한 줄로 충전 시각 (#999)
        if (isCreditsExhausted) ...[
          const SizedBox(height: PassqlSpacing.xs),
          CreditExhaustedQuery(dailyFreeLimit: dailyFreeLimit),
        ],
      ],
    );
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
                      '광고 보고 크레딧 $bonusQuestionCount개 받기',
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
