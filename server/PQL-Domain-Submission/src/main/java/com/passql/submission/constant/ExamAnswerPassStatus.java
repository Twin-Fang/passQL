package com.passql.submission.constant;

/**
 * 가채점 합격 판정 3개: PASS 최저 점수로도 합격, FAIL 최고 점수로도 불합격, BORDERLINE 점수 범위가 합격선·과락선에 걸침
 */
public enum ExamAnswerPassStatus {
    PASS,
    FAIL,
    BORDERLINE
}
