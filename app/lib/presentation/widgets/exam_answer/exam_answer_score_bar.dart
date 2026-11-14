import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 점수 막대 1개: 이름·점수 > 막대(채움 + 갈림 범위 띠 + 기준선) > 기준선 이름
/// 기준(과락·합격) 이상이면 초록, 미만이면 빨강
class ExamAnswerScoreBar extends StatelessWidget {
  const ExamAnswerScoreBar({
    super.key,
    required this.label,
    required this.score,
    required this.maxScore,
    required this.cutScore,
    required this.cutLabel,
    this.rangeMinScore,
    this.rangeMaxScore,
  });

  final String label;
  final int score;
  final int maxScore;

  /// 기준 점수 (이 점수 미만이면 과락·불합격)
  final int cutScore;

  /// 기준선 아래 이름 (예: `과락 8점`)
  final String cutLabel;

  /// 갈림·미확정 문항에 따른 범위 (같으면 띠 없음)
  final int? rangeMinScore;
  final int? rangeMaxScore;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isBelowCut = score < cutScore;
    final fillColor = isBelowCut ? colors.wrong : colors.correct;
    final rangeMin = rangeMinScore ?? score;
    final rangeMax = rangeMaxScore ?? score;
    return Semantics(
      container: true,
      label:
          '$label $score점, 만점 $maxScore점, $cutLabel${isBelowCut ? ', 기준 미달' : ''}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: PassqlTypography.subheadline.copyWith(
                    color: colors.label,
                  ),
                ),
              ),
              Text(
                '$score',
                style: PassqlTypography.headline.copyWith(
                  fontFeatures: PassqlTypography.tabular,
                  color: isBelowCut ? colors.wrongText : colors.label,
                ),
              ),
              Text(
                ' / $maxScore',
                style: PassqlTypography.footnote.copyWith(
                  fontFeatures: PassqlTypography.tabular,
                  color: colors.secondaryLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.xs),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              double positionOf(int value) =>
                  maxScore == 0 ? 0 : width * (value / maxScore).clamp(0, 1);
              return SizedBox(
                height:
                    PassqlSize.examAnswerScoreBarHeight +
                    PassqlSize.examAnswerCutLineOverhang * 2,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 트랙 + 채움
                    Positioned(
                      left: 0,
                      right: 0,
                      top: PassqlSize.examAnswerCutLineOverhang,
                      child: PassqlProgressBar(
                        value: maxScore == 0 ? 0 : score / maxScore,
                        fillColor: fillColor,
                        height: PassqlSize.examAnswerScoreBarHeight,
                      ),
                    ),
                    // 갈림 범위 띠 (최소 ~ 최대)
                    if (rangeMax > rangeMin)
                      Positioned(
                        left: positionOf(rangeMin),
                        width: positionOf(rangeMax) - positionOf(rangeMin),
                        top: PassqlSize.examAnswerCutLineOverhang,
                        height: PassqlSize.examAnswerScoreBarHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.warning.withValues(
                              alpha: PassqlOpacity.examAnswerScoreRange,
                            ),
                            borderRadius: BorderRadius.circular(
                              PassqlRadius.capsule,
                            ),
                          ),
                        ),
                      ),
                    // 기준선 (막대 위아래로 조금 삐져나옴)
                    Positioned(
                      left:
                          positionOf(cutScore) -
                          PassqlSize.examAnswerCutLineWidth / 2,
                      top: 0,
                      bottom: 0,
                      width: PassqlSize.examAnswerCutLineWidth,
                      child: ColoredBox(color: colors.label),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          // 기준선 이름: 선 위치 비율로 정렬 (양 끝을 넘지 않음)
          Align(
            alignment: Alignment(
              (maxScore == 0 ? 0.0 : cutScore / maxScore).clamp(0, 1) * 2 - 1,
              0,
            ),
            child: Text(
              cutLabel,
              style: PassqlTypography.caption.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
