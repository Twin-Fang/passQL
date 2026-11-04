import 'package:flutter/widgets.dart';

import '../../../core/utils/profile_pass_values.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';

/// 무료 오늘 남은 문제 (#816 A안): 제목·초기화 안내 > 남은 수 큰 숫자 / 오늘 한도 > 사용량 게이지 > 보너스 칸(세트 완료·세트 정답률·광고)
/// 남은 수 = 오늘 유효 한도(보너스 포함) - 오늘 푼 랜덤 문제 (0 아래로 내려가지 않음), 초기화는 KST 0시
class ProfileTodayFreeUsage extends StatelessWidget {
  const ProfileTodayFreeUsage({super.key, required this.plan});

  final MemberPlanResponse plan;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final limit = plan.effectiveTodayFreeLimit;
    final used = plan.todayRandomSolvedCount;
    final remaining = remainingFreeSolves(used: used, limit: limit);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '오늘 남은 문제',
                style: PassqlTypography.headline.copyWith(color: colors.label),
              ),
            ),
            Text(
              '내일 0시에 다시 ${plan.dailyFreeLimit}개',
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.xxs),
        Semantics(
          label: '오늘 남은 문제 $remaining개, 오늘 $limit문제 중',
          excludeSemantics: true,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$remaining',
                  style: PassqlTypography.largeTitle.copyWith(
                    color: colors.accentText,
                  ),
                ),
                TextSpan(
                  text: ' / $limit문제',
                  style: PassqlTypography.subheadline.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: PassqlSpacing.xs),
        PassqlPassUsageGauge(value: limit <= 0 ? 0 : used / limit),
        const SizedBox(height: PassqlSpacing.sm),
        _BonusChips(bonus: plan.dailyBonus),
      ],
    );
  }
}

/// 보너스 칸 3개: 세트 완료 +N, 세트 정답률 +N, 광고 남은 횟수 (광고 보너스가 없는 날이면 2칸)
class _BonusChips extends StatelessWidget {
  const _BonusChips({required this.bonus});

  final DailyFreeBonus bonus;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final bonusText = '+${bonus.bonusQuestionCount}';
    String earnedTextOf(bool isEarned) =>
        isEarned ? '$bonusText 받음' : '$bonusText 가능';
    final chips = [
      _BonusChip(
        label: '세트 완료',
        statusText: earnedTextOf(bonus.isDailySetCompletionEarned),
        valueColor: bonus.isDailySetCompletionEarned
            ? colors.correctText
            : colors.secondaryLabel,
      ),
      _BonusChip(
        label: '세트 정답 80%',
        statusText: earnedTextOf(bonus.isDailySetAccuracyEarned),
        valueColor: bonus.isDailySetAccuracyEarned
            ? colors.correctText
            : colors.secondaryLabel,
      ),
      if (bonus.adBonusMaxCount > 0)
        _BonusChip(
          label: '광고 보기',
          statusText: bonus.hasRemainingAdBonus
              ? '${bonus.remainingAdBonusCount}번 남음'
              : '다 받음',
          valueColor: bonus.hasRemainingAdBonus
              ? colors.accentText
              : colors.secondaryLabel,
        ),
    ];
    return Row(
      children: [
        for (var index = 0; index < chips.length; index++) ...[
          if (index > 0) const SizedBox(width: PassqlSpacing.xs),
          Expanded(child: chips[index]),
        ],
      ],
    );
  }
}

/// 보너스 칸 1개: 위 라벨 + 아래 상태 (회색 칸)
class _BonusChip extends StatelessWidget {
  const _BonusChip({
    required this.label,
    required this.statusText,
    required this.valueColor,
  });

  final String label;
  final String statusText;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.xxs,
        vertical: PassqlSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(PassqlRadius.md),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PassqlTypography.caption.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.hairlineGap),
          Text(
            statusText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PassqlTypography.footnoteSemibold.copyWith(
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
