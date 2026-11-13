import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/presentation/flows/random_practice_flow.dart';
import 'package:passql_app/presentation/widgets/practice/random_practice_row.dart';

/// 랜덤 풀기 행 부제 (홈·문제 탭 공용, #993): 크레딧 0일 때만 받는 방법 안내
void main() {
  test('크레딧이 남았거나 적용되지 않으면 흐름 설명', () {
    expect(
      randomPracticeSubtitleOf(remainingCredits: 3, dailyBonus: null),
      RandomPracticeFlow.summary,
    );
    expect(
      randomPracticeSubtitleOf(remainingCredits: null, dailyBonus: null),
      RandomPracticeFlow.summary,
    );
  });

  test('크레딧 0: 세트 완료 보너스를 받았으면 광고만 안내', () {
    final canEarnFromDailySet = randomPracticeSubtitleOf(
      remainingCredits: 0,
      dailyBonus: const DailyFreeBonus(),
    );
    final adOnly = randomPracticeSubtitleOf(
      remainingCredits: 0,
      dailyBonus: const DailyFreeBonus(isDailySetCompletionEarned: true),
    );
    expect(canEarnFromDailySet, contains('오늘의 세트'));
    expect(adOnly, isNot(contains('오늘의 세트')));
  });
}
