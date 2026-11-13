import 'package:flutter/cupertino.dart';

import '../../../core/utils/question_difficulty.dart';
import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 난이도 별 5개 (#1041): 채운 별 + 빈 별 아이콘, 스크린리더는 "난이도 N / 5"
/// 풀이 화면 머리·홈 추천·프로필 난이도별 정답률 공용 (글자 ★☆ 대신 아이콘으로 모양·크기 통일)
class PassqlDifficultyStars extends StatelessWidget {
  const PassqlDifficultyStars({
    super.key,
    required this.difficulty,
    this.size = PassqlIconSize.xxs,
  });

  /// 문제 난이도 (없거나 범위 밖이면 1~5로 맞춤)
  final int? difficulty;

  /// 별 하나 크기
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final filledCount = toClampedQuestionDifficulty(difficulty);
    return Semantics(
      label: '난이도 $filledCount / $maximumQuestionDifficulty',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < maximumQuestionDifficulty; index++)
            Icon(
              index < filledCount
                  ? CupertinoIcons.star_fill
                  : CupertinoIcons.star,
              size: size,
              // 별 대비 3:1 이상: 채운 별 warningText, 빈 별 iconSecondary (색 말고 채움 모양으로도 구분)
              color: index < filledCount
                  ? colors.warningText
                  : colors.iconSecondary,
            ),
        ],
      ),
    );
  }
}
