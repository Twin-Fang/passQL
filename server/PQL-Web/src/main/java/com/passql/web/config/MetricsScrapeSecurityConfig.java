package com.passql.web.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.HttpStatusEntryPoint;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Prometheus 수집 전용 Security filter chain: /actuator/prometheus 만, 수집기 토큰 인증 (#957)
 * API 체인(@Order(2), /actuator/**)보다 먼저 매칭 > JWT·제재·요청 제한·점검 필터 미적용
 */
@Configuration
public class MetricsScrapeSecurityConfig {

    // management.endpoints.web.exposure 의 prometheus 엔드포인트 경로
    static final String PROMETHEUS_SCRAPE_PATH = "/actuator/prometheus";

    @Bean
    @Order(0)
    public SecurityFilterChain metricsScrapeFilterChain(
            HttpSecurity http,
            @Value("${passql.metrics.scrape-token:}") String configuredScrapeToken) throws Exception {
        http
            .securityMatcher(PROMETHEUS_SCRAPE_PATH)
            .csrf(AbstractHttpConfigurer::disable)
            .httpBasic(AbstractHttpConfigurer::disable)
            .formLogin(AbstractHttpConfigurer::disable)
            .logout(AbstractHttpConfigurer::disable)
            .requestCache(AbstractHttpConfigurer::disable)
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .anyRequest().hasAuthority(PrometheusScrapeTokenFilter.METRICS_SCRAPER_AUTHORITY))
            // 필터 우회 시에도 본문 없는 401 (fail-closed)
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint(new HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED)))
            .addFilterBefore(new PrometheusScrapeTokenFilter(configuredScrapeToken),
                UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
