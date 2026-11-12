import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/utils/daily_set_bonus_rule.dart';
import '../passql_haptics.dart';
import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_button.dart';
import 'passql_code_block.dart';
import 'passql_credit_icon.dart';
import 'passql_query_status_line.dart';

/// 보상 연출 이유 문구 (광고·세트 완료·세트 정답, 보상 받은 화면 공통)
abstract final class PassqlRewardReason {
  static const adWatched = '광고를 끝까지 봐서 받았어요';
  static const dailySetCompleted = '오늘의 세트를 끝내서 받았어요';

  /// 세트 정답 80%: 배정 문제 수 > 기준 맞힌 수를 문장에 (예: 5문제 > 4개)
  static String dailySetAccurateOf(int assignedQuestionCount) =>
      '${DailySetBonusRule.accuracyLabel}(${DailySetBonusRule.accuracyCorrectCountOf(assignedQuestionCount)}개 이상)를 채워서 받았어요';
}

/// 보상 창 SQL 말투 한 줄 원본 (#999): 크레딧 UPDATE 문 > 실행 결과 줄
abstract final class PassqlRewardSql {
  /// 실행 결과 줄 (UPDATE 1행)
  static const updatedRowText = '1행 수정됨';

  /// 받은 크레딧 수 > UPDATE 문 (예: 5 > `SET 오늘 = 오늘 + 5;`)
  static String creditUpdateOf(int bonusCreditCount) =>
      'UPDATE 크레딧\nSET 오늘 = 오늘 + $bonusCreditCount;';
}

/// 보상 연출: 동전 팝·빛·불꽃 > +N 크레딧 > 이유 > UPDATE 한 줄·결과 > 오늘 크레딧 이전 > 이후 + 기본·보너스 게이지 > 주 버튼
/// [dailyBaseCreditCount] 오늘 기본 한도, [todayBonusCreditCount] 오늘 받은 보너스 합 (모르면 이번 보상 기준)
Future<void> showPassqlRewardCelebration(
  BuildContext context, {
  required int bonusQuestionCount,
  required String reasonText,
  required int remainingAfter,
  String actionLabel = '이어서 풀기',
  int? dailyBaseCreditCount,
  int? todayBonusCreditCount,
}) {
  PassqlHaptics.playCorrectAnswer();
  final remainingBefore = math.max(remainingAfter - bonusQuestionCount, 0);
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) => _RewardCelebrationPanel(
      bonusCreditCount: bonusQuestionCount,
      reasonText: reasonText,
      remainingBefore: remainingBefore,
      remainingAfter: remainingAfter,
      actionLabel: actionLabel,
      // 기본 구간: 등급 기본 한도, 모르면 받기 전 남은 수
      gaugeBaseCount: dailyBaseCreditCount ?? remainingBefore,
      // 보너스 구간: 오늘 보너스 합 (등급 응답이 늦어 작으면 이번 보상만큼은 보장)
      gaugeBonusCount: math.max(todayBonusCreditCount ?? 0, bonusQuestionCount),
      onActionPressed: () => Navigator.of(dialogContext).pop(),
    ),
  );
}

/// 보상 창 패널: 연출 컨트롤러 하나를 구간별로 나눠 씀
class _RewardCelebrationPanel extends StatefulWidget {
  const _RewardCelebrationPanel({
    required this.bonusCreditCount,
    required this.reasonText,
    required this.remainingBefore,
    required this.remainingAfter,
    required this.actionLabel,
    required this.gaugeBaseCount,
    required this.gaugeBonusCount,
    required this.onActionPressed,
  });

  final int bonusCreditCount;
  final String reasonText;
  final int remainingBefore;
  final int remainingAfter;
  final String actionLabel;
  final int gaugeBaseCount;
  final int gaugeBonusCount;
  final VoidCallback onActionPressed;

  @override
  State<_RewardCelebrationPanel> createState() =>
      _RewardCelebrationPanelState();
}

