/// 문제 난이도 최대 단계 (서버 관리자 등록·AI 서버 ai_request.py·웹 StarRating 과 같은 1~5)
const int maximumQuestionDifficulty = 5;

/// 난이도 > 1~5 범위 값 (없거나 범위 밖이면 가장 가까운 끝값)
int toClampedQuestionDifficulty(int? difficulty) =>
    (difficulty ?? 1).clamp(1, maximumQuestionDifficulty);

// 회차 평균 난이도 구간 경계 (미만이면 앞 단계, #1084)
const double _roundEasyDifficultyUpperBound = 2.5;
const double _roundNormalDifficultyUpperBound = 3.5;

/// 회차 문항 평균 난이도(1~5) > 표시 이름 (쉬움, 보통, 어려움), 없으면 null
String? toRoundDifficultyLabel(double? averageDifficulty) {
  if (averageDifficulty == null) return null;
  if (averageDifficulty < _roundEasyDifficultyUpperBound) return '쉬움';
  if (averageDifficulty < _roundNormalDifficultyUpperBound) return '보통';
  return '어려움';
}
