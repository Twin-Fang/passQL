import 'package:flutter/widgets.dart';

import '../../../core/utils/profile_pass_values.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../practice/credit_balance_header.dart';
import 'credit_today_history_sheet.dart';
import 'profile_bonus_cards.dart';

/// 무료 오늘 남은 문제 (#816 A안): 제목·내역 링크 > 남은 수 큰 숫자 / 오늘 한도 > 사용량 게이지 > 문제 더 받기 카드(세트 완료·세트 정답률·광고)
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
                '오늘 크레딧',
                style: PassqlTypography.headline.copyWith(color: colors.label),
              ),
            ),
            // 오늘 받은·쓴 내역 (다시 채워지는 때도 그 안에서 안내)
            PassqlSectionLink(
              label: '내역',
              semanticLabel: '오늘 크레딧 내역 보기',
              onTap: () => showCreditTodayHistorySheet(context, plan),
            ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.xxs),
        CreditBalanceHeader(
          remainingCount: remaining,
          baseLimit: plan.dailyFreeLimit,
          totalLimit: limit,
        ),
        const SizedBox(height: PassqlSpacing.sm),
        ProfileBonusCards(bonus: plan.dailyBonus),
      ],
    );
  }
}
