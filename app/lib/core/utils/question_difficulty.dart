/// 문제 난이도 최대 단계 (서버 관리자 등록·AI 서버 ai_request.py·웹 StarRating 과 같은 1~5)
const int maximumQuestionDifficulty = 5;

/// 난이도 > 1~5 범위 값 (없거나 범위 밖이면 가장 가까운 끝값)
int toClampedQuestionDifficulty(int? difficulty) =>
    (difficulty ?? 1).clamp(1, maximumQuestionDifficulty);

/// 난이도 > 별 글자 (3 > ★★★☆☆)
String toDifficultyStarText(int? difficulty) {
  final filledCount = toClampedQuestionDifficulty(difficulty);
  return '★' * filledCount + '☆' * (maximumQuestionDifficulty - filledCount);
}
