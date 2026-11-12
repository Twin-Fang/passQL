/// 오늘의 세트 크레딧 보너스: 이름 2개(세트 완료·세트 정답 80%) + 정답률 기준
/// 크레딧 시트·프로필 받는 방법·크레딧 내역·세트 결과 카드·보상 연출이 같은 이름을 씀
abstract final class DailySetBonusRule {
  // 정답률 보너스 기준 (%, 서버 DailyFreeBonusRule.ACCURACY_PERCENT_THRESHOLD 와 같은 값)
  static const int accuracyPercentThreshold = 80;

  static const String completionLabel = '세트 완료';
  static const String accuracyLabel = '세트 정답 $accuracyPercentThreshold%';

  /// 정답률 보너스에 필요한 맞힌 수 (배정 수의 기준 % 올림)
  static int accuracyCorrectCountOf(int assignedQuestionCount) =>
      (assignedQuestionCount * accuracyPercentThreshold + 99) ~/ 100;
}
