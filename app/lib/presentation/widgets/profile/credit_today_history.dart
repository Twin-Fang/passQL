import '../../../data/models/member/member_plan_response.dart';

/// 오늘 크레딧 내역 한 줄 (#971): 받은 것은 양수, 쓴 것은 음수
class CreditHistoryEntry {
  const CreditHistoryEntry({required this.label, required this.amount});

  final String label;
  final int amount;

  bool get isSpent => amount < 0;
}

/// 오늘 크레딧 내역: 기본 > 세트 완료 > 세트 정답 80% > 광고(받은 횟수) > 랜덤 풀기 사용
/// 서버가 주는 오늘 집계(등급 응답)만으로 만듦, 받지 않은 보너스·쓰지 않은 사용 줄은 빼고 보임
List<CreditHistoryEntry> buildTodayCreditHistory(MemberPlanResponse plan) {
  final bonus = plan.dailyBonus;
  final bonusCount = bonus.bonusQuestionCount;
  final adCredits = bonus.adBonusUsedCount * bonusCount;
  return [
    CreditHistoryEntry(label: '오늘 기본', amount: plan.dailyFreeLimit),
    if (bonus.isDailySetCompletionEarned && bonusCount > 0)
      CreditHistoryEntry(label: '오늘의 세트 완료', amount: bonusCount),
    if (bonus.isDailySetAccuracyEarned && bonusCount > 0)
      CreditHistoryEntry(label: '오늘의 세트 정답 80%', amount: bonusCount),
    if (adCredits > 0)
      CreditHistoryEntry(
        label: '광고 보기 ${bonus.adBonusUsedCount}번',
        amount: adCredits,
      ),
    if (plan.todayRandomSolvedCount > 0)
      CreditHistoryEntry(
        label: '랜덤 풀기 ${plan.todayRandomSolvedCount}문제',
        amount: -plan.todayRandomSolvedCount,
      ),
  ];
}
