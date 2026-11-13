package com.passql.application.entitlement;

/**
 * 무료 하루 한도 보너스 판정 3종 (#808): 세트 완료, 세트 정답률, 광고 시청(횟수 제한 없음, 공정 사용 상한은 FeatureAccessPolicy)
 * 판정 재료 > 받은 보너스 (저장·조회 없음, 재료는 DailyFreeBonusReader 가 모음)
 */
public final class DailyFreeBonusRule {

    // 보너스 1회분 (문제 수)
    public static final int BONUS_QUESTION_COUNT = 5;

    // 정답률 보너스 기준 (%, 맞힌 수 / 배정 수)
    public static final int ACCURACY_PERCENT_THRESHOLD = 80;

    private DailyFreeBonusRule() {
    }

    /** 재료 > 보너스: 완료(완료 기록 + 배정 전부 제출), 정답률(80% 이상), 광고(받은 횟수, 0 이상) */
    public static DailyFreeBonus calculate(DailyFreeBonusInput input) {
        boolean hasAssignedQuestions = input.assignedQuestionCount() > 0;
        boolean isCompletionEarned = input.hasDailySetCompletion() && hasAssignedQuestions
            && input.submittedAssignedQuestionCount() >= input.assignedQuestionCount();
        boolean isAccuracyEarned = input.hasDailySetCompletion() && hasAssignedQuestions
            && input.dailySetCorrectCount() * 100 >= input.assignedQuestionCount() * ACCURACY_PERCENT_THRESHOLD;
        int adBonusUsedCount = Math.max(input.adBonusUsedCount(), 0);
        // adBonusMaxCount: 옛 앱 호환용 (받은 횟수 + 1, 항상 더 받을 수 있음)
        return new DailyFreeBonus(isCompletionEarned, isAccuracyEarned, adBonusUsedCount,
            adBonusUsedCount + 1, BONUS_QUESTION_COUNT);
    }

    /** 다음 광고 보너스 칸 (1부터, 끝 없음) */
    public static int nextAdBonusSlot(int adBonusUsedCount) {
        return Math.max(adBonusUsedCount, 0) + 1;
    }
}
