package com.passql.web.controller.admin;

import com.passql.meta.service.AdminAccountService;
import com.passql.web.config.admin.AdminLoginResultHandler;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * 관리자 로그인 페이지 컨트롤러.
 * POST /admin/login 은 Spring Security formLogin이 직접 처리한다.
 */
@Controller
@RequestMapping("/admin/login")
public class AdminLoginController {

    @GetMapping
    public String loginPage(
            @RequestParam(value = "error", required = false) String error,
            @RequestParam(value = "logout", required = false) String logout,
            Model model
    ) {
        if (error != null) {
            model.addAttribute("errorMessage", toLoginErrorMessage(error));
        }
        if (logout != null) {
            model.addAttribute("logoutMessage", "로그아웃 되었습니다.");
        }
        return "admin/login";
    }

    /** 로그인 실패 사유 코드 > 화면 문구 (AdminLoginResultHandler 가 넘김) */
    private String toLoginErrorMessage(String error) {
        if (AdminLoginResultHandler.LOGIN_ERROR_LOCKED.equals(error)) {
            return "로그인을 " + AdminAccountService.MAX_FAILED_LOGIN_COUNT + "회 실패해 "
                    + AdminAccountService.LOGIN_LOCK_MINUTES + "분간 잠겼습니다. 잠시 후 다시 시도하거나 다른 관리자에게 잠금 해제를 요청하세요.";
        }
        if (AdminLoginResultHandler.LOGIN_ERROR_DISABLED.equals(error)) {
            return "사용 중지된 관리자 계정입니다.";
        }
        return "아이디 또는 비밀번호가 올바르지 않습니다.";
    }
}
