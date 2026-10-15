package com.passql.web.controller.admin;

import com.passql.meta.constant.AdminRole;
import com.passql.meta.dto.AdminAccountCreateRequest;
import com.passql.meta.dto.AdminAccountUpdateRequest;
import com.passql.meta.dto.AdminPasswordResetRequest;
import com.passql.meta.service.AdminAccountService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.security.Principal;
import java.util.UUID;

/**
 * 관리자 계정 관리 (ADMIN 전용, AdminSecurityConfig): 목록, 추가, 역할·사용 여부, 비밀번호 재설정, 잠금 해제
 */
@Controller
@RequestMapping("/admin/accounts")
@RequiredArgsConstructor
public class AdminAccountController {

    private final AdminAccountService adminAccountService;

    @GetMapping
    @AdminPage(menu = AdminMenu.ADMIN_ACCOUNTS)
    public String list(Model model) {
        model.addAttribute("accounts", adminAccountService.findAllAsView());
        model.addAttribute("roles", AdminRole.values());
        model.addAttribute("maxFailedLoginCount", AdminAccountService.MAX_FAILED_LOGIN_COUNT);
        model.addAttribute("loginLockMinutes", AdminAccountService.LOGIN_LOCK_MINUTES);
        return "admin/accounts";
    }

    @PostMapping
    @ResponseBody
    public ResponseEntity<Void> create(@Valid @RequestBody AdminAccountCreateRequest request) {
        adminAccountService.createAccount(request);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{adminAccountUuid}")
    @ResponseBody
    public ResponseEntity<Void> update(@PathVariable UUID adminAccountUuid,
                                       @Valid @RequestBody AdminAccountUpdateRequest request,
                                       Principal adminPrincipal) {
        adminAccountService.updateAccount(adminAccountUuid, request, adminPrincipal.getName());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{adminAccountUuid}/password")
    @ResponseBody
    public ResponseEntity<Void> resetPassword(@PathVariable UUID adminAccountUuid,
                                              @Valid @RequestBody AdminPasswordResetRequest request) {
        adminAccountService.resetPassword(adminAccountUuid, request.password());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{adminAccountUuid}/unlock")
    @ResponseBody
    public ResponseEntity<Void> unlock(@PathVariable UUID adminAccountUuid) {
        adminAccountService.unlockAccount(adminAccountUuid);
        return ResponseEntity.ok().build();
    }
}