class _RewardCelebrationPanelState extends State<_RewardCelebrationPanel>
    with SingleTickerProviderStateMixin {
  // 연출 구간 (전체 PassqlMotion.rewardCelebration 기준 비율)
  static const Interval _coinInterval = Interval(0.07, 0.36);
  static const Interval _glowInterval = Interval(0.07, 0.64);
  static const Interval _sparkInterval = Interval(0.18, 0.49);
  static const Interval _titleInterval = Interval(0.26, 0.43);
  static const Interval _sqlInterval = Interval(0.33, 0.48);
  static const Interval _resultInterval = Interval(0.43, 0.55);
  static const Interval _baseGaugeInterval = Interval(0.48, 0.76);
  static const Interval _bonusGaugeInterval = Interval(0.71, 1.0);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PassqlMotion.rewardCelebration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating || _controller.isCompleted) return;
    // 동작 줄이기면 마지막 모습만
    if (PassqlMotion.isReduced(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _phase(Interval interval) =>
      CurvedAnimation(parent: _controller, curve: interval);

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Dialog(
      backgroundColor: colors.card,
      insetPadding: const EdgeInsets.all(PassqlSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PassqlRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.lg,
          PassqlSpacing.xl,
          PassqlSpacing.lg,
          PassqlSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RewardCoin(
              coinProgress: _phase(_coinInterval),
              glowProgress: _phase(_glowInterval),
              sparkProgress: _phase(_sparkInterval),
            ),
            const SizedBox(height: PassqlSpacing.sm),
            _RiseIn(
              progress: _phase(_titleInterval),
              child: Text(
                '+${widget.bonusCreditCount} 크레딧',
                style: PassqlTypography.largeTitle.copyWith(
                  color: colors.correctText,
                ),
              ),
            ),
            const SizedBox(height: PassqlSpacing.xxs),
            Text(
              widget.reasonText,
              textAlign: TextAlign.center,
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            const SizedBox(height: PassqlSpacing.md),
            _RiseIn(
              progress: _phase(_sqlInterval),
              child: PassqlCodeBlock(
                code: PassqlRewardSql.creditUpdateOf(widget.bonusCreditCount),
                isSelectable: false,
                highlightedKeywords: PassqlCodeBlock.sqlKeywords,
              ),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            _RiseIn(
              progress: _phase(_resultInterval),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: PassqlQueryStatusLine(
                  text: PassqlRewardSql.updatedRowText,
                ),
              ),
            ),
            const SizedBox(height: PassqlSpacing.md),
            _CreditCountRow(
              remainingBefore: widget.remainingBefore,
              remainingAfter: widget.remainingAfter,
              countProgress: _phase(_bonusGaugeInterval),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            _CreditGauge(
              baseCount: widget.gaugeBaseCount,
              bonusCount: widget.gaugeBonusCount,
              baseProgress: _phase(_baseGaugeInterval),
              bonusProgress: _phase(_bonusGaugeInterval),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            _GaugeLegend(
              baseCount: widget.gaugeBaseCount,
              bonusCount: widget.gaugeBonusCount,
            ),
            const SizedBox(height: PassqlSpacing.lg),
            PassqlButton(
              label: widget.actionLabel,
              onPressed: widget.onActionPressed,
            ),
          ],
        ),
      ),
    );
  }
}

/// 크레딧 동전: 빛 번짐 + 8개 불꽃 퍼짐 + 동전 팝(0 > 1.15 > 1배, -20° > 6° > 0°)
class _RewardCoin extends StatelessWidget {
  const _RewardCoin({
    required this.coinProgress,
    required this.glowProgress,
    required this.sparkProgress,
  });

  final Animation<double> coinProgress;
  final Animation<double> glowProgress;
  final Animation<double> sparkProgress;

  // 불꽃 개수·지름·퍼지는 거리, 빛이 동전 밖으로 나가는 폭
  static const int _sparkCount = 8;
  static const double _sparkDiameter = 6;
  static const double _sparkTravel = 60;
  static const double _glowOutset = 14;
  // 동전 팝 키프레임 (70% 지점에서 가장 큼)
  static const double _popPeakPoint = 0.7;
  static const double _popPeakScale = 1.15;
  static const double _startDegrees = -20;
  static const double _peakDegrees = 6;

  double _coinScaleOf(double progress) => progress < _popPeakPoint
      ? _popPeakScale * progress / _popPeakPoint
      : _popPeakScale -
            (_popPeakScale - 1) *
                (progress - _popPeakPoint) /
                (1 - _popPeakPoint);

  double _coinDegreesOf(double progress) => progress < _popPeakPoint
      ? _startDegrees +
            (_peakDegrees - _startDegrees) * progress / _popPeakPoint
      : _peakDegrees * (1 - (progress - _popPeakPoint) / (1 - _popPeakPoint));

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: PassqlIconSize.rewardCoin,
        child: AnimatedBuilder(
          animation: coinProgress,
          builder: (_, _) => Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              _buildGlow(colors),
              for (var index = 0; index < _sparkCount; index++)
                _buildSpark(colors, index),
              Transform.rotate(
                angle: _coinDegreesOf(coinProgress.value) * math.pi / 180,
                child: Transform.scale(
                  scale: _coinScaleOf(coinProgress.value),
                  child: const PassqlCreditIcon(
                    size: PassqlIconSize.rewardCoin,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 빛: 0.6 > 1.4배로 커지며 40% 지점까지 밝아졌다 사라짐
  Widget _buildGlow(PassqlColors colors) {
    final progress = glowProgress.value;
    if (progress <= 0 || progress >= 1) return const SizedBox.shrink();
    const brightestPoint = 0.4;
    final opacity = progress < brightestPoint
        ? progress / brightestPoint
        : 1 - (progress - brightestPoint) / (1 - brightestPoint);
    return Positioned(
      left: -_glowOutset,
      top: -_glowOutset,
      right: -_glowOutset,
      bottom: -_glowOutset,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: 0.6 + 0.8 * progress,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [colors.passGlow, colors.passGlow.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 불꽃 한 개: 가운데에서 각도 방향으로 퍼지며 작아지고 사라짐
  Widget _buildSpark(PassqlColors colors, int index) {
    final progress = sparkProgress.value;
    if (progress <= 0 || progress >= 1) return const SizedBox.shrink();
    final angle = index / _sparkCount * 2 * math.pi;
    return Transform.translate(
      offset: Offset(
        math.cos(angle) * _sparkTravel * progress,
        math.sin(angle) * _sparkTravel * progress,
      ),
      child: Opacity(
        opacity: 1 - progress,
        child: Transform.scale(
          scale: 1 - 0.7 * progress,
          child: Container(
            width: _sparkDiameter,
            height: _sparkDiameter,
            decoration: BoxDecoration(
              color: colors.accent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// 아래에서 살짝 올라오며 나타남
class _RiseIn extends StatelessWidget {
  const _RiseIn({required this.progress, required this.child});

  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      child: child,
      builder: (_, child) => Opacity(
        opacity: progress.value,
        child: Transform.translate(
          offset: Offset(
            0,
            PassqlMotion.revealSlideDistance * (1 - progress.value),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 오늘 크레딧  이전 → 이후 (이후 숫자는 보너스 게이지와 함께 올라감)
class _CreditCountRow extends StatelessWidget {
  const _CreditCountRow({
    required this.remainingBefore,
    required this.remainingAfter,
    required this.countProgress,
  });

  final int remainingBefore;
  final int remainingAfter;
  final Animation<double> countProgress;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Semantics(
      label: '오늘 크레딧 $remainingBefore개에서 $remainingAfter개',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '오늘 크레딧',
            style: PassqlTypography.subheadlineSemibold.copyWith(
              color: colors.label,
            ),
          ),
          const Spacer(),
          Text(
            '$remainingBefore → ',
            style: PassqlTypography.subheadlineSemibold.copyWith(
              color: colors.secondaryLabel,
              fontFeatures: PassqlTypography.tabular,
            ),
          ),
          AnimatedBuilder(
            animation: countProgress,
            builder: (_, _) => Text(
              '${(remainingBefore + (remainingAfter - remainingBefore) * countProgress.value).round()}',
              style: PassqlTypography.title3.copyWith(
                color: colors.label,
                fontWeight: FontWeight.w700,
                fontFeatures: PassqlTypography.tabular,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 오늘 한도 게이지: 기본 구간(accent)이 먼저 차고 > 보너스 구간(correct)이 늘어남, 사이 2px
class _CreditGauge extends StatelessWidget {
  const _CreditGauge({
    required this.baseCount,
    required this.bonusCount,
    required this.baseProgress,
    required this.bonusProgress,
  });

  final int baseCount;
  final int bonusCount;
  final Animation<double> baseProgress;
  final Animation<double> bonusProgress;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final totalCount = baseCount + bonusCount;
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
        child: SizedBox(
          height: PassqlSize.rewardGaugeHeight,
          child: LayoutBuilder(
            builder: (_, constraints) {
              // 두 구간이 다 있을 때만 사이 틈
              final gap = baseCount > 0 && bonusCount > 0
                  ? PassqlSpacing.hairlineGap
                  : 0.0;
              final fillableWidth = constraints.maxWidth - gap;
              final baseFullWidth = totalCount <= 0
                  ? 0.0
                  : fillableWidth * baseCount / totalCount;
              final bonusFullWidth = totalCount <= 0
                  ? 0.0
                  : fillableWidth * bonusCount / totalCount;
              return AnimatedBuilder(
                animation: Listenable.merge([baseProgress, bonusProgress]),
                builder: (_, _) => Stack(
                  children: [
                    Positioned.fill(child: ColoredBox(color: colors.fill)),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: baseFullWidth * baseProgress.value,
                      child: ColoredBox(color: colors.accent),
                    ),
                    Positioned(
                      left: baseFullWidth + gap,
                      top: 0,
                      bottom: 0,
                      width: bonusFullWidth * bonusProgress.value,
                      child: ColoredBox(color: colors.correct),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 범례: ■ 기본 N  ■ 보너스 +M
class _GaugeLegend extends StatelessWidget {
  const _GaugeLegend({required this.baseCount, required this.bonusCount});

  final int baseCount;
  final int bonusCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: colors.accent, text: '기본 $baseCount'),
        const SizedBox(width: PassqlSpacing.sm),
        _LegendItem(color: colors.correct, text: '보너스 +$bonusCount'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.text});

  final Color color;
  final String text;

  // 범례 색 칸 한 변·모서리
  static const double _swatchSize = 8;
  static const double _swatchRadius = 2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _swatchSize,
          height: _swatchSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(_swatchRadius),
          ),
        ),
        const SizedBox(width: PassqlSpacing.xxs),
        Text(
          text,
          style: PassqlTypography.caption.copyWith(
            color: context.passqlColors.secondaryLabel,
          ),
        ),
      ],
    );
  }
}
