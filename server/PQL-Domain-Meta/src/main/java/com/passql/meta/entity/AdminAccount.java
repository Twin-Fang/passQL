package com.passql.meta.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.meta.constant.AdminRole;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 관리자 계정: 아이디·비밀번호 해시·역할·사용 여부·로그인 잠금 상태
 * isEnvironmentManaged: yml(admin.username/password-hash) 기본 계정, 기동 시 동기화·화면 변경 불가
 */
@Entity
@Table(
    name = "admin_account",
    uniqueConstraints = @UniqueConstraint(name = "uk_admin_account_username", columnNames = "username")
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AdminAccount extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID adminAccountUuid;

    @Column(nullable = false, length = 50)
    private String username;

    // BCrypt 해시
    @Column(nullable = false, length = 100)
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private AdminRole role;

    @Column(nullable = false)
    private Boolean isEnabled;

    @Column(nullable = false)
    private Boolean isEnvironmentManaged;

    // 연속 로그인 실패 수 (성공·잠금 시 0)
    @Column(nullable = false)
    private Integer failedLoginCount;

    // 이 시각 전까지 로그인 거부 (null 이면 잠기지 않음)
    private LocalDateTime lockedUntil;

    private LocalDateTime lastLoginAt;

    @Column(length = 64)
    private String lastLoginIp;

    public static AdminAccount create(String username, String passwordHash, AdminRole role, boolean isEnvironmentManaged) {
        AdminAccount account = new AdminAccount();
        account.username = username;
        account.passwordHash = passwordHash;
        account.role = role;
        account.isEnabled = true;
        account.isEnvironmentManaged = isEnvironmentManaged;
        account.failedLoginCount = 0;
        return account;
    }

    public boolean isLockedAt(LocalDateTime now) {
        return lockedUntil != null && lockedUntil.isAfter(now);
    }

    /** 로그인 실패 1회 기록 > 한도 도달 시 잠금, 잠기면 true */
    public boolean recordLoginFailure(int maxFailedLoginCount, LocalDateTime lockUntil) {
        failedLoginCount = (failedLoginCount == null ? 0 : failedLoginCount) + 1;
        if (failedLoginCount < maxFailedLoginCount) {
            return false;
        }
        lockedUntil = lockUntil;
        failedLoginCount = 0;
        return true;
    }

    public void recordLoginSuccess(LocalDateTime now, String clientIp) {
        failedLoginCount = 0;
        lockedUntil = null;
        lastLoginAt = now;
        lastLoginIp = clientIp;
    }

    public void unlock() {
        failedLoginCount = 0;
        lockedUntil = null;
    }
}
