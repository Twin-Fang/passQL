import 'package:flutter/material.dart';
import '../../../data/models/progress/readiness_response.dart';
import '../../design/design.dart';

/// 홈 합격 준비도 본문 (#972): 준비도 링(가운데 점수) + 오른쪽 지표 3줄(이름·값·막대) > 상황 문구
/// 링·숫자·막대는 한 진행값으로 0에서 함께 차오름 (점수 차오름 700ms, 동작 줄이기면 바로 최종값)
class HomeReadinessBody extends StatelessWidget {
  const HomeReadinessBody({
    super.key,
    required this.readiness,
    required this.scorePercent,
    required this.message,
  });

  final ReadinessResponse readiness;
  final int scorePercent;
  final String message;

  /// 아직 푼 기록이 없음: 점수·정확도·최신성 모두 0, 다룬 토픽 0
  bool get _isEmpty =>
      readiness.score <= 0 &&
      readiness.accuracy <= 0 &&
      readiness.recency <= 0 &&
      readiness.coveredTopicCount == 0;

  @override
  Widget build(BuildContext context) {
    // 기록이 없으면 0% 지표 대신 무엇을 하면 채워지는지 안내 (빈 링은 자리 표시로 남김)
    if (_isEmpty) return const _EmptyReadinessBody();

    final colors = context.passqlColors;
    final accuracyText = '${(readiness.accuracy * 100).round()}%';
    final coverageText =
        '${readiness.coveredTopicCount}/${readiness.activeTopicCount}';
    final recencyText = '${(readiness.recency * 100).round()}%';
    // 지표 3개: 이름, 표시 값, 막대 비율 (범위는 7/9 처럼 개수로 표시)
    final metrics = [
      (label: '정확도', valueText: accuracyText, ratio: readiness.accuracy),
      (label: '범위', valueText: coverageText, ratio: readiness.coverage),
      (label: '최신성', valueText: recencyText, ratio: readiness.recency),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 링과 지표를 한 번에 읽음 (차오르는 중간값은 읽지 않음)
        Semantics(
          label:
              '합격 준비도 $scorePercent%, 정확도 $accuracyText, '
              '범위 $coverageText, 최신성 $recencyText',
          excludeSemantics: true,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: PassqlMotion.durationOf(context, PassqlMotion.scoreFill),
            curve: PassqlMotion.curve,
            builder: (context, fillProgress, _) => Row(
              children: [
                PassqlReadinessRing(
                  value: readiness.score * fillProgress,
                  center: _RingCenterLabel(
                    displayedPercent: (scorePercent * fillProgress).round(),
                  ),
                ),
                const SizedBox(width: PassqlSpacing.lg),
                Expanded(
                  child: Column(
                    children: [
                      for (var i = 0; i < metrics.length; i++) ...[
                        if (i > 0) const SizedBox(height: PassqlSpacing.sm),
                        _ReadinessMetricRow(
                          label: metrics[i].label,
                          valueText: metrics[i].valueText,
                          barRatio: metrics[i].ratio * fillProgress,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (message.isNotEmpty) ...[
          const SizedBox(height: PassqlSpacing.md),
          Text(
            message,
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ],
      ],
    );
  }
}

/// 링 가운데: 차오르는 점수(크게, 강조 글자색) > '합격 준비도' 캡션
class _RingCenterLabel extends StatelessWidget {
  const _RingCenterLabel({required this.displayedPercent});

  final int displayedPercent;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    // 큰 글자 배율에서도 링 안쪽을 넘지 않게 줄여 맞춤
    return Padding(
      padding: const EdgeInsets.all(PassqlSize.readinessRingStroke),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$displayedPercent%',
              style: PassqlTypography.largeTitle.copyWith(
                color: colors.accentText,
                fontFeatures: PassqlTypography.tabular,
              ),
            ),
            Text(
              '합격 준비도',
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

/// 지표 한 줄: 이름(본문), 값(강조 글자색 굵게) > 둥근 막대
class _ReadinessMetricRow extends StatelessWidget {
  const _ReadinessMetricRow({
    required this.label,
    required this.valueText,
    required this.barRatio,
  });

  final String label;
  final String valueText;
  final double barRatio;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                label,
                style: PassqlTypography.body.copyWith(color: colors.label),
              ),
            ),
            Text(
              valueText,
              style: PassqlTypography.headline.copyWith(
                color: colors.accentText,
                fontFeatures: PassqlTypography.tabular,
              ),
            ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.xs),
        PassqlProgressBar(
          value: barRatio,
          height: PassqlSize.readinessMetricBarHeight,
          isFillAnimated: false,
        ),
      ],
    );
  }
}

/// 기록 없음: 빈 링 + 첫 세트 안내
class _EmptyReadinessBody extends StatelessWidget {
  const _EmptyReadinessBody();

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Semantics(
      label: '합격 준비도 아직 없음. 첫 세트를 풀면 준비도가 채워져요',
      excludeSemantics: true,
      child: Row(
        children: [
          const PassqlReadinessRing(value: 0),
          const SizedBox(width: PassqlSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PassqlKeepAllText(
                  '첫 세트를 풀면\n합격 준비도가 채워져요',
                  style: PassqlTypography.headline.copyWith(
                    color: colors.label,
                  ),
                ),
                const SizedBox(height: PassqlSpacing.xxs),
                PassqlKeepAllText(
                  '정확도, 범위, 최신성으로 계산해요',
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
