package com.passql.question.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;

import java.util.Set;

/**
 * 선택지 세트 생성 재시도 규칙: 로그 접두사, 재시도 불가 에러 코드, 재시도 불가·일시 오류 로그
 * 생성 유형 3개(개념, SQL, 결과 비교)가 각자 하나씩 정의
 */
record ChoiceSetRetryRule(
        String logPrefix,
        Set<ErrorCode> nonRetryableErrorCodes,
        AttemptLogger<ErrorCode> nonRetryableLogger,
        AttemptLogger<CustomException> transientLogger) {

    /** 시도 1건 로그 (실행 상태, 원인, 시도 번호) */
    @FunctionalInterface
    interface AttemptLogger<T> {
        void log(ChoiceSetGenerationRun run, T cause, int attempt);
    }
}
