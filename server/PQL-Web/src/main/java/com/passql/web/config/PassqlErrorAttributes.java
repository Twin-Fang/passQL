package com.passql.web.config;

import com.passql.common.exception.constant.ErrorCode;
import org.springframework.boot.web.error.ErrorAttributeOptions;
import org.springframework.boot.web.servlet.error.DefaultErrorAttributes;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import java.util.Map;

/**
 * 컨트롤러 밖에서 난 오류(없는 경로 404, CSRF 403 등)의 /error 응답에도 errorCode·message를 넣는다 (#406).
 * GlobalExceptionHandler는 com.passql 컨트롤러 예외만 잡아, 이 경로는 Spring 기본 {timestamp,status,error,path}였다.
 * status·path는 남긴다 — 관리자 오류 화면(error.html)이 쓴다.
 */
@Component
public class PassqlErrorAttributes extends DefaultErrorAttributes {

    @Override
    public Map<String, Object> getErrorAttributes(WebRequest webRequest, ErrorAttributeOptions options) {
        Map<String, Object> attrs = super.getErrorAttributes(webRequest, options);
        ErrorCode code = toErrorCode((Integer) attrs.get("status"));
        attrs.put("errorCode", code.name());
        attrs.put("message", code.getMessage());
        // 기본 필드 중 클라이언트에 의미 없는 것은 뺀다
        attrs.remove("timestamp");
        attrs.remove("error");
        return attrs;
    }

    private ErrorCode toErrorCode(Integer status) {
        if (status == null) return ErrorCode.INTERNAL_SERVER_ERROR;
        return switch (HttpStatus.valueOf(status)) {
            case UNAUTHORIZED -> ErrorCode.UNAUTHORIZED;
            case FORBIDDEN -> ErrorCode.ACCESS_DENIED;
            case NOT_FOUND -> ErrorCode.RESOURCE_NOT_FOUND;
            case METHOD_NOT_ALLOWED -> ErrorCode.METHOD_NOT_ALLOWED;
            case UNSUPPORTED_MEDIA_TYPE -> ErrorCode.UNSUPPORTED_MEDIA_TYPE;
            default -> status >= 500 ? ErrorCode.INTERNAL_SERVER_ERROR : ErrorCode.INVALID_REQUEST;
        };
    }
}
