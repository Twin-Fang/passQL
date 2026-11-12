import 'package:flutter/cupertino.dart';

import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';

// 보너스 카드 아이콘 원 지름
const double _iconCircleSize = 36;

/// 보너스 카드 상태 3종: 받음(초록), 받을 수 있음(기본), 광고(강조색, 횟수 제한 없음)
enum _BonusCardState { earned, available, ad }

/// 「문제 더 받기」 카드 3장 (#966): 세트 완료 +N, 세트 정답 80% +N, 광고 +N씩(횟수 제한 없음)
/// 광고 보너스 대상이 아니면 2장
class ProfileBonusCards extends StatelessWidget {
  const ProfileBonusCards({super.key, required this.bonus});

  final DailyFreeBonus bonus;

  @override
  Widget build(BuildContext context) {
    final bonusText = '+${bonus.bonusQuestionCount}';
    final cards = [
      _BonusCard(
        icon: CupertinoIcons.checkmark_alt,
        label: '세트 완료',
        valueText: bonusText,
        captionWhenAvailable: '오늘의 세트를 끝내면',
        state: bonus.isDailySetCompletionEarned
            ? _BonusCardState.earned
            : _BonusCardState.available,
      ),
      _BonusCard(
        icon: CupertinoIcons.scope,
        label: '세트 정답 80%',
        valueText: bonusText,
        captionWhenAvailable: '세트 정답이 80%면',
        state: bonus.isDailySetAccuracyEarned
            ? _BonusCardState.earned
            : _BonusCardState.available,
      ),
      if (bonus.canEarnAdBonus)
        _BonusCard(
          icon: CupertinoIcons.play_fill,
          label: '광고 보기',
          valueText: '$bonusText씩',
          // 받은 횟수가 있으면 횟수, 없으면 제한 없음 안내
          captionWhenAvailable: bonus.adBonusUsedCount > 0
              ? '오늘 ${bonus.adBonusUsedCount}번 받음'
              : '횟수 제한 없음',
          state: _BonusCardState.ad,
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '크레딧 더 받기',
          style: PassqlTypography.footnoteSemibold.copyWith(
            color: context.passqlColors.secondaryLabel,
          ),
        ),
        const SizedBox(height: PassqlSpacing.xs),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                if (index > 0) const SizedBox(width: PassqlSpacing.xs),
                Expanded(child: cards[index]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 보너스 카드 1장: 아이콘 원 > 이름 > 문제 수 > 상태 한 줄
class _BonusCard extends StatelessWidget {
  const _BonusCard({
    required this.icon,
    required this.label,
    required this.valueText,
    required this.captionWhenAvailable,
    required this.state,
  });

  final IconData icon;
  final String label;
  final String valueText;

  /// 아직 안 받았을 때(또는 광고) 아래 한 줄. 받은 뒤에는 `받았어요`
  final String captionWhenAvailable;
  final _BonusCardState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final (
      cardColor,
      borderColor,
      circleColor,
      glyphColor,
      valueColor,
    ) = switch (state) {
      _BonusCardState.earned => (
        colors.correctTint,
        colors.correctTint,
        colors.correct,
        colors.onSemantic,
        colors.correctText,
      ),
      _BonusCardState.available => (
        colors.card,
        colors.separator,
        colors.fill,
        colors.iconSecondary,
        colors.label,
      ),
      _BonusCardState.ad => (
        Color.alphaBlend(colors.accentTint, colors.card),
        colors.accent,
        colors.accent,
        colors.onAccent,
        colors.accentText,
      ),
    };
    final caption = state == _BonusCardState.earned
        ? '받았어요'
        : captionWhenAvailable;
    return Semantics(
      label: '$label, 크레딧 $valueText, $caption',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PassqlSpacing.xxs,
          vertical: PassqlSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(PassqlRadius.md),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _iconCircleSize,
              height: _iconCircleSize,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: PassqlIconSize.md, color: glyphColor),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            _FittedLine(
              label,
              style: PassqlTypography.caption.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            _FittedLine(
              valueText,
              style: PassqlTypography.headline.copyWith(color: valueColor),
            ),
            _FittedLine(
              caption,
              style: PassqlTypography.caption.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 한 줄 글자: 카드 폭보다 길면 줄여 그림 (좁은 폰·큰 글자에서 줄바꿈 방지)
class _FittedLine extends StatelessWidget {
  const _FittedLine(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text, maxLines: 1, style: style),
    );
  }
}
