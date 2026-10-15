package com.passql.web.config.admin;

import com.passql.meta.constant.AdminRole;
import com.passql.meta.entity.AdminAccount;
import com.passql.meta.service.AdminAccountService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * 관리자 인증 계정 조회: admin_account 행 우선 > 기본 계정(yml) 폴백
 * 폴백 2가지: 행 없음(시드 전), DB 조회 실패 > yml 아이디면 ADMIN 으로 로그인 유지 (운영 로그인 연속성)
 * 기본 계정 비밀번호는 항상 yml 해시 (환경변수 교체만으로 복구 가능)
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminUserDetailsService implements UserDetailsService {

    private final AdminAccountService adminAccountService;

    @Value("${admin.username}")
    private String environmentAdminUsername;

    @Value("${admin.password-hash}")
    private String environmentAdminPasswordHash;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Optional<AdminAccount> accountOptional = findAccountOrEmptyOnFailure(username);
        if (accountOptional.isPresent()) {
            return toUserDetails(accountOptional.get());
        }
        if (isEnvironmentAdmin(username)) {
            return buildEnvironmentAdmin();
        }
        throw new UsernameNotFoundException("admin account not found");
    }

    /** DB 장애·테이블 누락이어도 기본 계정 로그인은 살아 있게 조회 실패를 빈 값으로 */
    private Optional<AdminAccount> findAccountOrEmptyOnFailure(String username) {
        try {
            return adminAccountService.findByUsername(username);
        } catch (Exception e) {
            log.warn("[admin auth] account lookup failed, environment fallback : {}", e.getClass().getSimpleName());
            return Optional.empty();
        }
    }

    /** 계정 행 > UserDetails (잠금·사용 여부 반영, 기본 계정은 yml 해시) */
    private UserDetails toUserDetails(AdminAccount account) {
        boolean isEnvironmentAccount = Boolean.TRUE.equals(account.getIsEnvironmentManaged()) && isEnvironmentAdmin(account.getUsername());
        String passwordHash = isEnvironmentAccount ? environmentAdminPasswordHash : account.getPasswordHash();
        return User.withUsername(account.getUsername())
                .password(passwordHash)
                .roles(account.getRole().toSecurityRoleName())
                .accountLocked(account.isLockedAt(LocalDateTime.now()))
                .disabled(!Boolean.TRUE.equals(account.getIsEnabled()))
                .build();
    }

    private UserDetails buildEnvironmentAdmin() {
        return User.withUsername(environmentAdminUsername)
                .password(environmentAdminPasswordHash)
                .roles(AdminRole.ADMIN.toSecurityRoleName())
                .build();
    }

    private boolean isEnvironmentAdmin(String username) {
        return environmentAdminUsername.equals(username);
    }
}
