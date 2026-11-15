package com.passql.submission.constant;

/**
 * 회차 종류 2개: MOCK 자동 구성 모의고사, PAST_EXAM 기출 복원 회차(관리자가 50문항 순서 지정, #1079)
 * PAST_EXAM 의 roundNumber = 실제 시험 회차 번호 (예 62)
 */
public enum MockExamRoundType {
    MOCK,
    PAST_EXAM
}
