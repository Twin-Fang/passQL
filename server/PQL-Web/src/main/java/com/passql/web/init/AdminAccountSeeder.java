package com.passql.web.init;

import com.passql.meta.service.AdminAccountService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

/**
 * 기동 시 기본 관리자 계정(yml admin.username/password-hash) > admin_account 시드·동기화
 * 실패해도 기동은 계속 (AdminUserDetailsService 가 yml 폴백으로 로그인 유지)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AdminAccountSeeder implements ApplicationRunner {

    @Value("${admin.username}")
    private String environmentAdminUsername;

    @Value("${admin.password-hash}")
    private String environmentAdminPasswordHash;

    private final AdminAccountService adminAccountService;

    @Override
    public void run(ApplicationArguments args) {
        try {
            adminAccountService.syncEnvironmentAccount(environmentAdminUsername, environmentAdminPasswordHash);
        } catch (Exception e) {
            log.error("[admin account] environment account sync failed, yml fallback stays active : {}",
                    e.getClass().getSimpleName());
        }
    }
}
