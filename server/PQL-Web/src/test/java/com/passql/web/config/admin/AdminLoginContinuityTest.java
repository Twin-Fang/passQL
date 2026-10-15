package com.passql.web.config.admin;

import com.passql.meta.constant.AdminRole;
import com.passql.meta.entity.AdminAccount;
import com.passql.meta.service.AdminAccountService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/** 운영 로그인 연속성 (#478): 기본 계정 폴백 2가지, 잠금·역할 반영 — 컨텍스트 없는 단위 테스트 */
class AdminLoginContinuityTest {

    private static final String ENVIRONMENT_USERNAME = "operator";
    private static final String ENVIRONMENT_HASH = "{bcrypt-hash-from-yml}";

    private AdminAccountService adminAccountService;
    private AdminUserDetailsService adminUserDetailsService;

    @BeforeEach
    void setUp() {
        adminAccountService = mock(AdminAccountService.class);
        adminUserDetailsService = new AdminUserDetailsService(adminAccountService);
        ReflectionTestUtils.setField(adminUserDetailsService, "environmentAdminUsername", ENVIRONMENT_USERNAME);
        ReflectionTestUtils.setField(adminUserDetailsService, "environmentAdminPasswordHash", ENVIRONMENT_HASH);
    }

    @Test
    void 계정_행이_없어도_기본_계정은_yml_해시와_ADMIN으로_로그인된다() {
        when(adminAccountService.findByUsername(anyString())).thenReturn(Optional.empty());

        UserDetails user = adminUserDetailsService.loadUserByUsername(ENVIRONMENT_USERNAME);

        assertThat(user.getPassword()).isEqualTo(ENVIRONMENT_HASH);
        assertThat(user.getAuthorities()).extracting("authority").containsExactly("ROLE_ADMIN");
    }

    @Test
    void DB_조회가_실패해도_기본_계정은_로그인된다() {
        when(adminAccountService.findByUsername(anyString()))
                .thenThrow(new DataAccessResourceFailureException("admin_account missing"));

        UserDetails user = adminUserDetailsService.loadUserByUsername(ENVIRONMENT_USERNAME);

        assertThat(user.getUsername()).isEqualTo(ENVIRONMENT_USERNAME);
        assertThat(user.isAccountNonLocked()).isTrue();
    }

    @Test
    void 기본_계정_행이_있으면_비밀번호는_항상_yml_해시를_쓴다() {
        AdminAccount seeded = AdminAccount.create(ENVIRONMENT_USERNAME, "{stale-hash}", AdminRole.ADMIN, true);
        when(adminAccountService.findByUsername(ENVIRONMENT_USERNAME)).thenReturn(Optional.of(seeded));

        assertThat(adminUserDetailsService.loadUserByUsername(ENVIRONMENT_USERNAME).getPassword()).isEqualTo(ENVIRONMENT_HASH);
    }

    @Test
    void 화면에서_만든_VIEWER_계정은_역할과_잠금이_반영된다() {
        AdminAccount viewer = AdminAccount.create("viewer1", "{viewer-hash}", AdminRole.VIEWER, false);
        viewer.setLockedUntil(LocalDateTime.now().plusMinutes(5));
        when(adminAccountService.findByUsername("viewer1")).thenReturn(Optional.of(viewer));

        UserDetails user = adminUserDetailsService.loadUserByUsername("viewer1");

        assertThat(user.getAuthorities()).extracting("authority").containsExactly("ROLE_VIEWER");
        assertThat(user.isAccountNonLocked()).isFalse();
    }

    @Test
    void 없는_아이디는_거부된다() {
        when(adminAccountService.findByUsername(anyString())).thenReturn(Optional.empty());

        assertThatThrownBy(() -> adminUserDetailsService.loadUserByUsername("nobody"))
                .isInstanceOf(UsernameNotFoundException.class);
    }

    @Test
    void 다섯번째_실패에서_잠기고_실패_수는_초기화된다() {
        AdminAccount account = AdminAccount.create("viewer2", "{hash}", AdminRole.VIEWER, false);
        LocalDateTime lockUntil = LocalDateTime.now().plusMinutes(AdminAccountService.LOGIN_LOCK_MINUTES);

        for (int attempt = 1; attempt < AdminAccountService.MAX_FAILED_LOGIN_COUNT; attempt++) {
            assertThat(account.recordLoginFailure(AdminAccountService.MAX_FAILED_LOGIN_COUNT, lockUntil)).isFalse();
        }
        assertThat(account.recordLoginFailure(AdminAccountService.MAX_FAILED_LOGIN_COUNT, lockUntil)).isTrue();
        assertThat(account.isLockedAt(LocalDateTime.now())).isTrue();
        assertThat(account.getFailedLoginCount()).isZero();
    }
}
