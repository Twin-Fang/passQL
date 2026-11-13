import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/member/credit_history_response.dart';
import 'package:passql_app/presentation/widgets/account/credit_history_entry.dart';

/// 크레딧 내역 줄 핵심: 받은 줄 합 - 쓴 줄 = 남은 크레딧, 받지 않은 보너스는 줄이 없음 (#971, #974)
void main() {
  test('기본·세트 완료·광고 2번·사용 8문제면 받은 합 25, 쓴 것 -8', () {
    final day = CreditHistoryDayResponse(
      date: DateTime(2026, 11, 12),
      baseCredits: 10,
      dailySetCompletionCredits: 5,
      adBonusCount: 2,
      adBonusCredits: 10,
      usedCredits: 8,
      remainingCredits: 17,
    );
    final entries = buildCreditHistoryEntries(day, isToday: true);
    expect(entries.map((entry) => entry.amount), [10, 5, 10, -8]);
    expect(
      entries.fold<int>(0, (sum, entry) => sum + entry.amount),
      day.remainingCredits,
    );
  });

  test('받은 보너스도 쓴 것도 없으면 기본 한 줄만, 이름은 오늘이면 오늘 기본·지난 날짜면 기본', () {
    final day = CreditHistoryDayResponse(
      date: DateTime(2026, 11, 12),
      baseCredits: 10,
      remainingCredits: 10,
    );
    final todayEntry = buildCreditHistoryEntries(day, isToday: true).single;
    final pastEntry = buildCreditHistoryEntries(day, isToday: false).single;
    expect(todayEntry.amount, 10);
    expect(todayEntry.label, '오늘 기본');
    expect(pastEntry.label, '기본');
  });
}
