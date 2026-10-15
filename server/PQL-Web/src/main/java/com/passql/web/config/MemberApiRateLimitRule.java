package com.passql.web.config;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpMethod;
import org.springframework.util.AntPathMatcher;

/**
 * 회원 API 요청 제한 규칙 (비싼 경로 위주): 경로 > 창(초)당 최대 요청 수, 기준(IP 또는 회원)
 * 로그인은 IP 기준(미인증), 그 외 회원 기준(토큰 없으면 IP)
 */
@Getter
@RequiredArgsConstructor
public enum MemberApiRateLimitRule {

    // 소셜 로그인 (IP 당 분당 20회, 토큰 교환·외부 검증 호출)
    LOGIN(HttpMethod.POST, "/api/auth/login", 20, 60, true),
    // 토큰 재발급 (IP 당 분당 60회)
    TOKEN_REISSUE(HttpMethod.POST, "/api/auth/reissue", 60, 60, true),
    // AI 선택지 생성 SSE (회원당 분당 30회)
    CHOICE_GENERATION(HttpMethod.POST, "/api/questions/*/generate-choices", 30, 60, false),
    // AI 오류 해설·차이 해설 (회원당 분당 20회)
    AI_EXPLANATION(HttpMethod.POST, "/api/ai/**", 20, 60, false),
    // 샌드박스 SQL 실행 (회원당 분당 60회)
    SQL_EXECUTION(HttpMethod.POST, "/api/questions/*/execute", 60, 60, false);

    private static final AntPathMatcher PATH_MATCHER = new AntPathMatcher();

    private final HttpMethod method;
    private final String pathPattern;
    private final int maxRequestsPerWindow;
    private final int windowSeconds;
    // true: 클라이언트 IP 기준, false: 회원 기준
    private final boolean isKeyedByClientIp;

    public boolean matches(String requestMethod, String path) {
        return method.matches(requestMethod) && PATH_MATCHER.match(pathPattern, path);
    }

    /** 요청 > 첫 번째로 맞는 규칙 (없으면 null) */
    public static MemberApiRateLimitRule findMatchingRule(String requestMethod, String path) {
        for (MemberApiRateLimitRule rule : values()) {
            if (rule.matches(requestMethod, path)) {
                return rule;
            }
        }
        return null;
    }
}
