package com.passql.common.util;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.Optional;

/**
 * 현재 요청의 관리자 정보: 관리자 세션 아이디, 클라이언트 IP
 * 관리자 세션 principal = UserDetails (회원 JWT principal 은 LoginMember 라 제외)
 */
public final class AdminRequestContext {

    // 관리자 세션 밖 변경(회원 API·스케줄러)의 처리 주체
    public static final String SYSTEM_ACTOR = "system";

    private AdminRequestContext() {
    }

    /** 관리자 아이디, 관리자 세션 밖이면 system */
    public static String findAdminUsernameOrSystem() {
        return findAdminUsername().orElse(SYSTEM_ACTOR);
    }

    /** 관리자 세션 요청이면 관리자 아이디 */
    public static Optional<String> findAdminUsername() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof UserDetails adminUser) {
            return Optional.of(adminUser.getUsername());
        }
        return Optional.empty();
    }

    /** 요청 스레드면 클라이언트 IP (forward-headers 반영값) */
    public static Optional<String> findClientIp() {
        RequestAttributes requestAttributes = RequestContextHolder.getRequestAttributes();
        if (requestAttributes instanceof ServletRequestAttributes servletRequestAttributes) {
            HttpServletRequest request = servletRequestAttributes.getRequest();
            return Optional.ofNullable(request.getRemoteAddr());
        }
        return Optional.empty();
    }
}
