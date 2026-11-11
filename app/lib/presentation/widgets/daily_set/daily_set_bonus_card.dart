import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../practice/open_random_practice.dart';

// 정답률 보너스 기준 (%, 서버 DailyFreeBonusRule.ACCURACY_PERCENT_THRESHOLD 와 같은 값)
const int _accuracyBonusPercentThreshold = 80;

/// 오늘의 세트 결과 보너스 카드 (#808): 결제 UI 대상 무료 회원 + 받은 보너스 있을 때만
/// 진입 시 등급 다시 받기(방금 완료 반영) > 보상 연출(방금 완료 진입만) + 강조 카드(+N문제, 이유 칩, 이어 풀기)
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
          PassqlRewardReason.dailySetAccurate,
      ].join('\n'),
      remainingAfter: ref.read(freeRemainingSolvesProvider) ?? 0,
      totalQuestionCount: knownPlan?.effectiveTodayFreeLimit,
      actionLabel: '확인',
    );
  }

  /// 정답률 보너스에 필요한 맞힌 수 (배정 수의 80% 올림)
  int get _accuracyBonusCorrectCount =>
      (widget.assignedQuestionCount * _accuracyBonusPercentThreshold + 99) ~/
      100;

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
            '+$earnedQuestionCount문제 열렸어요',
            style: PassqlTypography.title1.copyWith(color: colors.accentText),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          Wrap(
            spacing: PassqlSpacing.xs,
            runSpacing: PassqlSpacing.xs,
            children: [
              if (dailyBonus.isDailySetCompletionEarned)
                const PassqlBadge(text: '세트 완료'),
              if (dailyBonus.isDailySetAccuracyEarned)
                PassqlBadge(text: '정답 $_accuracyBonusCorrectCount개 이상'),
            ],
          ),
          if (!dailyBonus.isDailySetAccuracyEarned)
            Padding(
              padding: const EdgeInsets.only(top: PassqlSpacing.sm),
              child: Text(
                '$_accuracyBonusCorrectCount개 이상 맞히면 $bonusQuestionCount문제 더 열려요',
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ),
          const SizedBox(height: PassqlSpacing.md),
          PassqlButton(
            label: '랜덤 풀기로 이어 가기',
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
