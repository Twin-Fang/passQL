import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/presentation/widgets/profile/credit_today_history.dart';

/// 오늘 크레딧 내역 핵심: 받은 줄 합 - 쓴 줄 = 남은 크레딧, 받지 않은 보너스는 줄이 없음 (#971)
void main() {
  test('기본·세트 완료·광고 2번·사용 8문제면 받은 합 25, 쓴 것 -8', () {
    const plan = MemberPlanResponse(
      dailyFreeLimit: 10,
      todayFreeLimit: 25,
      todayRandomSolvedCount: 8,
      dailyBonus: DailyFreeBonus(
        isDailySetCompletionEarned: true,
        adBonusUsedCount: 2,
        bonusQuestionCount: 5,
      ),
    );
    final entries = buildTodayCreditHistory(plan);
    expect(entries.map((entry) => entry.amount), [10, 5, 10, -8]);
    expect(entries.fold<int>(0, (sum, entry) => sum + entry.amount), 17);
  });

  test('받은 보너스도 쓴 것도 없으면 기본 한 줄만', () {
    const plan = MemberPlanResponse(dailyFreeLimit: 10, todayFreeLimit: 10);
    final entries = buildTodayCreditHistory(plan);
    expect(entries.single.amount, 10);
  });
}
