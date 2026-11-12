/// 홈 「다음에 할 일」 한 가지 (#975)
enum HomeNextStep {
  dailySet, // 오늘의 세트를 아직 안 풂
  randomPractice, // 세트를 풀었고 랜덤 풀기를 이어 갈 수 있음
  earnCredits, // 크레딧을 다 씀: 광고·이용권 안내
  browseQuestions, // 랜덤 풀기 진입이 없는 환경: 문제 탭
}

/// 다음 할 일 판정: 오늘의 세트 > (랜덤 풀기 없음 > 문제 탭) > 크레딧 0 > 랜덤 풀기
/// [remainingCredits] null = 크레딧 개념이 적용되지 않음(프로·결제 꺼짐)
HomeNextStep decideHomeNextStep({
  required bool canSolveDailySet,
  required bool isRandomPracticeVisible,
  required int? remainingCredits,
}) {
  if (canSolveDailySet) return HomeNextStep.dailySet;
  if (!isRandomPracticeVisible) return HomeNextStep.browseQuestions;
  if (remainingCredits == 0) return HomeNextStep.earnCredits;
  return HomeNextStep.randomPractice;
}
