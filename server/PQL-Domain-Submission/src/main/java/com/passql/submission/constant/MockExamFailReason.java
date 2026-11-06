package com.passql.submission.constant;

/**
 * 불합격 이유 3개: NONE 합격, SUBJECT_FAIL 과락(총점과 무관하게 우선), TOTAL_SCORE_BELOW 총점 60점 미만
 */
public enum MockExamFailReason {
    NONE,
    SUBJECT_FAIL,
    TOTAL_SCORE_BELOW
}
