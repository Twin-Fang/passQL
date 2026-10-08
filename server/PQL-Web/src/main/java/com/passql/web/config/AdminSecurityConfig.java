package com.passql.web.config;

import com.passql.web.config.admin.AdminUserDetailsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

/**
 * 관리자 페이지 전용 Security filter chain.
 * /admin/** 경로에만 적용되며, 세션 기반 폼 로그인을 사용한다.
 * JWT 기반 API chain(@Order(2))과 완전 분리된다.
 */
@Configuration
@RequiredArgsConstructor
@Slf4j
public class AdminSecurityConfig {

    private final AdminUserDetailsService adminUserDetailsService;

    @Bean
    @Order(1)
    public SecurityFilterChain adminFilterChain(HttpSecurity http) throws Exception {
        http
            // 운영 Swagger(/docs/swagger, /docs/api-docs)는 API 전체 구조를 드러내므로 관리자 로그인 뒤로 둔다 (#440)
            .securityMatcher("/admin/**", "/docs/**")
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/admin/login").permitAll()
                .anyRequest().hasRole("ADMIN")
            )
            .formLogin(form -> form
                .loginPage("/admin/login")
                .loginProcessingUrl("/admin/login")
                .defaultSuccessUrl("/admin", true)
                // 실패만 기록한다 — 무차별 대입을 추적할 수 있게 (#406). 입력한 아이디는 남기지 않는다
                .failureHandler((request, response, e) -> {
                    log.warn("[admin-auth] 관리자 로그인 실패: ip={}, reason={}", request.getRemoteAddr(), e.getClass().getSimpleName());
                    response.sendRedirect(request.getContextPath() + "/admin/login?error=true");
                })
                .usernameParameter("username")
                .passwordParameter("password")
            )
            .logout(logout -> logout
                .logoutUrl("/admin/logout")
                .logoutSuccessUrl("/admin/login?logout=true")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID")
            )
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
            )
            .userDetailsService(adminUserDetailsService);

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
