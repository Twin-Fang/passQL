import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';

// 정답률 보너스 기준 (%, 서버 DailyFreeBonusRule.ACCURACY_PERCENT_THRESHOLD 와 같은 값)
const int _accuracyBonusPercentThreshold = 80;

/// 오늘의 세트 결과 보너스 카드 (#808): 결제 UI 대상 무료 회원 + 받은 보너스 있을 때만
/// 진입 시 등급 다시 받기(방금 완료 반영) > 받은 합계 + 이유 줄, 정답률 미달이면 다음 기준 안내
class DailySetBonusCard extends ConsumerStatefulWidget {
  const DailySetBonusCard({super.key, required this.assignedQuestionCount});

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
    unawaited(ref.read(planProvider.notifier).refresh());
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
    final reasonLines = [
      if (dailyBonus.isDailySetCompletionEarned) '세트 완료 +$bonusQuestionCount',
      if (dailyBonus.isDailySetAccuracyEarned)
        '정답 $_accuracyBonusCorrectCount개 이상 +$bonusQuestionCount'
      else
        '$_accuracyBonusCorrectCount개 이상 맞히면 +$bonusQuestionCount 더',
    ];
    return PassqlCard(
      title: '랜덤 풀기 +$earnedQuestionCount문제 열렸어요',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final reasonLine in reasonLines)
            Padding(
              padding: const EdgeInsets.only(top: PassqlSpacing.xxs),
              child: Text(
                reasonLine,
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
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
