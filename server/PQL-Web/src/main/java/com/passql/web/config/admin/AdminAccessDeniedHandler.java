package com.passql.web.config.admin;

import com.passql.common.exception.constant.ErrorCode;
import com.passql.web.config.ApiSecurityErrorHandler;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

/**
 * 관리자 권한 부족(조회 전용 계정의 변경 요청 등): fetch·변경 요청 > 403 ADMIN_WRITE_FORBIDDEN 본문, 화면 이동 > 403 오류 화면
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AdminAccessDeniedHandler implements AccessDeniedHandler {

    // admin-fetch.js 가 붙이는 요청 표시 헤더
    private static final String REQUESTED_WITH_HEADER = "X-Requested-With";

    private final ApiSecurityErrorHandler apiSecurityErrorHandler;

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response,
                       AccessDeniedException exception) throws IOException {
        log.warn("[admin auth] access denied 403 : {} {}", request.getMethod(), request.getRequestURI());
        if (isApiStyleRequest(request)) {
            apiSecurityErrorHandler.writeErrorResponse(response, ErrorCode.ADMIN_WRITE_FORBIDDEN);
            return;
        }
        response.sendError(HttpStatus.FORBIDDEN.value());
    }

    private boolean isApiStyleRequest(HttpServletRequest request) {
        String accept = request.getHeader("Accept");
        return !HttpMethod.GET.matches(request.getMethod())
                || request.getHeader(REQUESTED_WITH_HEADER) != null
                || (accept != null && accept.contains(MediaType.APPLICATION_JSON_VALUE));
    }
}
