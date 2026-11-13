package com.passql.web.config;

import com.passql.member.auth.infrastructure.jwt.JwtTokenProvider;
import com.passql.member.service.MemberSuspensionService;
import com.passql.meta.service.AppOperationService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.data.jpa.JpaRepositoriesAutoConfiguration;
import org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration;
import org.springframework.boot.autoconfigure.data.redis.RedisRepositoriesAutoConfiguration;
import org.springframework.boot.autoconfigure.flyway.FlywayAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration;
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration;
import org.springframework.boot.test.autoconfigure.actuate.observability.AutoConfigureObservability;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Prometheus 수집 주소 보안 (#957): 실제 보안 체인 2개(수집 @Order(0), API @Order(2)) + 실제 actuator 엔드포인트
 * DB·Redis 없이 실행 (API 체인 의존 서비스는 목), 필터 켬
 */
@SpringBootTest(
        classes = MetricsScrapeSecurityIntegrationTest.MetricsScrapeContext.class,
        // application.yml 의 prod 프로필(DB 접속) 대신 빈 프로필, 변경 이력 주입(suh-api-log) 제외
        properties = {
                "spring.profiles.active=metrics-scrape-test",
                "suhapilog.enabled=false",
                "passql.metrics.scrape-token=" + MetricsScrapeSecurityIntegrationTest.SCRAPE_TOKEN
        })
@AutoConfigureMockMvc
// 테스트 기본값은 지표 내보내기 꺼짐 > prometheus 엔드포인트 등록을 위해 켬
@AutoConfigureObservability
class MetricsScrapeSecurityIntegrationTest {

    static final String SCRAPE_TOKEN = "integration-test-scrape-token";
    private static final String PROMETHEUS_PATH = MetricsScrapeSecurityConfig.PROMETHEUS_SCRAPE_PATH;
    private static final String HEALTH_PATH = "/actuator/health";

    @Autowired
    private MockMvc mockMvc;

    // API 체인(SecurityConfig) 생성자 의존
    @MockitoBean
    private JwtTokenProvider jwtTokenProvider;
    @MockitoBean
    private MemberSuspensionService memberSuspensionService;
    @MockitoBean
    private AppOperationService appOperationService;

    @Test
    void 토큰_없이_수집하면_401() throws Exception {
        mockMvc.perform(get(PROMETHEUS_PATH))
                .andExpect(status().isUnauthorized())
                .andExpect(content().string(""));
    }

    @Test
    void 틀린_토큰으로_수집하면_401() throws Exception {
        mockMvc.perform(get(PROMETHEUS_PATH).header("Authorization", "Bearer wrong-token"))
                .andExpect(status().isUnauthorized())
                .andExpect(content().string(""));
    }

    @Test
    void 맞는_토큰으로_수집하면_지표를_돌려준다() throws Exception {
        mockMvc.perform(get(PROMETHEUS_PATH).header("Authorization", "Bearer " + SCRAPE_TOKEN))
                .andExpect(status().isOk())
                .andExpect(content().string(containsString("jvm_memory_used_bytes")))
                // management.metrics.tags.application 공통 태그
                .andExpect(content().string(containsString("application=\"passql\"")));
    }

    @Test
    void 헬스체크는_토큰_없이_200() throws Exception {
        mockMvc.perform(get(HEALTH_PATH))
                .andExpect(status().isOk());
    }

    @Test
    void 수집기_토큰으로_다른_actuator_경로는_열리지_않는다() throws Exception {
        // API 체인(/actuator/**, 인증 필요)이 처리 > 수집기 토큰은 JWT 로 통하지 않음
        mockMvc.perform(get("/actuator/env").header("Authorization", "Bearer " + SCRAPE_TOKEN))
                .andExpect(status().isUnauthorized());
    }

    /**
     * 보안 체인 검증 전용 최소 컨텍스트: 보안 설정 2개 + actuator 자동설정, DB·Redis·요청 로깅 자동설정 제외
     */
    @Configuration
    @EnableAutoConfiguration(exclude = {
            DataSourceAutoConfiguration.class,
            DataSourceTransactionManagerAutoConfiguration.class,
            HibernateJpaAutoConfiguration.class,
            JpaRepositoriesAutoConfiguration.class,
            FlywayAutoConfiguration.class,
            RedisAutoConfiguration.class,
            RedisRepositoriesAutoConfiguration.class
    }, excludeName = {
            // suh-logger 가 자기 패키지 @SpringBootApplication 까지 스캔 > 위 제외가 무시됨 (OpenApiContractTest 와 같은 이유)
            "kr.suhsaechan.suhlogger.config.SuhLoggerAutoConfiguration"
    })
    @Import({MetricsScrapeSecurityConfig.class, SecurityConfig.class, ApiSecurityErrorHandler.class})
    static class MetricsScrapeContext {
    }
}
