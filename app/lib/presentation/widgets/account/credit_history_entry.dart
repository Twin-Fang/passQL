import '../../../data/models/member/credit_history_response.dart';

/// 크레딧 내역 한 줄 (#971, #974): 받은 것은 양수, 쓴 것은 음수
class CreditHistoryEntry {
  const CreditHistoryEntry({required this.label, required this.amount});

  final String label;
  final int amount;

  bool get isSpent => amount < 0;
}

/// 하루치 크레딧 내역 줄: 기본 > 세트 완료 > 세트 정답 80% > 광고(받은 횟수) > 랜덤 풀기 사용
/// 기본은 항상, 받지 않은 보너스·쓰지 않은 사용 줄은 빼고 보임 ([isToday] 면 기본 줄 이름이 `오늘 기본`)
List<CreditHistoryEntry> buildCreditHistoryEntries(
  CreditHistoryDayResponse day, {
  required bool isToday,
}) {
  return [
    CreditHistoryEntry(
      label: isToday ? '오늘 기본' : '기본',
      amount: day.baseCredits,
    ),
    if (day.dailySetCompletionCredits > 0)
      CreditHistoryEntry(
        label: '세트 완료',
        amount: day.dailySetCompletionCredits,
      ),
    if (day.dailySetAccuracyCredits > 0)
      CreditHistoryEntry(
        label: '세트 정답 80%',
        amount: day.dailySetAccuracyCredits,
      ),
    if (day.adBonusCredits > 0)
      CreditHistoryEntry(
        label: '광고 보기 ${day.adBonusCount}번',
        amount: day.adBonusCredits,
      ),
    if (day.usedCredits > 0)
      CreditHistoryEntry(
        label: '랜덤 풀기 ${day.usedCredits}문제',
        amount: -day.usedCredits,
      ),
  ];
}
