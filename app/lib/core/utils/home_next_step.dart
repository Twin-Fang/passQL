/// 홈 「다음에 할 일」 한 가지 (#975)
enum HomeNextStep {
  dailySet, // 오늘의 세트를 아직 안 풂
  lockScreen, // 세트를 끝냈고 잠금화면 문제를 아직 안 켬 (Android, #990)
  randomPractice, // 세트를 풀었고 랜덤 풀기를 이어 갈 수 있음
  earnCredits, // 크레딧을 다 씀 (카드 숨김)
  mockExamTrial, // 크레딧을 다 썼고 모의고사 무료 1회가 남음
  browseQuestions, // 랜덤 풀기 진입이 없는 환경: 문제 탭
}

/// 다음 할 일 판정: 오늘의 세트 > 잠금화면 문제 소개 > (랜덤 풀기 없음 > 문제 탭) > 크레딧 0 (모의고사 무료 1회 > 숨김) > 랜덤 풀기
/// [remainingCredits] null = 크레딧 개념이 적용되지 않음(프로·결제 꺼짐)
/// [canSuggestLockScreen]: Android + 서버 스위치 + 안 켬 + 소개를 끝까지 거절하지 않음
HomeNextStep decideHomeNextStep({
  required bool canSolveDailySet,
  required bool isRandomPracticeVisible,
  required int? remainingCredits,
  bool hasMockExamTrial = false,
  bool canSuggestLockScreen = false,
}) {
  if (canSolveDailySet) return HomeNextStep.dailySet;
  if (canSuggestLockScreen) return HomeNextStep.lockScreen;
  if (!isRandomPracticeVisible) return HomeNextStep.browseQuestions;
  if (remainingCredits == 0) {
    return hasMockExamTrial
        ? HomeNextStep.mockExamTrial
        : HomeNextStep.earnCredits;
  }
  return HomeNextStep.randomPractice;
}
