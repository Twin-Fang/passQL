package com.passql.common.exception;

import com.passql.common.exception.constant.ErrorCode;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * API 에러 응답 표준 형식: {errorCode, message}
 * 생성은 ErrorCode 기반 정적 팩토리만 허용 (문자열 코드 직접 지정 불가)
 */
@Getter
@NoArgsConstructor
@AllArgsConstructor(access = AccessLevel.PRIVATE)
public class ErrorResponse {

    private String errorCode;
    private String message;

    /** ErrorCode > 기본 메시지 응답 */
    public static ErrorResponse of(ErrorCode errorCode) {
        return new ErrorResponse(errorCode.name(), errorCode.getMessage());
    }

    /** ErrorCode + 상황별 메시지 (검증 실패 필드, 파라미터 이름 등) */
    public static ErrorResponse of(ErrorCode errorCode, String message) {
        return new ErrorResponse(errorCode.name(), message);
    }
}
