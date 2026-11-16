import '../../../core/utils/question_difficulty.dart';
import 'difficulty_stat.dart';

/// 난이도 단계(쉬움, 보통, 어려움) 한 칸 정답률: 1~5 단계 기록을 묶은 값 (#1145)
class DifficultyLevelStat {
  const DifficultyLevelStat({
    required this.level,
    required this.solvedCount,
    required this.correctRate,
  });

  final QuestionDifficultyLevel level;
  final int solvedCount;

  /// 0~1, 푼 문제 수 가중 평균
  final double correctRate;
}

/// 난이도 1~5 정답률 목록 > 단계별 3칸 (쉬움 > 보통 > 어려움 순, 푼 문제 없는 단계·범위 밖 값 제외)
List<DifficultyLevelStat> toDifficultyLevelStats(
  List<DifficultyStat> difficultyStats,
) {
  // 단계별 합계 (푼 수, 맞힌 수 = 정답률 x 푼 수)
  final solvedCountByLevel = <QuestionDifficultyLevel, int>{};
  final correctCountByLevel = <QuestionDifficultyLevel, double>{};
  for (final stat in difficultyStats) {
    final level = toQuestionDifficultyLevel(stat.difficulty);
    if (level == null || stat.solvedCount <= 0) continue;
    solvedCountByLevel[level] =
        (solvedCountByLevel[level] ?? 0) + stat.solvedCount;
    correctCountByLevel[level] =
        (correctCountByLevel[level] ?? 0) + stat.correctRate * stat.solvedCount;
  }
  return [
    for (final level in QuestionDifficultyLevel.values)
      if (solvedCountByLevel[level] case final solvedCount?)
        DifficultyLevelStat(
          level: level,
          solvedCount: solvedCount,
          correctRate: correctCountByLevel[level]! / solvedCount,
        ),
  ];
}
