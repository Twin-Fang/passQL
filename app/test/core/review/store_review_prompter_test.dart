import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/monitoring/app_analytics.dart';
import 'package:passql_app/core/review/store_review_prompt_history.dart';
import 'package:passql_app/core/review/store_review_prompter.dart';

/// 스토어 평가 요청 대기 (#1027): 보상 연출 창이 결과 화면을 덮어도 닫힌 뒤 요청, 떠났으면 요청 안 함
void main() {
  final now = DateTime(2026, 11, 12, 21);

  // 이번 완료로 조건을 채우는 기록: 첫 완료 5일 전, 학습한 날 3일, 완료 2회
  StoreReviewPrompter prompterWith(_FakeRequester requester) =>
      StoreReviewPrompter(
        historyStore: _MemoryHistoryStore(
          StoreReviewPromptHistory(
            firstStudyCompletedAtEpochMilliseconds: now
                .subtract(const Duration(days: 5))
                .millisecondsSinceEpoch,
            lastStudyCompletedAtEpochMilliseconds: now
                .subtract(const Duration(days: 1))
                .millisecondsSinceEpoch,
            studyDayCount: 2,
            completedStudyCount: 2,
          ),
        ),
        requester: requester,
        readAppVersion: () async => '1.112.0',
        analytics: const AppAnalytics(NoopAnalyticsBackend()),
        now: () => now,
      );

  testWidgets('결과 화면을 덮은 창이 닫힌 뒤 평가 창 요청', (tester) async {
    final requester = _FakeRequester();
    var isResultVisible = false;
    final request = prompterWith(requester)
        .recordStudyCompletedAndRequestIfEligible(
          trigger: StoreReviewTrigger.dailySet,
          isGoodResult: true,
          isResultStillVisible: () => isResultVisible,
        );
    await tester.pump(const Duration(seconds: 10));
    expect(requester.requestCount, 0);

    // 보상 연출 창 닫힘 > 다시 읽을 시간 뒤 요청
    isResultVisible = true;
    await tester.pump(const Duration(seconds: 4));
    await request;
    expect(requester.requestCount, 1);
  });

  testWidgets('결과 화면을 떠났으면 최대 대기 뒤 요청하지 않음', (tester) async {
    final requester = _FakeRequester();
    final request = prompterWith(requester)
        .recordStudyCompletedAndRequestIfEligible(
          trigger: StoreReviewTrigger.mockExam,
          isGoodResult: true,
          isResultStillVisible: () => false,
        );
    await tester.pump(const Duration(minutes: 2));
    await request;
    expect(requester.requestCount, 0);
  });
}

class _FakeRequester implements StoreReviewRequester {
  int requestCount = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> requestReview() async => requestCount++;
}

class _MemoryHistoryStore implements StoreReviewPromptHistoryStore {
  _MemoryHistoryStore(this._history);

  StoreReviewPromptHistory _history;

  @override
  Future<StoreReviewPromptHistory> read() async => _history;

  @override
  Future<void> write(StoreReviewPromptHistory history) async =>
      _history = history;
}
