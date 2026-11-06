import 'store_review_prompt_history.dart';

/// 평가 요청 판정 결과 7종: 요청 가능 1개 + 거부 사유 6개
enum StoreReviewPromptDecision {
  eligible,
  notGoodResult,
  firstStudyDay,
  tooFewStudyDays,
  tooFewCompletedStudies,
  alreadyRequestedThisVersion,
  requestedRecently,
}

/// 스토어 평가 요청 조건 (#864): 좋은 결과 + 첫날 아님 + 학습한 날 3일 + 완료 3회 + 버전당 1회 + 90일 간격
/// 기록 갱신(이번 완료 반영)이 끝난 기록으로 판정. 사전 질문·별점 거르기 없이 시스템 창만 (App Store 1.1.7·5.6.1)
abstract final class StoreReviewPromptRule {
  /// 최소 학습한 날 수 (기기 현지 날짜 기준 서로 다른 날)
  static const int minimumStudyDayCount = 3;

  /// 최소 학습 완료 횟수 (오늘의 세트·모의고사 합산)
  static const int minimumCompletedStudyCount = 3;

  /// 이전 요청 뒤 다시 묻지 않는 기간 (90일)
  static const Duration requestCooldown = Duration(days: 90);

  /// 오늘의 세트 좋은 결과 기준 정답률 (60% 이상)
  static const double goodDailySetCorrectRatio = 0.6;

  /// 오늘의 세트 점수가 좋은 결과인지 (문항 없음 > 아님)
  static bool isGoodDailySetScore({
    required int correctCount,
    required int questionCount,
  }) {
    if (questionCount <= 0) return false;
    return correctCount / questionCount >= goodDailySetCorrectRatio;
  }

  /// 판정 순서: 결과 > 첫날 > 학습한 날 > 완료 횟수 > 같은 버전 > 90일 간격
  static StoreReviewPromptDecision decide({
    required StoreReviewPromptHistory history,
    required DateTime now,
    required String appVersion,
    required bool isGoodResult,
  }) {
    if (!isGoodResult) return StoreReviewPromptDecision.notGoodResult;
    final firstCompletedAt = history.firstStudyCompletedAtEpochMilliseconds;
    if (firstCompletedAt == null ||
        StoreReviewPromptHistory.isSameLocalDay(
          DateTime.fromMillisecondsSinceEpoch(firstCompletedAt),
          now,
        )) {
      return StoreReviewPromptDecision.firstStudyDay;
    }
    if (history.studyDayCount < minimumStudyDayCount) {
      return StoreReviewPromptDecision.tooFewStudyDays;
    }
    if (history.completedStudyCount < minimumCompletedStudyCount) {
      return StoreReviewPromptDecision.tooFewCompletedStudies;
    }
    if (history.lastRequestedAppVersion == appVersion) {
      return StoreReviewPromptDecision.alreadyRequestedThisVersion;
    }
    final lastRequestedAt = history.lastRequestedAtEpochMilliseconds;
    if (lastRequestedAt != null) {
      final elapsed = now.difference(
        DateTime.fromMillisecondsSinceEpoch(lastRequestedAt),
      );
      // 기기 시각을 되돌린 경우(음수)도 간격 미달로 봄
      if (elapsed < requestCooldown) {
        return StoreReviewPromptDecision.requestedRecently;
      }
    }
    return StoreReviewPromptDecision.eligible;
  }
}
