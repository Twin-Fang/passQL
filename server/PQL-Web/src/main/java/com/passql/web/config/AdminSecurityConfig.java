package com.passql.web.config;

import com.passql.meta.constant.AdminRole;
import com.passql.web.config.admin.AdminAccessDeniedHandler;
import com.passql.web.config.admin.AdminLoginResultHandler;
import com.passql.web.config.admin.AdminUserDetailsService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.core.session.SessionRegistry;
import org.springframework.security.core.session.SessionRegistryImpl;
import org.springframework.security.web.session.HttpSessionEventPublisher;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

/**
 * 관리자 페이지 전용 Security filter chain.
 * /admin/** 경로에만 적용되며, 세션 기반 폼 로그인을 사용한다.
 * JWT 기반 API chain(@Order(2))과 완전 분리된다.
 * 권한 3단계: 관리자 계정 관리 ADMIN, 조회(GET) ADMIN·VIEWER, 그 외 변경 요청 ADMIN (#478)
 */
@Configuration
@RequiredArgsConstructor
public class AdminSecurityConfig {

    private static final String ADMIN = AdminRole.ADMIN.toSecurityRoleName();
    private static final String VIEWER = AdminRole.VIEWER.toSecurityRoleName();

    private final AdminUserDetailsService adminUserDetailsService;
    private final AdminLoginResultHandler adminLoginResultHandler;
    private final AdminAccessDeniedHandler adminAccessDeniedHandler;
    private final SessionRegistry adminSessionRegistry;

    /** 관리자 세션 추적 (세션 생성·삭제 이벤트는 HttpSessionEventPublisher 가 전달) */
    @Bean
    public static SessionRegistry adminSessionRegistry() {
        return new SessionRegistryImpl();
    }

    @Bean
    public static HttpSessionEventPublisher httpSessionEventPublisher() {
        return new HttpSessionEventPublisher();
    }

    @Bean
    @Order(1)
    public SecurityFilterChain adminFilterChain(HttpSecurity http) throws Exception {
        http
            // 운영 Swagger(/docs/swagger, /docs/api-docs)는 API 전체 구조를 드러내므로 관리자 로그인 뒤로 둔다 (#440)
            .securityMatcher("/admin/**", "/docs/**")
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/admin/login").permitAll()
                .requestMatchers("/admin/logout").authenticated()
                .requestMatchers("/admin/accounts/**").hasRole(ADMIN)
                .requestMatchers(HttpMethod.GET, "/admin/**", "/docs/**").hasAnyRole(ADMIN, VIEWER)
                .anyRequest().hasRole(ADMIN)
            )
            .formLogin(form -> form
                .loginPage("/admin/login")
                .loginProcessingUrl("/admin/login")
                // 성공·실패 기록과 5회 실패 잠금 (#478), 실패 로그에 입력 아이디는 남기지 않는다 (#406)
                .successHandler(adminLoginResultHandler)
                .failureHandler(adminLoginResultHandler)
                .usernameParameter(AdminLoginResultHandler.USERNAME_PARAMETER)
                .passwordParameter("password")
            )
            .exceptionHandling(ex -> ex.accessDeniedHandler(adminAccessDeniedHandler))
            .logout(logout -> logout
                .logoutUrl("/admin/logout")
                .logoutSuccessUrl("/admin/login?logout=true")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID")
            )
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
                // 세션 수 제한 없음(-1), 레지스트리로 세션 추적 > 계정 화면에서 강제 종료
                .maximumSessions(-1)
                .sessionRegistry(adminSessionRegistry)
                .expiredUrl("/admin/login?expired=true")
            )
            .userDetailsService(adminUserDetailsService);

        return http.build();
    }
}
