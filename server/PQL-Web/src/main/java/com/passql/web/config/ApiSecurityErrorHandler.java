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
 * API(JWT 체인) 인증 실패·접근 거부를 표준 {errorCode, message} 본문과 WARN 로그로 응답한다 (#406).
 * 이전에는 본문 없는 401만 내려가 클라이언트가 원인을 구분할 수 없고, 비인증 스캔도 로그에 남지 않았다.
 * 웹·앱은 상태 코드로만 분기하므로 본문 추가는 호환된다.
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
        write(response, ErrorCode.UNAUTHORIZED);
    }

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response,
                       AccessDeniedException e) throws IOException {
        log.warn("[auth] 접근 거부: {} {} ip={}", request.getMethod(), request.getRequestURI(), request.getRemoteAddr());
        write(response, ErrorCode.ACCESS_DENIED);
    }

    private void write(HttpServletResponse response, ErrorCode errorCode) throws IOException {
        response.setStatus(errorCode.getStatus().value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        objectMapper.writeValue(response.getWriter(), ErrorResponse.getResponse(errorCode));
    }
}
