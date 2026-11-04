package com.passql.application.entitlement;

import java.util.OptionalInt;

/**
 * 무료 하루 한도 보너스 판정 3종 (#808): 세트 완료, 세트 정답률, 광고 시청
 * 판정 재료 > 받은 보너스 (저장·조회 없음, 재료는 DailyFreeBonusReader 가 모음)
 */
public final class DailyFreeBonusRule {

    // 보너스 1회분 (문제 수)
    public static final int BONUS_QUESTION_COUNT = 5;

    // 하루 광고 보너스 최대 횟수 (slot 1·2)
    public static final int AD_BONUS_MAX_COUNT_PER_DAY = 2;

    // 정답률 보너스 기준 (%, 맞힌 수 / 배정 수)
    public static final int ACCURACY_PERCENT_THRESHOLD = 80;

    private DailyFreeBonusRule() {
    }

    /** 재료 > 보너스: 완료(완료 기록 + 배정 전부 제출), 정답률(80% 이상), 광고(최대 2회로 자름) */
    public static DailyFreeBonus calculate(DailyFreeBonusInput input) {
        boolean hasAssignedQuestions = input.assignedQuestionCount() > 0;
        boolean isCompletionEarned = input.hasDailySetCompletion() && hasAssignedQuestions
            && input.submittedAssignedQuestionCount() >= input.assignedQuestionCount();
        boolean isAccuracyEarned = input.hasDailySetCompletion() && hasAssignedQuestions
            && input.dailySetCorrectCount() * 100 >= input.assignedQuestionCount() * ACCURACY_PERCENT_THRESHOLD;
        int adBonusUsedCount = Math.clamp(input.adBonusUsedCount(), 0, AD_BONUS_MAX_COUNT_PER_DAY);
        return new DailyFreeBonus(isCompletionEarned, isAccuracyEarned, adBonusUsedCount,
            AD_BONUS_MAX_COUNT_PER_DAY, BONUS_QUESTION_COUNT);
    }

    /** 다음 광고 보너스 칸 (1부터), 오늘 다 썼으면 empty */
    public static OptionalInt nextAdBonusSlot(int adBonusUsedCount) {
        return adBonusUsedCount < AD_BONUS_MAX_COUNT_PER_DAY
            ? OptionalInt.of(Math.max(adBonusUsedCount, 0) + 1)
            : OptionalInt.empty();
    }
}
