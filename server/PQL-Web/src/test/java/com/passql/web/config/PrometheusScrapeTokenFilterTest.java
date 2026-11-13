package com.passql.web.config;

import jakarta.servlet.FilterChain;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 수집기 토큰 필터 판정 (#957): 일치 > 권한 인증 후 통과, 그 외 > 본문 없는 401·다음 필터 미호출
 */
class PrometheusScrapeTokenFilterTest {

    private static final String SCRAPE_TOKEN = "test-scrape-token";

    @AfterEach
    void clearSecurityContext() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void 토큰이_일치하면_수집기_권한으로_통과한다() throws Exception {
        // 다음 필터 시점의 인증 기록 (호출 여부 겸용)
        AtomicReference<Authentication> authenticationInNextFilter = new AtomicReference<>();
        FilterChain capturingFilterChain = (request, response) ->
                authenticationInNextFilter.set(SecurityContextHolder.getContext().getAuthentication());

        MockHttpServletResponse response = runFilter(SCRAPE_TOKEN, "Bearer " + SCRAPE_TOKEN, capturingFilterChain);

        assertThat(response.getStatus()).isEqualTo(200);
        assertThat(authenticationInNextFilter.get()).isNotNull();
        assertThat(authenticationInNextFilter.get().isAuthenticated()).isTrue();
        assertThat(authenticationInNextFilter.get().getAuthorities()).extracting(GrantedAuthority::getAuthority)
                .containsExactly(PrometheusScrapeTokenFilter.METRICS_SCRAPER_AUTHORITY);
    }

    @Test
    void 헤더가_없으면_401() throws Exception {
        assertRejected(SCRAPE_TOKEN, null);
    }

    @Test
    void 토큰이_다르면_401() throws Exception {
        assertRejected(SCRAPE_TOKEN, "Bearer wrong-token");
        assertRejected(SCRAPE_TOKEN, "Bearer " + SCRAPE_TOKEN + "x");
    }

    @Test
    void Bearer_형식이_아니면_401() throws Exception {
        assertRejected(SCRAPE_TOKEN, SCRAPE_TOKEN);
        assertRejected(SCRAPE_TOKEN, "Basic " + SCRAPE_TOKEN);
    }

    @Test
    void 설정_토큰이_비어_있으면_항상_401() throws Exception {
        // 빈 설정 + 빈 Bearer 값처럼 길이 0 끼리 같아지는 경우 포함
        assertRejected("", "Bearer ");
        assertRejected("", "Bearer anything");
        assertRejected("   ", "Bearer    ");
        assertRejected(null, "Bearer ");
        assertRejected(null, null);
    }

    /** 거부 판정: 401·본문 없음·다음 필터 미호출·인증 미설정 */
    private void assertRejected(String configuredScrapeToken, String authorizationHeader) throws Exception {
        MockFilterChain filterChain = new MockFilterChain();

        MockHttpServletResponse response = runFilter(configuredScrapeToken, authorizationHeader, filterChain);

        assertThat(response.getStatus()).isEqualTo(401);
        assertThat(response.getContentAsByteArray()).isEmpty();
        assertThat(filterChain.getRequest()).isNull();
        assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
    }

    private MockHttpServletResponse runFilter(String configuredScrapeToken, String authorizationHeader,
                                              FilterChain filterChain) throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", MetricsScrapeSecurityConfig.PROMETHEUS_SCRAPE_PATH);
        if (authorizationHeader != null) {
            request.addHeader("Authorization", authorizationHeader);
        }
        MockHttpServletResponse response = new MockHttpServletResponse();
        new PrometheusScrapeTokenFilter(configuredScrapeToken).doFilter(request, response, filterChain);
        return response;
    }
}
