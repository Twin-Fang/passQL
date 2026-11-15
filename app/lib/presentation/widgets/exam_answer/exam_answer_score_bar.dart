import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 과목 행 안 얇은 점수 막대: 채움(기준 이상 초록, 미만 빨강) + 과락 기준 눈금 하나
/// 글자 없음 > 점수·기준은 행 글자와 묶음 각주가 전달 (막대는 스크린리더에서 숨김)
class ExamAnswerScoreBar extends StatelessWidget {
  const ExamAnswerScoreBar({
    super.key,
    required this.score,
    required this.maxScore,
    required this.cutScore,
  });

  final int score;
  final int maxScore;

  /// 기준 점수 (이 점수 미만이면 과락)
  final int cutScore;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isBelowCut = score < cutScore;
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final cutRatio = maxScore == 0
              ? 0.0
              : (cutScore / maxScore).clamp(0.0, 1.0);
          return SizedBox(
            height:
                PassqlSize.progressBarHeight +
                PassqlSize.examAnswerCutLineOverhang * 2,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: PassqlSize.examAnswerCutLineOverhang,
                  child: PassqlProgressBar(
                    value: maxScore == 0 ? 0 : score / maxScore,
                    fillColor: isBelowCut ? colors.wrong : colors.correct,
                  ),
                ),
                // 과락 기준 눈금 (막대 위아래로 조금 삐져나옴)
                Positioned(
                  left:
                      width * cutRatio - PassqlSize.examAnswerCutLineWidth / 2,
                  top: 0,
                  bottom: 0,
                  width: PassqlSize.examAnswerCutLineWidth,
                  child: ColoredBox(color: colors.secondaryLabel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
