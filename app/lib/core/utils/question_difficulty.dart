/// 문제 난이도 범위 1~5 (서버 관리자 등록·AI 서버 ai_request.py·웹 StarRating 과 같은 범위)
const int minimumQuestionDifficulty = 1;
const int maximumQuestionDifficulty = 5;

/// 난이도 표시 3단계: 쉬움, 보통, 어려움 (#1145, 별 대신 글자)
enum QuestionDifficultyLevel {
  easy('쉬움'),
  normal('보통'),
  hard('어려움');

  const QuestionDifficultyLevel(this.label);

  /// 화면 표시 이름
  final String label;

  /// 단계 번호 1~3 (쉬움 1, 보통 2, 어려움 3) = 난이도 띠 채운 칸 수 (#1147)
  int get difficultyStepNumber => index + 1;

  /// 단계 수 3 = 난이도 띠 전체 칸 수
  static int get difficultyStepCount => values.length;
}

/// 단계 번호 1~3 > 단계 (회차 체감 난이도 등 이미 3단계인 값, 범위 밖이면 null, #1158)
QuestionDifficultyLevel? toDifficultyLevelFromStepNumber(int stepNumber) =>
    stepNumber >= 1 && stepNumber <= QuestionDifficultyLevel.values.length
    ? QuestionDifficultyLevel.values[stepNumber - 1]
    : null;

// 문항 난이도 구간 상한 (이하면 해당 단계, #1145)
const int _easyDifficultyUpperBound = 2;
const int _normalDifficultyUpperBound = 3;

/// 문항 난이도 1~5 > 단계 (1~2 쉬움, 3 보통, 4~5 어려움), 없거나 범위 밖이면 null
QuestionDifficultyLevel? toQuestionDifficultyLevel(int? difficulty) {
  if (difficulty == null ||
      difficulty < minimumQuestionDifficulty ||
      difficulty > maximumQuestionDifficulty) {
    return null;
  }
  if (difficulty <= _easyDifficultyUpperBound) {
    return QuestionDifficultyLevel.easy;
  }
  if (difficulty <= _normalDifficultyUpperBound) {
    return QuestionDifficultyLevel.normal;
  }
  return QuestionDifficultyLevel.hard;
}

/// 문항 난이도 1~5 > 표시 이름 (쉬움, 보통, 어려움), 표시 안 하면 null
String? toDifficultyLabel(int? difficulty) =>
    toQuestionDifficultyLevel(difficulty)?.label;

// 회차 평균 난이도 구간 경계 (미만이면 앞 단계, #1084)
const double _roundEasyDifficultyUpperBound = 2.5;
const double _roundNormalDifficultyUpperBound = 3.5;

/// 회차 문항 평균 난이도(1~5) > 표시 이름 (쉬움, 보통, 어려움), 없으면 null
String? toRoundDifficultyLabel(double? averageDifficulty) {
  if (averageDifficulty == null) return null;
  if (averageDifficulty < _roundEasyDifficultyUpperBound) {
    return QuestionDifficultyLevel.easy.label;
  }
  if (averageDifficulty < _roundNormalDifficultyUpperBound) {
    return QuestionDifficultyLevel.normal.label;
  }
  return QuestionDifficultyLevel.hard.label;
}
