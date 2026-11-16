package com.passql.submission.constant;

/**
 * 회차 종류 3개: MOCK 자동 구성 모의고사, PAST_EXAM 기출 복원 회차(#1079), FINAL 시험 직전 회차(#1084)
 * PAST_EXAM 의 roundNumber = 실제 시험 회차 번호 (예 62), FINAL 의 roundNumber = FINAL 순번, examDate = 대상 시험일
 */
public enum MockExamRoundType {
    MOCK,
    PAST_EXAM,
    FINAL
}
