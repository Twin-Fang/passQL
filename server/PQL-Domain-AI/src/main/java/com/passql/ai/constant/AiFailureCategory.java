package com.passql.ai.constant;

import java.util.List;
import java.util.Locale;
import java.util.regex.Pattern;

/**
 * AI 호출 실패 원인 4종 (대시보드 24시간 실패 원인): ai_call_log.error_type 문자열 > 분류
 * 판정 순서: 한도 초과 > 권한·결제 > 시간 초과·서버 오류 > 기타
 */
public enum AiFailureCategory {

    // 요청·토큰 한도 초과 (429, RESOURCE_EXHAUSTED)
    QUOTA_EXCEEDED(List.of("GEMINI_QUOTA_EXCEEDED", "429", "QUOTA", "RESOURCE_EXHAUSTED")),
    // 키 무효·권한 없음·결제 문제 (401, 403)
    PERMISSION_DENIED(List.of("GEMINI_PERMISSION_DENIED", "401", "403", "PERMISSION")),
    // AI 서버 연결 실패·시간 초과·5xx
    TIMEOUT_OR_SERVER_ERROR(List.of("AI_SERVER_UNAVAILABLE", "AI_UNAVAILABLE", "TIMEOUT", "IOEXCEPTION",
            "RESOURCEACCESS", "SERVERERROR")),
    OTHER(List.of());

    // 상태 코드 5xx (앞뒤가 숫자가 아닌 3자리)
    private static final Pattern SERVER_ERROR_STATUS_PATTERN = Pattern.compile("(^|\\D)5\\d\\d(\\D|$)");

    // error_type 대문자 변환 후 포함 여부로 비교할 단어
    private final List<String> matchingKeywords;

    AiFailureCategory(List<String> matchingKeywords) {
        this.matchingKeywords = matchingKeywords;
    }

    /** error_type > 실패 원인 (null·빈 값·모르는 값은 OTHER) */
    public static AiFailureCategory fromErrorType(String errorType) {
        if (errorType == null || errorType.isBlank()) {
            return OTHER;
        }
        String normalizedErrorType = errorType.toUpperCase(Locale.ROOT);
        for (AiFailureCategory category : values()) {
            if (category.hasMatchingKeyword(normalizedErrorType)) {
                return category;
            }
        }
        return SERVER_ERROR_STATUS_PATTERN.matcher(normalizedErrorType).find() ? TIMEOUT_OR_SERVER_ERROR : OTHER;
    }

    private boolean hasMatchingKeyword(String normalizedErrorType) {
        return matchingKeywords.stream().anyMatch(normalizedErrorType::contains);
    }
}
