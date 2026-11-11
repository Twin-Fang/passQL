import 'package:flutter/material.dart';

import '../passql_haptics.dart';
import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_button.dart';
import 'passql_pop_in.dart';

// 남은 수 게이지 높이
const double _gaugeHeight = 8;

/// 보상 연출 이유 문구 (광고·세트 완료·세트 정답, 보상 받은 화면 공통)
abstract final class PassqlRewardReason {
  static const adWatched = '광고를 끝까지 봐서 열렸어요';
  static const dailySetCompleted = '오늘의 세트를 끝내서 열렸어요';
  static const dailySetAccurate = '세트에서 4개 이상 맞혀서 열렸어요';
}

/// 보상 연출: 가운데 패널에 +N문제 팝 > 이유 > 남은 수 게이지·숫자 차오름 > 주 버튼
/// [totalQuestionCount] 게이지 기준 (생략하면 남은 수가 곧 가득 찬 상태)
Future<void> showPassqlRewardCelebration(
  BuildContext context, {
  required int bonusQuestionCount,
  required String reasonText,
  required int remainingAfter,
  String actionLabel = '이어서 풀기',
  int? totalQuestionCount,
}) {
  PassqlHaptics.playCorrectAnswer();
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) => _RewardCelebrationPanel(
      bonusQuestionCount: bonusQuestionCount,
      reasonText: reasonText,
      remainingAfter: remainingAfter,
      actionLabel: actionLabel,
      totalQuestionCount: totalQuestionCount ?? remainingAfter,
      onActionPressed: () => Navigator.of(dialogContext).pop(),
    ),
  );
}

class _RewardCelebrationPanel extends StatelessWidget {
  const _RewardCelebrationPanel({
    required this.bonusQuestionCount,
    required this.reasonText,
    required this.remainingAfter,
    required this.actionLabel,
    required this.totalQuestionCount,
    required this.onActionPressed,
  });

  final int bonusQuestionCount;
  final String reasonText;
  final int remainingAfter;
  final String actionLabel;
  final int totalQuestionCount;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final fillRatio = totalQuestionCount <= 0
        ? 0.0
        : (remainingAfter / totalQuestionCount).clamp(0.0, 1.0);
    return Dialog(
      backgroundColor: colors.card,
      insetPadding: const EdgeInsets.all(PassqlSpacing.xl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PassqlRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PassqlSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PassqlPopIn(
              isRotating: false,
              child: Text(
                '+$bonusQuestionCount문제',
                style: PassqlTypography.largeTitle.copyWith(
                  color: colors.accentText,
                ),
              ),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            Text(
              reasonText,
              textAlign: TextAlign.center,
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            const SizedBox(height: PassqlSpacing.lg),
            _RemainingCountText(remainingAfter: remainingAfter),
            const SizedBox(height: PassqlSpacing.xs),
            _RemainingGauge(fillRatio: fillRatio),
            const SizedBox(height: PassqlSpacing.xl),
            PassqlButton(label: actionLabel, onPressed: onActionPressed),
          ],
        ),
      ),
    );
  }
}

/// 오늘 남은 N문제: 0에서 N까지 올라감 (동작 줄이기면 바로 N)
class _RemainingCountText extends StatelessWidget {
  const _RemainingCountText({required this.remainingAfter});

  final int remainingAfter;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: remainingAfter.toDouble()),
      duration: PassqlMotion.durationOf(context, PassqlMotion.scoreFill),
      curve: PassqlMotion.curve,
      builder: (_, animatedCount, _) => Text(
        '오늘 남은 ${animatedCount.round()}문제',
        style: PassqlTypography.headline.copyWith(color: colors.label),
      ),
    );
  }
}

/// 남은 수 게이지: 0에서 차오름
class _RemainingGauge extends StatelessWidget {
  const _RemainingGauge({required this.fillRatio});

  final double fillRatio;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
        child: SizedBox(
          height: _gaugeHeight,
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: colors.separator)),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fillRatio),
                duration: PassqlMotion.durationOf(
                  context,
                  PassqlMotion.scoreFill,
                ),
                curve: PassqlMotion.curve,
                builder: (_, animatedRatio, _) => FractionallySizedBox(
                  widthFactor: animatedRatio,
                  child: ColoredBox(color: colors.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
