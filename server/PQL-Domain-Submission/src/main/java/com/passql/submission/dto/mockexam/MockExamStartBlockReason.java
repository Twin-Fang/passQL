package com.passql.submission.dto.mockexam;

/**
 * 회차 시작 불가 이유 3개: PRO_REQUIRED 무료 체험 회차 아님, FREE_TRIAL_USED 무료 체험 소진, OTHER_ATTEMPT_IN_PROGRESS 다른 회차 풀이 중
 */
public enum MockExamStartBlockReason {
    PRO_REQUIRED,
    FREE_TRIAL_USED,
    OTHER_ATTEMPT_IN_PROGRESS
}
