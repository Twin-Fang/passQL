package com.passql.meta.dto;

import com.passql.meta.constant.AdminRole;
import com.passql.meta.entity.AdminAccount;

import java.time.LocalDateTime;
import java.util.UUID;

/** 관리자 계정 화면 행 (비밀번호 해시 제외) */
public record AdminAccountView(
        UUID adminAccountUuid,
        String username,
        AdminRole role,
        Boolean isEnabled,
        Boolean isEnvironmentManaged,
        Boolean isLocked,
        LocalDateTime lockedUntil,
        LocalDateTime lastLoginAt,
        String lastLoginIp,
        LocalDateTime createdAt,
        String createdBy
) {
    public static AdminAccountView from(AdminAccount account, LocalDateTime now) {
        return new AdminAccountView(
                account.getAdminAccountUuid(),
                account.getUsername(),
                account.getRole(),
                account.getIsEnabled(),
                account.getIsEnvironmentManaged(),
                account.isLockedAt(now),
                account.getLockedUntil(),
                account.getLastLoginAt(),
                account.getLastLoginIp(),
                account.getCreatedAt(),
                account.getCreatedBy()
        );
    }
}
