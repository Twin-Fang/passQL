package com.passql.web.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.common.exception.ErrorResponse;
import com.passql.common.exception.constant.ErrorCode;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

/**
 * API(JWT 체인) 인증 실패·접근 거부 > 표준 {errorCode, message} 본문 + WARN 로그 (#406)
 * 본문으로 클라이언트 원인 구분, 로그로 비인증 스캔 추적 (웹·앱은 상태 코드로만 분기해 본문 추가 호환)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ApiSecurityErrorHandler implements AuthenticationEntryPoint, AccessDeniedHandler {

    private final ObjectMapper objectMapper;

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response,
                         AuthenticationException e) throws IOException {
        log.warn("[auth] 인증 실패: {} {} ip={}", request.getMethod(), request.getRequestURI(), request.getRemoteAddr());
        writeErrorResponse(response, ErrorCode.UNAUTHORIZED);
    }

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response,
                       AccessDeniedException e) throws IOException {
        log.warn("[auth] 접근 거부: {} {} ip={}", request.getMethod(), request.getRequestURI(), request.getRemoteAddr());
        writeErrorResponse(response, ErrorCode.ACCESS_DENIED);
    }

    /** ErrorCode > 표준 오류 본문 응답 (API 체인 필터 공통) */
    public void writeErrorResponse(HttpServletResponse response, ErrorCode errorCode) throws IOException {
        response.setStatus(errorCode.getStatus().value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        objectMapper.writeValue(response.getWriter(), ErrorResponse.of(errorCode));
    }
}
