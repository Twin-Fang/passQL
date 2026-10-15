package com.passql.web.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * 비밀번호 해시 (BCrypt): 관리자 인증·관리자 계정 서비스 공용
 * AdminSecurityConfig 와 분리 (보안 설정 > 계정 서비스 > 인코더 순환 참조 방지)
 */
@Configuration
public class PasswordEncoderConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
