package com.passql.web.support;

import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.member.service.MemberActivityRecorder;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * 회원 활동 기록 공통 지점 (#557): JWT 인증된 /api/** 요청 > MemberActivityRecorder (관리자 /admin 은 등록 경로 밖)
 * 기록 실패는 로그만 (요청 흐름에 영향 금지)
 */
@Slf4j
@RequiredArgsConstructor
public class MemberActivityInterceptor implements HandlerInterceptor {

    private final MemberActivityRecorder memberActivityRecorder;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && authentication.getPrincipal() instanceof LoginMember loginMember) {
                memberActivityRecorder.recordActivity(loginMember.memberUuid());
            }
        } catch (Exception e) {
            log.warn("[member activity] record skipped : {}", e.getClass().getSimpleName());
        }
        return true;
    }
}
