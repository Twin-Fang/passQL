import 'package:flutter/cupertino.dart';

import '../../../core/utils/daily_set_bonus_rule.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';

/// 크레딧 시트의 오늘의 세트 카드: 머리(제목·한 줄 설명) > 보너스 2줄(받을 수 있음·받았어요·오늘은 못 받음) > 세트를 끝내기 전이면 풀러 가기 버튼
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
          // 머리: 광고 카드와 같은 구성 (아이콘 타일 + 제목 + 한 줄 설명)
          Row(
            children: [
              PassqlIconTile(
                icon: CupertinoIcons.square_list_fill,
                color: colors.accent,
              ),
              const SizedBox(width: PassqlSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 세트로 크레딧 받기',
                      style: PassqlTypography.headline.copyWith(
                        color: colors.label,
                      ),
                    ),
                    Text(
                      '하루 한 번, 최대 ${bonusQuestionCount * 2}개',
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
          _DailySetBonusRow(
            label: DailySetBonusRule.completionLabel,
            bonusQuestionCount: bonusQuestionCount,
            state: isCompletionEarned
                ? _BonusRowState.earned
                : _BonusRowState.obtainable,
          ),
          const SizedBox(height: PassqlSpacing.sm),
          _DailySetBonusRow(
            label: DailySetBonusRule.accuracyLabel,
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

// 오늘 못 받게 된 보너스의 크레딧 수 흐림 정도
const double _missedOpacity = 0.5;

/// 세트 보너스 한 줄 상태 3종
enum _BonusRowState {
  obtainable, // 아직 받을 수 있음: 빈 원 + 강조색 크레딧 수
  earned, // 받음: 초록 체크 + 초록 크레딧 수
  missed, // 세트를 끝냈지만 못 받음: 회색 빼기 + 흐린 줄 그은 크레딧 수
}

/// 세트 보너스 한 줄: 상태 아이콘(빈 원·초록 체크·회색 빼기) + 조건 + 오른쪽 크레딧 수 (상태는 글자 대신 아이콘·색으로)
class _DailySetBonusRow extends StatelessWidget {
  const _DailySetBonusRow({
    required this.label,
    required this.bonusQuestionCount,
    required this.state,
  });

  final String label;
  final int bonusQuestionCount;
  final _BonusRowState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final (stateIcon, stateIconColor) = switch (state) {
      _BonusRowState.obtainable => (
        CupertinoIcons.circle,
        colors.iconSecondary,
      ),
      _BonusRowState.earned => (
        CupertinoIcons.checkmark_circle_fill,
        colors.correct,
      ),
      _BonusRowState.missed => (
        CupertinoIcons.minus_circle,
        colors.iconSecondary,
      ),
    };
    return Row(
      children: [
        Icon(stateIcon, size: PassqlIconSize.xl, color: stateIconColor),
        const SizedBox(width: PassqlSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: PassqlTypography.subheadline.copyWith(color: colors.label),
          ),
        ),
        const SizedBox(width: PassqlSpacing.xs),
        // 오른쪽은 늘 크레딧 수: 받을 수 있음 강조색, 받음 초록, 못 받음 흐리게 줄 그음
        Opacity(
          opacity: state == _BonusRowState.missed ? _missedOpacity : 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PassqlCreditIcon(),
              const SizedBox(width: PassqlSpacing.xxs),
              Text(
                '+$bonusQuestionCount',
                style: PassqlTypography.subheadlineSemibold.copyWith(
                  color: switch (state) {
                    _BonusRowState.obtainable => colors.accentText,
                    _BonusRowState.earned => colors.correctText,
                    _BonusRowState.missed => colors.secondaryLabel,
                  },
                  decoration: state == _BonusRowState.missed
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
