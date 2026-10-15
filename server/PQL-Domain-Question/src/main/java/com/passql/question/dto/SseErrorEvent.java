package com.passql.question.dto;

import com.passql.common.exception.constant.ErrorCode;

/**
 * SSE error 이벤트 본문: {errorCode, code, message, retryable}
 * code 는 출시 앱 호환용 사본 (errorCode 와 같은 값, 최소 지원 앱 버전이 errorCode 를 읽게 되면 제거)
 */
public record SseErrorEvent(
    String errorCode,
    String code,
    String message,
    boolean retryable
) {

    /** ErrorCode > error 이벤트 (errorCode·code 동일 값) */
    public static SseErrorEvent of(ErrorCode errorCode, String message, boolean retryable) {
        return new SseErrorEvent(errorCode.name(), errorCode.name(), message, retryable);
    }
}
