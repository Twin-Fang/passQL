import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/review/store_review_prompt_history.dart';
import 'package:passql_app/core/review/store_review_prompt_rule.dart';

/// 스토어 평가 요청 판정 (#864): 요청 가능 1개 + 거부 사유 6개, 학습한 날 세기
void main() {
  final now = DateTime(2026, 11, 7, 21);
  const appVersion = '1.83.0';

  // 조건을 모두 채운 기록: 첫 완료 5일 전, 학습한 날 3일, 완료 3회, 요청 기록 없음
  StoreReviewPromptHistory eligibleHistory({
    int studyDayCount = 3,
    int completedStudyCount = 3,
    DateTime? lastRequestedAt,
    String? lastRequestedAppVersion,
  }) => StoreReviewPromptHistory(
    firstStudyCompletedAtEpochMilliseconds: now
        .subtract(const Duration(days: 5))
        .millisecondsSinceEpoch,
    lastStudyCompletedAtEpochMilliseconds: now.millisecondsSinceEpoch,
    studyDayCount: studyDayCount,
    completedStudyCount: completedStudyCount,
    lastRequestedAtEpochMilliseconds: lastRequestedAt?.millisecondsSinceEpoch,
    lastRequestedAppVersion: lastRequestedAppVersion,
  );

  StoreReviewPromptDecision decide(
    StoreReviewPromptHistory history, {
    bool isGoodResult = true,
  }) => StoreReviewPromptRule.decide(
    history: history,
    now: now,
    appVersion: appVersion,
    isGoodResult: isGoodResult,
  );

  test('조건을 모두 채우면 요청 가능', () {
    expect(decide(eligibleHistory()), StoreReviewPromptDecision.eligible);
  });

  test('거부 사유 6개를 판정 순서대로 돌려준다', () {
    expect(
      decide(eligibleHistory(), isGoodResult: false),
      StoreReviewPromptDecision.notGoodResult,
    );
    expect(
      decide(
        StoreReviewPromptHistory(
          firstStudyCompletedAtEpochMilliseconds: DateTime(
            2026,
            11,
            7,
            8,
          ).millisecondsSinceEpoch,
          studyDayCount: 3,
          completedStudyCount: 3,
        ),
      ),
      StoreReviewPromptDecision.firstStudyDay,
    );
    expect(
      decide(eligibleHistory(studyDayCount: 2)),
      StoreReviewPromptDecision.tooFewStudyDays,
    );
    expect(
      decide(eligibleHistory(completedStudyCount: 2)),
      StoreReviewPromptDecision.tooFewCompletedStudies,
    );
    expect(
      decide(
        eligibleHistory(
          lastRequestedAt: now.subtract(const Duration(days: 200)),
          lastRequestedAppVersion: appVersion,
        ),
      ),
      StoreReviewPromptDecision.alreadyRequestedThisVersion,
    );
    expect(
      decide(
        eligibleHistory(
          lastRequestedAt: now.subtract(const Duration(days: 89)),
          lastRequestedAppVersion: '1.82.0',
        ),
      ),
      StoreReviewPromptDecision.requestedRecently,
    );
    expect(
      decide(
        eligibleHistory(
          lastRequestedAt: now.subtract(const Duration(days: 90)),
          lastRequestedAppVersion: '1.82.0',
        ),
      ),
      StoreReviewPromptDecision.eligible,
    );
  });

  test('오늘의 세트 좋은 결과는 정답률 60% 이상', () {
    expect(
      StoreReviewPromptRule.isGoodDailySetScore(
        correctCount: 3,
        questionCount: 5,
      ),
      isTrue,
    );
    expect(
      StoreReviewPromptRule.isGoodDailySetScore(
        correctCount: 2,
        questionCount: 5,
      ),
      isFalse,
    );
    expect(
      StoreReviewPromptRule.isGoodDailySetScore(
        correctCount: 0,
        questionCount: 0,
      ),
      isFalse,
    );
  });

  test('학습한 날은 현지 날짜가 바뀔 때만 늘고 완료 횟수는 매번 는다', () {
    final firstDay = DateTime(2026, 11, 5, 9);
    final history = const StoreReviewPromptHistory()
        .recordStudyCompletedAt(firstDay)
        .recordStudyCompletedAt(firstDay.add(const Duration(hours: 3)))
        .recordStudyCompletedAt(DateTime(2026, 11, 6, 0, 30));
    expect(history.studyDayCount, 2);
    expect(history.completedStudyCount, 3);
    expect(
      history.firstStudyCompletedAtEpochMilliseconds,
      firstDay.millisecondsSinceEpoch,
    );
  });
}
