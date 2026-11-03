package com.passql.application.entitlement;

/**
 * 보너스 판정 재료 (KST 오늘 기준)
 *
 * @param hasDailySetCompletion          오늘의 세트 완료 기록 있음 (daily_set_submission)
 * @param dailySetCorrectCount           완료 기록의 맞힌 수 (서버 채점, 문제별 오늘 첫 제출)
 * @param assignedQuestionCount          오늘 배정된 오늘의 세트 문제 수 (daily_challenge)
 * @param submittedAssignedQuestionCount 오늘 배정 문제 중 오늘 제출한 서로 다른 문제 수
 * @param adBonusUsedCount               오늘 받은 광고 보너스 횟수
 */
public record DailyFreeBonusInput(
    boolean hasDailySetCompletion,
    int dailySetCorrectCount,
    int assignedQuestionCount,
    int submittedAssignedQuestionCount,
    int adBonusUsedCount
) {
}
