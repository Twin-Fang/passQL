import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/daily_set_bonus_rule.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../practice/open_random_practice.dart';

/// 오늘의 세트 결과 보너스 카드 (#808): 결제 UI 대상 무료 회원 + 받은 보너스 있을 때만
/// 진입 시 등급 다시 받기(방금 완료 반영) > 보상 연출(방금 완료 진입만) + 강조 카드(크레딧 +N, 이유 칩, 랜덤 풀기 보조 버튼)
/// 정답률 미달이면 다음 기준 안내
class DailySetBonusCard extends ConsumerStatefulWidget {
  const DailySetBonusCard({
    super.key,
    required this.assignedQuestionCount,
    this.shouldCelebrate = false,
  });

  /// 풀이를 막 끝낸 진입이면 true (기록에서 다시 열면 카드만)
  final bool shouldCelebrate;

  /// 오늘 배정된 세트 문제 수 (정답률 기준 개수 계산)
  final int assignedQuestionCount;

  @override
  ConsumerState<DailySetBonusCard> createState() => _DailySetBonusCardState();
}

class _DailySetBonusCardState extends ConsumerState<DailySetBonusCard> {
  @override
  void initState() {
    super.initState();
    // 완료 기록 직후라 보너스가 아직 반영 안 된 등급일 수 있음
    unawaited(_refreshThenCelebrate());
  }

  /// 등급 갱신 > 받은 보상이 있으면 연출 1회 (이유 문구는 받은 보상 종류대로)
  Future<void> _refreshThenCelebrate() async {
    await ref.read(planProvider.notifier).refresh();
    if (!mounted || !widget.shouldCelebrate) return;
    // 기다리는 사이 다른 창(광고 안내·잠금 창 등)이 떴거나 화면을 떠났으면 연출 생략 (창 위에 쌓지 않음, #963)
    if (ModalRoute.of(context)?.isCurrent != true) return;
    final knownPlan = ref.read(knownPlanProvider);
    final dailyBonus = knownPlan?.dailyBonus;
    if (!ref.read(shouldShowProUiProvider) || dailyBonus == null) return;
    final earnedQuestionCount = _earnedDailySetQuestionCountOf(dailyBonus);
    if (earnedQuestionCount == 0) return;
    await showPassqlRewardCelebration(
      context,
      bonusQuestionCount: earnedQuestionCount,
      reasonText: [
        if (dailyBonus.isDailySetCompletionEarned)
          PassqlRewardReason.dailySetCompleted,
        if (dailyBonus.isDailySetAccuracyEarned)
          PassqlRewardReason.dailySetAccurateOf(widget.assignedQuestionCount),
      ].join('\n'),
      remainingAfter: ref.read(freeRemainingSolvesProvider) ?? 0,
      dailyBaseCreditCount: knownPlan?.dailyFreeLimit,
      todayBonusCreditCount: knownPlan?.todayBonusFreeLimit,
      actionLabel: '확인',
    );
  }

  /// 정답률 보너스에 필요한 맞힌 수
  int get _accuracyBonusCorrectCount =>
      DailySetBonusRule.accuracyCorrectCountOf(widget.assignedQuestionCount);

  @override
  Widget build(BuildContext context) {
    final dailyBonus = ref.watch(knownPlanProvider)?.dailyBonus;
    if (!ref.watch(shouldShowProUiProvider) || dailyBonus == null) {
      return const SizedBox.shrink();
    }
    final earnedQuestionCount = _earnedDailySetQuestionCountOf(dailyBonus);
    if (earnedQuestionCount == 0) return const SizedBox.shrink();
    final colors = context.passqlColors;
    final bonusQuestionCount = dailyBonus.bonusQuestionCount;
    // 못 받은 정답률 보너스는 다음 기준 안내 줄로
    return PassqlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '크레딧 +$earnedQuestionCount개 받았어요',
            style: PassqlTypography.title1.copyWith(color: colors.accentText),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          Wrap(
            spacing: PassqlSpacing.xs,
            runSpacing: PassqlSpacing.xs,
            children: [
              if (dailyBonus.isDailySetCompletionEarned)
                const PassqlBadge(text: DailySetBonusRule.completionLabel),
              if (dailyBonus.isDailySetAccuracyEarned)
                const PassqlBadge(text: DailySetBonusRule.accuracyLabel),
            ],
          ),
          if (!dailyBonus.isDailySetAccuracyEarned)
            Padding(
              padding: const EdgeInsets.only(top: PassqlSpacing.sm),
              child: Text(
                '${DailySetBonusRule.accuracyLabel}($_accuracyBonusCorrectCount개 이상)를 채우면 크레딧 $bonusQuestionCount개를 더 받아요',
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ),
          const SizedBox(height: PassqlSpacing.md),
          // 결과 화면의 채운 버튼은 아래 닫기 하나라 보조 모양
          PassqlButton(
            label: '랜덤 풀기로 이어 가기',
            variant: PassqlButtonVariant.tinted,
            onPressed: () => openRandomPractice(context, ref),
          ),
        ],
      ),
    );
  }

  /// 세트로 받은 보너스 문제 수 (광고 보너스 제외)
  static int _earnedDailySetQuestionCountOf(DailyFreeBonus dailyBonus) =>
      ((dailyBonus.isDailySetCompletionEarned ? 1 : 0) +
          (dailyBonus.isDailySetAccuracyEarned ? 1 : 0)) *
      dailyBonus.bonusQuestionCount;
}
