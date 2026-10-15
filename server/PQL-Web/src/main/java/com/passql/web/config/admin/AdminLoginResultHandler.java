package com.passql.web.config.admin;

import com.passql.meta.service.AdminAccountService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

/**
 * 관리자 로그인 결과 처리: 성공 > 실패 수 초기화·마지막 로그인 기록, 실패 > 실패 수 증가(5회째 15분 잠금)
 * 실패 사유 3종을 로그인 화면 error 파라미터로: locked 잠김, disabled 사용 중지, true 아이디·비밀번호 불일치
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AdminLoginResultHandler implements AuthenticationSuccessHandler, AuthenticationFailureHandler {

    // 로그인 폼 아이디 파라미터 (AdminSecurityConfig usernameParameter 와 같은 값)
    public static final String USERNAME_PARAMETER = "username";
    // 로그인 화면 error 파라미터 값
    public static final String LOGIN_ERROR_LOCKED = "locked";
    public static final String LOGIN_ERROR_DISABLED = "disabled";
    private static final String LOGIN_ERROR_BAD_CREDENTIALS = "true";
    private static final String ADMIN_HOME_PATH = "/admin";
    private static final String LOGIN_PAGE_PATH = "/admin/login?error=";

    private final AdminAccountService adminAccountService;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) throws IOException {
        adminAccountService.recordLoginSuccess(authentication.getName(), request.getRemoteAddr());
        log.info("[admin auth] login success : ip={}", request.getRemoteAddr());
        response.sendRedirect(request.getContextPath() + ADMIN_HOME_PATH);
    }

    @Override
    public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response,
                                        AuthenticationException exception) throws IOException {
        String loginError = resolveLoginError(request, exception);
        // 입력한 아이디는 남기지 않음 (비밀번호 오입력 노출 방지, #406)
        log.warn("[admin auth] login failed : ip={}, reason={}, result={}",
                request.getRemoteAddr(), exception.getClass().getSimpleName(), loginError);
        response.sendRedirect(request.getContextPath() + LOGIN_PAGE_PATH + loginError);
    }

    /** 실패 예외 > 화면 사유 (불일치면 실패 1회 기록 후 잠김 여부 반영) */
    private String resolveLoginError(HttpServletRequest request, AuthenticationException exception) {
        if (exception instanceof LockedException) {
            return LOGIN_ERROR_LOCKED;
        }
        if (exception instanceof DisabledException) {
            return LOGIN_ERROR_DISABLED;
        }
        String username = request.getParameter(USERNAME_PARAMETER);
        boolean isLockedNow = username != null && adminAccountService.recordLoginFailure(username);
        return isLockedNow ? LOGIN_ERROR_LOCKED : LOGIN_ERROR_BAD_CREDENTIALS;
    }
}
