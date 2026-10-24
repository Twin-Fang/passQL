package com.passql.web.controller.admin;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.AdminAccountSort;
import com.passql.meta.constant.AdminRole;
import com.passql.meta.dto.AdminAccountCreateRequest;
import com.passql.meta.dto.AdminAccountUpdateRequest;
import com.passql.meta.dto.AdminPasswordResetRequest;
import com.passql.meta.service.AdminAccountService;
import com.passql.web.support.AdminMenu;
import com.passql.web.service.AdminSessionService;
import com.passql.web.support.AdminPage;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.security.Principal;
import java.util.Map;
import java.util.UUID;

/**
 * 관리자 계정 관리 (ADMIN 전용, AdminSecurityConfig): 목록, 추가, 역할·사용 여부, 비밀번호 재설정, 잠금 해제, 삭제, 세션 강제 종료
 */
@Controller
@RequestMapping("/admin/accounts")
@RequiredArgsConstructor
public class AdminAccountController {

    private final AdminAccountService adminAccountService;
    private final AdminSessionService adminSessionService;

    @GetMapping
    @AdminPage(menu = AdminMenu.ADMIN_ACCOUNTS)
    public String list(Model model,
                       @RequestParam(required = false) String keyword,
                       @RequestParam(required = false) String sort) {
        AdminAccountSort accountSort = AdminAccountSort.fromRequestValueOrDefault(sort);
        model.addAttribute("accounts", adminAccountService.searchAsView(keyword, accountSort));
        model.addAttribute("keyword", keyword);
        model.addAttribute("selectedSort", accountSort.name());
        model.addAttribute("sorts", AdminAccountSort.values());
        // 아이디 > 활성 세션 수 (강제 종료 버튼 노출 기준)
        model.addAttribute("activeSessionCountByUsername", adminSessionService.countActiveSessionsByUsername());
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

    @DeleteMapping("/{adminAccountUuid}")
    @ResponseBody
    public ResponseEntity<Void> delete(@PathVariable UUID adminAccountUuid, Principal adminPrincipal) {
        adminAccountService.deleteAccount(adminAccountUuid, adminPrincipal.getName());
        return ResponseEntity.ok().build();
    }

    /** 계정의 로그인 세션 전부 강제 종료 (본인 계정 제외: 자기 세션을 끊어 화면이 잠기는 것 방지) */
    @PostMapping("/{adminAccountUuid}/sessions/terminate")
    @ResponseBody
    public Map<String, Integer> terminateSessions(@PathVariable UUID adminAccountUuid, Principal adminPrincipal) {
        String username = adminAccountService.getUsername(adminAccountUuid);
        if (username.equals(adminPrincipal.getName())) {
            throw new CustomException(ErrorCode.ADMIN_ACCOUNT_SELF_CHANGE_FORBIDDEN);
        }
        return Map.of("terminatedCount", adminSessionService.terminateSessions(username));
    }
}
