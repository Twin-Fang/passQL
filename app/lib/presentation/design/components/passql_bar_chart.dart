import 'dart:math' as math;

import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:flutter/widgets.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 막대 하나: [totalValue] 막대 전체 길이, [accentValue] 그중 아래부터 강조색으로 칠할 몫 (나머지는 옅은 색)
/// 쌓은 막대(맞힘/전체)는 accentValue 에 맞힌 수, 한 막대만 강조하려면 그 막대만 accentValue = totalValue
class PassqlBarChartBar {
  const PassqlBarChartBar({
    required this.totalValue,
    double? accentValue,
    this.label,
  }) : accentValue = accentValue ?? totalValue;

  final double totalValue;
  final double accentValue;

  /// 아래 축 글자 (null 이면 빈칸, 촘촘한 차트는 몇 칸만 적음)
  final String? label;
}

/// 세로 막대 차트 (#909 프로필 통계): 바닥선 + 막대(강조 몫·나머지 두 색) + 아래 축 글자.
/// 값은 막대 중 최댓값 기준 비율, 0 이 아니면 최소 높이로 보임. 처음 그릴 때 아래에서 자람(동작 줄이기면 정지).
/// 숫자는 쓰는 쪽이 글로 함께 보여 주고, 차트는 [semanticLabel] 한 문장으로만 읽힘
class PassqlBarChart extends StatelessWidget {
  const PassqlBarChart({
    super.key,
    required this.bars,
    required this.semanticLabel,
    this.height = defaultHeight,
    this.accentColor,
    this.restColor,
  });

  /// 막대 영역 기본 높이 (논리 픽셀, 축 글자 제외)
  static const double defaultHeight = 96;

  final List<PassqlBarChartBar> bars;
  final String semanticLabel;
  final double height;

  /// 강조 몫 색 (null 이면 강조색)
  final Color? accentColor;

  /// 나머지 몫 색 (null 이면 옅은 강조색, 강조 몫과 한 막대로 읽힘)
  final Color? restColor;

  // 칸 폭 대비 막대 폭 비율과 상한 (칸이 넓어도 막대가 뭉툭해지지 않게)
  static const double _barWidthRatio = 0.62;
  static const double _maximumBarWidth = 22;
  // 0 이 아닌 값의 최소 막대 높이 (아주 작은 값도 보이게)
  static const double _minimumVisibleHeight = 2;
  // 막대 윗모서리 반경 상한 (가는 막대는 폭의 절반)
  static const double _maximumTopRadius = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final effectiveAccent = accentColor ?? colors.accent;
    final effectiveRest = restColor ?? colors.accentTint;
    final maximumValue = bars.fold<double>(
      0,
      (maximum, bar) => math.max(maximum, bar.totalValue),
    );
    final hasLabels = bars.any((bar) => bar.label != null);
    return Semantics(
      label: semanticLabel,
      container: true,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: height,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: PassqlMotion.durationOf(
                context,
                PassqlMotion.scoreFill,
              ),
              curve: PassqlMotion.curve,
              builder: (context, growth, _) => DecoratedBox(
                // 바닥선: 값 0 인 칸도 축이 이어져 보이게
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colors.separator,
                      width: PassqlSize.hairline,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final bar in bars)
                      Expanded(
                        child: _BarSlot(
                          bar: bar,
                          maximumValue: maximumValue,
                          chartHeight: height,
                          growth: growth,
                          accentColor: effectiveAccent,
                          restColor: effectiveRest,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (hasLabels) ...[
            const SizedBox(height: PassqlSpacing.xxs),
            Row(
              children: [
                for (final bar in bars)
                  Expanded(
                    // 칸보다 긴 글자는 칸 가운데를 기준으로 양옆으로 넘쳐 그림 (촘촘한 차트)
                    child: Center(
                      child: OverflowBox(
                        minWidth: 0,
                        maxWidth: double.infinity,
                        // 높이는 글자만큼 (세로는 넘치지 않음)
                        fit: OverflowBoxFit.deferToChild,
                        child: Text(
                          bar.label ?? '',
                          maxLines: 1,
                          softWrap: false,
                          style: PassqlTypography.caption.copyWith(
                            color: colors.secondaryLabel,
                            fontFeatures: PassqlTypography.tabular,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 한 칸: 가운데 막대 (위 나머지 몫 + 아래 강조 몫)
class _BarSlot extends StatelessWidget {
  const _BarSlot({
    required this.bar,
    required this.maximumValue,
    required this.chartHeight,
    required this.growth,
    required this.accentColor,
    required this.restColor,
  });

  final PassqlBarChartBar bar;
  final double maximumValue;
  final double chartHeight;
  final double growth;
  final Color accentColor;
  final Color restColor;

  @override
  Widget build(BuildContext context) {
    if (bar.totalValue <= 0 || maximumValue <= 0) return const SizedBox.shrink();
    final fullHeight = math.max(
      PassqlBarChart._minimumVisibleHeight,
      chartHeight * bar.totalValue / maximumValue,
    );
    final barHeight = fullHeight * growth;
    final accentRatio = (bar.accentValue / bar.totalValue).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = math.min(
          PassqlBarChart._maximumBarWidth,
          constraints.maxWidth * PassqlBarChart._barWidthRatio,
        );
        final topRadius = Radius.circular(
          math.min(PassqlBarChart._maximumTopRadius, barWidth / 2),
        );
        return Align(
          alignment: Alignment.bottomCenter,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: topRadius,
              topRight: topRadius,
            ),
            child: SizedBox(
              width: barWidth,
              height: barHeight,
              child: Column(
                // 자식 없는 ColoredBox 는 폭 0 이 되므로 막대 폭으로 늘림
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: ColoredBox(color: restColor)),
                  SizedBox(
                    height: barHeight * accentRatio,
                    child: ColoredBox(color: accentColor),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
