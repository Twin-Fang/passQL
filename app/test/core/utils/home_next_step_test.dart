import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/utils/home_next_step.dart';

/// 홈 다음 할 일 판정 순서 (#975)
void main() {
  test('오늘의 세트를 풀 수 있으면 크레딧과 상관없이 세트가 먼저', () {
    expect(
      decideHomeNextStep(
        canSolveDailySet: true,
        isRandomPracticeVisible: true,
        remainingCredits: 0,
      ),
      HomeNextStep.dailySet,
    );
  });

  test('세트를 풀었고 크레딧이 남았거나 크레딧이 적용되지 않으면 랜덤 풀기', () {
    for (final remainingCredits in [3, null]) {
      expect(
        decideHomeNextStep(
          canSolveDailySet: false,
          isRandomPracticeVisible: true,
          remainingCredits: remainingCredits,
        ),
        HomeNextStep.randomPractice,
      );
    }
  });

  test('세트를 풀었고 크레딧이 0이면 크레딧 받기', () {
    expect(
      decideHomeNextStep(
        canSolveDailySet: false,
        isRandomPracticeVisible: true,
        remainingCredits: 0,
      ),
      HomeNextStep.earnCredits,
    );
  });

  test('랜덤 풀기 진입이 없으면 문제 탭', () {
    expect(
      decideHomeNextStep(
        canSolveDailySet: false,
        isRandomPracticeVisible: false,
        remainingCredits: null,
      ),
      HomeNextStep.browseQuestions,
    );
  });

  test('크레딧 0 이고 모의고사 무료 1회가 남았으면 모의고사', () {
    expect(
      decideHomeNextStep(
        canSolveDailySet: false,
        isRandomPracticeVisible: true,
        remainingCredits: 0,
        hasMockExamTrial: true,
      ),
      HomeNextStep.mockExamTrial,
    );
  });

  test('세트를 끝냈고 잠금화면을 권할 수 있으면 잠금화면 소개 (세트가 남았으면 세트 먼저, #990)', () {
    expect(
      decideHomeNextStep(
        canSolveDailySet: false,
        isRandomPracticeVisible: true,
        remainingCredits: 3,
        canSuggestLockScreen: true,
      ),
      HomeNextStep.lockScreen,
    );
    expect(
      decideHomeNextStep(
        canSolveDailySet: true,
        isRandomPracticeVisible: true,
        remainingCredits: 3,
        canSuggestLockScreen: true,
      ),
      HomeNextStep.dailySet,
    );
  });
}
