package com.passql.web.config;

import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.member.service.MemberSuspensionService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpMethod;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

/**
 * 제재 회원 차단 공통 지점: JWT 인증된 회원 API 요청 > 제재 효력 중이면 403 MEMBER_SUSPENDED
 * 예외 경로 4종: 인증(로그인·재발급·로그아웃), 공개 meta, actuator, 탈퇴(DELETE /api/members/me)
 */
@Slf4j
@RequiredArgsConstructor
public class SuspendedMemberBlockingFilter extends OncePerRequestFilter {

    // 제재 중에도 허용: 인증 흐름(앱이 재발급 후 getMe 403 으로 제재 안내), 공개 API, 헬스체크
    private static final List<String> SUSPENSION_EXEMPT_PATH_PREFIXES = List.of("/api/auth/", "/api/meta/", "/actuator/");
    // 탈퇴: 제재 중에도 개인정보 삭제 요청권 보장
    private static final String WITHDRAW_PATH = "/api/members/me";

    private final MemberSuspensionService memberSuspensionService;
    private final ApiSecurityErrorHandler apiSecurityErrorHandler;

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI().substring(request.getContextPath().length());
        boolean isWithdrawRequest = HttpMethod.DELETE.matches(request.getMethod()) && WITHDRAW_PATH.equals(path);
        return isWithdrawRequest || SUSPENSION_EXEMPT_PATH_PREFIXES.stream().anyMatch(path::startsWith);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof LoginMember loginMember
                && memberSuspensionService.isMemberBlockedBySuspension(loginMember.memberUuid())) {
            log.warn("[member suspension] blocked 403 : {} {}", request.getMethod(), request.getRequestURI());
            apiSecurityErrorHandler.writeErrorResponse(response, ErrorCode.MEMBER_SUSPENDED);
            return;
        }
        filterChain.doFilter(request, response);
    }
}
