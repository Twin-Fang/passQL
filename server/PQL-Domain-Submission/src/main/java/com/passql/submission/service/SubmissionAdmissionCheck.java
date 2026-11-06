package com.passql.submission.service;

/**
 * 제출 기록 직전 확인: 기록 트랜잭션 안 첫 단계에서 실행, 막으면 CustomException (트랜잭션 롤백)
 * 하루 문제 수처럼 "이미 낸 수"로 판정하는 확인을 기록과 같은 트랜잭션에 묶기 위한 자리 (#867)
 */
@FunctionalInterface
public interface SubmissionAdmissionCheck {

    void checkWithinRecordTransaction();
}
