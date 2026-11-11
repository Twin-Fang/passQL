package com.passql.application.entitlement;

/**
 * 오늘 받은 무료 한도 보너스 (등급 응답에 그대로 실림)
 *
 * @param isDailySetCompletionEarned 오늘의 세트 완료 보너스 받음
 * @param isDailySetAccuracyEarned   오늘의 세트 정답률 보너스 받음
 * @param adBonusUsedCount           오늘 받은 광고 보너스 횟수
 * @param adBonusMaxCount            옛 앱 호환용, 항상 받은 횟수 + 1 (횟수 제한 없음)
 * @param bonusQuestionCount         보너스 1회분 문제 수
 */
public record DailyFreeBonus(
    boolean isDailySetCompletionEarned,
    boolean isDailySetAccuracyEarned,
    int adBonusUsedCount,
    int adBonusMaxCount,
    int bonusQuestionCount
) {

    /** 보너스 없음 (결제 꺼짐·프로, 광고 보너스 대상 아님 > 최대 횟수 0, #814) */
    public static DailyFreeBonus none() {
        return new DailyFreeBonus(false, false, 0, 0, DailyFreeBonusRule.BONUS_QUESTION_COUNT);
    }

    /** 받은 보너스 합계 (문제 수) */
    public int totalBonusQuestionCount() {
        int earnedCount = (isDailySetCompletionEarned ? 1 : 0) + (isDailySetAccuracyEarned ? 1 : 0) + adBonusUsedCount;
        return earnedCount * bonusQuestionCount;
    }
}
