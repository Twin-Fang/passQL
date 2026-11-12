import 'package:flutter/cupertino.dart';

import '../../../core/utils/daily_set_bonus_rule.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';

/// 오늘의 세트 보너스 체크 2줄 (세트 완료·세트 정답 80%): 크레딧 시트 세트 카드·세트 결과 보너스 카드 공용
/// 받은 보너스 > 상태 3종(받을 수 있음·받음·오늘은 못 받음), 결과 카드는 받은 줄만
class DailySetBonusCheckRows extends StatelessWidget {
  const DailySetBonusCheckRows({
    super.key,
    required this.dailyBonus,
    required this.bonusQuestionCount,
    this.shouldShowEarnedOnly = false,
  });

  /// 오늘 받은 보너스 (등급을 모르면 null > 둘 다 안 받음으로 표시)
  final DailyFreeBonus? dailyBonus;
  final int bonusQuestionCount;

  /// true: 받은 줄만 (세트 결과 카드, 못 받은 줄을 늘어놓지 않음) / false: 받는 방법 안내라 2줄 모두 (크레딧 시트)
  final bool shouldShowEarnedOnly;

  @override
  Widget build(BuildContext context) {
    final isCompletionEarned = dailyBonus?.isDailySetCompletionEarned ?? false;
    final isAccuracyEarned = dailyBonus?.isDailySetAccuracyEarned ?? false;
    // 세트를 끝냈는데 못 받았으면 오늘은 더 받을 수 없음
    final accuracyState = isAccuracyEarned
        ? _BonusRowState.earned
        : isCompletionEarned
        ? _BonusRowState.missed
        : _BonusRowState.obtainable;
    final rows = [
      if (!shouldShowEarnedOnly || isCompletionEarned)
        _DailySetBonusRow(
          label: DailySetBonusRule.completionLabel,
          bonusQuestionCount: bonusQuestionCount,
          state: isCompletionEarned
              ? _BonusRowState.earned
              : _BonusRowState.obtainable,
        ),
      if (!shouldShowEarnedOnly || isAccuracyEarned)
        _DailySetBonusRow(
          label: DailySetBonusRule.accuracyLabel,
          bonusQuestionCount: bonusQuestionCount,
          state: accuracyState,
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) const SizedBox(height: PassqlSpacing.sm),
          row,
        ],
      ],
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
    final isMissed = state == _BonusRowState.missed;
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
          opacity: isMissed ? _missedOpacity : 1,
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
                  decoration: isMissed ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
