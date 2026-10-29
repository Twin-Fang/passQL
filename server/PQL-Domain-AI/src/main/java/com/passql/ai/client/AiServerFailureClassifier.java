package com.passql.ai.client;

import com.fasterxml.jackson.core.JacksonException;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.ResourceAccessException;

import java.net.SocketTimeoutException;

/**
 * AI 서버 호출 실패 > ai_call_log.error_type 세부 원인 (#575)
 * 원인 4종: HTTP 상태 코드, 시간 초과, 연결 실패, 응답 파싱 실패 (그 외 null > 호출부 기본값)
 */
final class AiServerFailureClassifier {

    // 응답 상태 코드 > AI_SERVER_HTTP_{코드} (예: AI_SERVER_HTTP_422)
    static final String HTTP_STATUS_PREFIX = "AI_SERVER_HTTP_";
    static final String TIMEOUT = "AI_SERVER_TIMEOUT";
    static final String CONNECTION_FAILED = "AI_SERVER_CONNECTION_FAILED";
    static final String RESPONSE_PARSE_FAILED = "AI_SERVER_RESPONSE_PARSE_FAILED";

    private AiServerFailureClassifier() {
    }

    /** 예외 원인 사슬 > 세부 원인 (판정 순서: 상태 코드 > 시간 초과 > 연결 실패 > 파싱 실패, 모르면 null) */
    static String toFailureType(Throwable throwable) {
        for (Throwable cause = throwable; cause != null; cause = cause.getCause()) {
            if (cause instanceof HttpStatusCodeException statusException) {
                return HTTP_STATUS_PREFIX + statusException.getStatusCode().value();
            }
            if (cause instanceof SocketTimeoutException) {
                return TIMEOUT;
            }
            if (cause instanceof ResourceAccessException) {
                return hasTimeoutCause(cause) ? TIMEOUT : CONNECTION_FAILED;
            }
            if (cause instanceof JacksonException) {
                return RESPONSE_PARSE_FAILED;
            }
            if (cause.getCause() == cause) break;
        }
        return null;
    }

    private static boolean hasTimeoutCause(Throwable throwable) {
        for (Throwable cause = throwable.getCause(); cause != null; cause = cause.getCause()) {
            if (cause instanceof SocketTimeoutException) return true;
            if (cause.getCause() == cause) break;
        }
        return false;
    }
}
