import 'package:flutter/cupertino.dart';

import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';

/// 한도 화면의 오늘의 세트 카드: 보너스 2줄(받을 수 있음·받았어요·오늘은 못 받음) > 세트를 끝내기 전이면 풀러 가기 버튼
class DailyLimitDailySetCard extends StatelessWidget {
  const DailyLimitDailySetCard({
    super.key,
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
            state: isCompletionEarned
                ? _BonusRowState.earned
                : _BonusRowState.obtainable,
          ),
          const SizedBox(height: PassqlSpacing.sm),
          _DailySetBonusRow(
            icon: CupertinoIcons.star_fill,
            label: '세트 4문제 이상 맞히기',
            bonusQuestionCount: bonusQuestionCount,
            // 세트를 끝냈는데 못 받았으면 오늘은 더 받을 수 없음
            state: isAccuracyEarned
                ? _BonusRowState.earned
                : isCompletionEarned
                ? _BonusRowState.missed
                : _BonusRowState.obtainable,
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

/// 세트 보너스 한 줄 상태 3종
enum _BonusRowState {
  obtainable, // 아직 받을 수 있음: 초록 +N
  earned, // 받았어요
  missed, // 세트를 끝냈지만 못 받음: 오늘은 받지 못했어요
}

/// 세트 보너스 한 줄: 아이콘 + 조건 + 오른쪽 상태 (+N·받았어요·오늘은 받지 못했어요)
class _DailySetBonusRow extends StatelessWidget {
  const _DailySetBonusRow({
    required this.icon,
    required this.label,
    required this.bonusQuestionCount,
    required this.state,
  });

  final IconData icon;
  final String label;
  final int bonusQuestionCount;
  final _BonusRowState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isObtainable = state == _BonusRowState.obtainable;
    return Row(
      children: [
        PassqlIconTile(
          icon: icon,
          color: isObtainable ? colors.correct : colors.secondaryLabel,
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
          switch (state) {
            _BonusRowState.obtainable => '+$bonusQuestionCount',
            _BonusRowState.earned => '받았어요',
            _BonusRowState.missed => '오늘은 받지 못했어요',
          },
          style: PassqlTypography.footnoteSemibold.copyWith(
            color: isObtainable ? colors.correctText : colors.secondaryLabel,
          ),
        ),
      ],
    );
  }
}
