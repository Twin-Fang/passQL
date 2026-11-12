import 'package:flutter/widgets.dart';

import '../../../core/utils/profile_pass_values.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import 'profile_bonus_cards.dart';

/// 무료 오늘 남은 문제 (#816 A안): 제목·초기화 안내 > 남은 수 큰 숫자 / 오늘 한도 > 사용량 게이지 > 문제 더 받기 카드(세트 완료·세트 정답률·광고)
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
        ProfileBonusCards(bonus: plan.dailyBonus),
      ],
    );
  }
}
