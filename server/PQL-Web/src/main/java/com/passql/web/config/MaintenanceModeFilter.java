package com.passql.web.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.common.exception.ErrorResponse;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.service.AppOperationService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * 점검 중 회원 API 차단: /api 요청 > 503 SERVICE_UNDER_MAINTENANCE (#464)
 * 통과 경로 2개: /api/meta (앱 시작 설정·약관), /api/auth (토큰 재발급 실패로 로그아웃되지 않게)
 * API 보안 체인 CORS 필터 뒤에 등록 (웹이 503 을 CORS 오류가 아닌 응답으로 받게) — SecurityConfig
 */
@Slf4j
@RequiredArgsConstructor
public class MaintenanceModeFilter extends OncePerRequestFilter {

    // 점검 중에도 통과시키는 경로 접두사
    private static final List<String> MAINTENANCE_BYPASS_PATH_PREFIXES = List.of("/api/meta/", "/api/auth/");
    private static final String API_PATH_PREFIX = "/api/";

    private final AppOperationService appOperationService;
    private final ObjectMapper objectMapper;

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI().substring(request.getContextPath().length());
        return !path.startsWith(API_PATH_PREFIX) || isMaintenanceBypassPath(path);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        if (!appOperationService.isUnderMaintenance()) {
            filterChain.doFilter(request, response);
            return;
        }
        log.info("[maintenance] rejected 503 : {} {}", request.getMethod(), request.getRequestURI());
        ErrorCode errorCode = ErrorCode.SERVICE_UNDER_MAINTENANCE;
        response.setStatus(errorCode.getStatus().value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        objectMapper.writeValue(response.getWriter(), ErrorResponse.of(errorCode));
    }

    /** 점검 중 통과 경로면 true */
    static boolean isMaintenanceBypassPath(String path) {
        return MAINTENANCE_BYPASS_PATH_PREFIXES.stream().anyMatch(path::startsWith);
    }
}
