package com.passql.web.config;

import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.web.support.FixedWindowRateLimiter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Clock;
import java.time.Duration;
import java.util.Arrays;

/**
 * 회원 API 요청 제한 공통 지점: MemberApiRateLimitRule 경로 > 한도 초과 시 429 RATE_LIMITED
 * JWT 인증 직후 실행 (회원 기준 규칙이 회원 UUID 를 읽음)
 */
@Slf4j
public class MemberApiRateLimitFilter extends OncePerRequestFilter {

    private final FixedWindowRateLimiter rateLimiter;
    private final ApiSecurityErrorHandler apiSecurityErrorHandler;

    public MemberApiRateLimitFilter(ApiSecurityErrorHandler apiSecurityErrorHandler, Clock clock) {
        this.apiSecurityErrorHandler = apiSecurityErrorHandler;
        int longestWindowSeconds = Arrays.stream(MemberApiRateLimitRule.values())
                .mapToInt(MemberApiRateLimitRule::getWindowSeconds).max().orElse(60);
        this.rateLimiter = new FixedWindowRateLimiter(Duration.ofSeconds(longestWindowSeconds), clock);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String path = request.getRequestURI().substring(request.getContextPath().length());
        MemberApiRateLimitRule rule = MemberApiRateLimitRule.findMatchingRule(request.getMethod(), path);
        if (rule != null && !rateLimiter.tryAcquire(toRateLimitKey(rule, request), rule.getMaxRequestsPerWindow(), rule.getWindowSeconds())) {
            log.warn("[rate limit] rejected 429 : rule={}, {} {}", rule, request.getMethod(), path);
            apiSecurityErrorHandler.writeErrorResponse(response, ErrorCode.RATE_LIMITED);
            return;
        }
        filterChain.doFilter(request, response);
    }

    /** 규칙 기준 > 키 (회원 기준인데 토큰 없으면 IP) */
    private String toRateLimitKey(MemberApiRateLimitRule rule, HttpServletRequest request) {
        if (!rule.isKeyedByClientIp()) {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && authentication.getPrincipal() instanceof LoginMember loginMember) {
                return rule.name() + ":member:" + loginMember.memberUuid();
            }
        }
        return rule.name() + ":ip:" + request.getRemoteAddr();
    }
}
