package com.passql.web.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.member.auth.presentation.security.JwtAuthenticationFilter;
import com.passql.member.auth.infrastructure.jwt.JwtTokenProvider;
import com.passql.member.service.MemberSuspensionService;
import com.passql.meta.service.AppOperationService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import jakarta.servlet.DispatcherType;
import java.time.Clock;
import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtTokenProvider jwtTokenProvider;
    private final ApiSecurityErrorHandler apiSecurityErrorHandler;
    private final MemberSuspensionService memberSuspensionService;
    private final AppOperationService appOperationService;
    private final ObjectMapper objectMapper;

    // 허용 Origin — 운영 웹·Vercel 미리보기·로컬 개발만. 모바일 앱은 Origin을 보내지 않아 무관 (#394)
    @Value("${cors.allowed-origin-patterns:https://passql.vercel.app,https://passql-*.vercel.app,http://localhost:*,http://127.0.0.1:*}")
    private List<String> allowedOriginPatterns;

    @Bean
    @Order(2)
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // Swagger 실제 경로는 /docs/** 라 관리자 체인(AdminSecurityConfig)에서 다룬다 — 옛 기본 경로 설정은 제거 (#440)
            .securityMatcher("/api/**", "/actuator/**")
            .csrf(AbstractHttpConfigurer::disable)
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                // SSE async dispatch 시 Tomcat이 Security Filter Chain을 재통과 — ASYNC는 무조건 허용
                .dispatcherTypeMatchers(DispatcherType.ASYNC).permitAll()
                .requestMatchers(HttpMethod.POST, "/api/auth/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/auth/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/meta/**").permitAll()
                .requestMatchers("/actuator/health").permitAll()
                .anyRequest().authenticated()
            )
            .exceptionHandling(ex -> ex
                // 미인증 401·권한 없음 403을 표준 본문과 WARN 로그로 응답 (#406)
                .authenticationEntryPoint(apiSecurityErrorHandler)
                .accessDeniedHandler(apiSecurityErrorHandler)
            )
            // 점검 중 회원 API 503 (#464)
            .addFilterAfter(new MaintenanceModeFilter(appOperationService, objectMapper), CorsFilter.class)
            .addFilterBefore(
                new JwtAuthenticationFilter(jwtTokenProvider),
                UsernamePasswordAuthenticationFilter.class
            )
            // 제재 회원 차단 (JWT 인증 직후, 모든 회원 API 공통)
            .addFilterAfter(
                new SuspendedMemberBlockingFilter(memberSuspensionService, apiSecurityErrorHandler),
                UsernamePasswordAuthenticationFilter.class
            )
            // 비싼 경로 요청 제한 429 (로그인·AI·SQL 실행, #478)
            .addFilterAfter(
                new MemberApiRateLimitFilter(apiSecurityErrorHandler, Clock.systemUTC()),
                SuspendedMemberBlockingFilter.class
            );

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOriginPatterns(allowedOriginPatterns);
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
