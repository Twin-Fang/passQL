package com.passql.web.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.List;

/**
 * 지표 수집기 토큰 검사: Authorization Bearer <-> passql.metrics.scrape-token 상수 시간 비교 (#957)
 * 일치 > METRICS_SCRAPER 권한 인증, 불일치·헤더 없음·설정 토큰 비어 있음 > 본문 없는 401
 */
@Slf4j
public class PrometheusScrapeTokenFilter extends OncePerRequestFilter {

    // 수집 체인(MetricsScrapeSecurityConfig)이 요구하는 권한
    public static final String METRICS_SCRAPER_AUTHORITY = "METRICS_SCRAPER";
    // SecurityContext 주체 이름 (회원·관리자와 구분)
    private static final String METRICS_SCRAPER_PRINCIPAL = "metrics-scraper";
    private static final String BEARER_PREFIX = "Bearer ";

    // 설정 토큰 바이트 (빈 배열이면 전부 거부)
    private final byte[] configuredScrapeTokenBytes;

    public PrometheusScrapeTokenFilter(String configuredScrapeToken) {
        String trimmedScrapeToken = configuredScrapeToken == null ? "" : configuredScrapeToken.trim();
        this.configuredScrapeTokenBytes = trimmedScrapeToken.getBytes(StandardCharsets.UTF_8);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        if (!isScrapeTokenMatched(request.getHeader(HttpHeaders.AUTHORIZATION))) {
            // 토큰 유무·설정 여부를 응답으로 드러내지 않음 (본문 없음)
            log.warn("[metrics scrape] rejected 401 : {} {} ip={}",
                    request.getMethod(), request.getRequestURI(), request.getRemoteAddr());
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        SecurityContext securityContext = SecurityContextHolder.createEmptyContext();
        securityContext.setAuthentication(UsernamePasswordAuthenticationToken.authenticated(
                METRICS_SCRAPER_PRINCIPAL, null, List.of(new SimpleGrantedAuthority(METRICS_SCRAPER_AUTHORITY))));
        SecurityContextHolder.setContext(securityContext);
        filterChain.doFilter(request, response);
    }

    /** Authorization 헤더 값이 설정 토큰과 같으면 true (설정 토큰 비면 항상 false) */
    boolean isScrapeTokenMatched(String authorizationHeader) {
        if (configuredScrapeTokenBytes.length == 0
                || authorizationHeader == null
                || !authorizationHeader.startsWith(BEARER_PREFIX)) {
            return false;
        }
        byte[] presentedScrapeTokenBytes = authorizationHeader.substring(BEARER_PREFIX.length())
                .trim().getBytes(StandardCharsets.UTF_8);
        // 상수 시간 비교 (응답 시간으로 토큰 앞부분 추측 방지)
        return MessageDigest.isEqual(configuredScrapeTokenBytes, presentedScrapeTokenBytes);
    }
}
