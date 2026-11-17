import 'package:flutter/widgets.dart';

import '../../../core/utils/question_difficulty.dart';
import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 난이도 표시: 가로 3칸 띠 + 글자 (쉬움 1칸, 보통 2칸, 어려움 3칸, #1147)
/// 풀이 머리·홈 추천 메타 줄, 프로필 난이도별 정답률 공용. 이미지 없이 코드로 그림
class PassqlDifficultyIndicator extends StatelessWidget {
  const PassqlDifficultyIndicator({
    super.key,
    required this.level,
    required this.textStyle,
  });

  /// 난이도 단계 (toQuestionDifficultyLevel 로 1~5 에서 도출)
  final QuestionDifficultyLevel level;

  /// 옆 글자 모양 (놓이는 줄의 글자와 맞춤)
  final TextStyle textStyle;

  /// 글자 줄 안에 끼우는 조각 (메타 줄 Text.rich 용, 글자 높이 가운데 정렬)
  /// WidgetSpan 이 줄 글자 배율만큼 통째로 키우므로 안쪽 글자 배율은 끔 (이중 확대 방지)
  static InlineSpan spanOf(
    QuestionDifficultyLevel level,
    TextStyle textStyle,
  ) => WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: MediaQuery.withNoTextScaling(
      child: PassqlDifficultyIndicator(level: level, textStyle: textStyle),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Semantics(
      label: '난이도 ${level.label}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 띠 3칸 (채운 칸 secondaryLabel, 빈 칸 tertiaryLabel: 색 말고 채운 수로도 구분)
          for (
            var index = 0;
            index < QuestionDifficultyLevel.difficultyStepCount;
            index++
          ) ...[
            if (index > 0) const SizedBox(width: PassqlSpacing.hairlineGap),
            Container(
              width: PassqlSize.difficultySegmentWidth,
              height: PassqlSize.difficultySegmentHeight,
              decoration: BoxDecoration(
                color: index < level.difficultyStepNumber
                    ? colors.secondaryLabel
                    : colors.tertiaryLabel,
                borderRadius: BorderRadius.circular(PassqlRadius.capsule),
              ),
            ),
          ],
          const SizedBox(width: PassqlSpacing.xxs),
          Text(level.label, style: textStyle),
        ],
      ),
    );
  }
}
