package com.passql.web.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

/**
 * 관제소 연동 경로 보안 체인 (#959): /control/** 는 회원 JWT·관리자 세션 대상 밖
 * 인증은 컨트롤러 서비스의 X-Control-Token 검증 (무상태, CSRF 없음)
 */
@Configuration
public class ControlTowerSecurityConfig {

    // 관제소 pull 수집 경로 (관제소 소스 url: https://api.passql.suhsaechan.kr/control/attention)
    public static final String ATTENTION_PATH = "/control/attention";
    private static final String CONTROL_TOWER_PATH_PATTERN = "/control/**";

    @Bean
    @Order(3)
    public SecurityFilterChain controlTowerFilterChain(HttpSecurity http) throws Exception {
        http
            .securityMatcher(CONTROL_TOWER_PATH_PATTERN)
            .csrf(AbstractHttpConfigurer::disable)
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .requestCache(AbstractHttpConfigurer::disable)
            .authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
        return http.build();
    }
}
