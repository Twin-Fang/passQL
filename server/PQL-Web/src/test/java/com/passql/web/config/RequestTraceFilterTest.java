package com.passql.web.config;

import jakarta.servlet.FilterChain;
import org.junit.jupiter.api.Test;
import org.slf4j.MDC;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;

/** 요청 ID 가 로그(MDC)·응답 헤더에 같게 실리고, 요청이 끝나면 지워지는지 확인한다 (#436). */
class RequestTraceFilterTest {

    private final RequestTraceFilter filter = new RequestTraceFilter();

    @Test
    void 요청ID를_만들어_MDC와_응답헤더에_싣고_끝나면_비운다() throws Exception {
        MockHttpServletRequest req = new MockHttpServletRequest("GET", "/api/meta/topics");
        MockHttpServletResponse res = new MockHttpServletResponse();
        AtomicReference<String> seen = new AtomicReference<>();
        FilterChain chain = (rq, rs) -> {
            seen.set(MDC.get(RequestTraceFilter.MDC_REQUEST_ID));
            MDC.put(RequestTraceFilter.MDC_MEMBER_ID, "abcd1234"); // JWT 필터가 채운 상황
        };

        filter.doFilter(req, res, chain);

        assertThat(seen.get()).hasSize(8);
        assertThat(res.getHeader(RequestTraceFilter.HEADER)).isEqualTo(seen.get());
        assertThat(MDC.get(RequestTraceFilter.MDC_REQUEST_ID)).isNull();
        assertThat(MDC.get(RequestTraceFilter.MDC_MEMBER_ID)).isNull();
    }

    @Test
    void 안전한_X_Request_Id는_이어받고_위험한_값은_버린다() throws Exception {
        MockHttpServletRequest ok = new MockHttpServletRequest("GET", "/api/x");
        ok.addHeader(RequestTraceFilter.HEADER, "client-req-0001");
        MockHttpServletResponse okRes = new MockHttpServletResponse();
        filter.doFilter(ok, okRes, (rq, rs) -> { });
        assertThat(okRes.getHeader(RequestTraceFilter.HEADER)).isEqualTo("client-req-0001");

        MockHttpServletRequest bad = new MockHttpServletRequest("GET", "/api/x");
        bad.addHeader(RequestTraceFilter.HEADER, "x\n[req] fake log line");
        MockHttpServletResponse badRes = new MockHttpServletResponse();
        filter.doFilter(bad, badRes, (rq, rs) -> { });
        assertThat(badRes.getHeader(RequestTraceFilter.HEADER)).matches("[0-9a-f]{8}");
    }

    @Test
    void 헬스체크와_정적파일은_요약하지_않는다() {
        assertThat(RequestTraceFilter.shouldSummarize("/api/members/me")).isTrue();
        assertThat(RequestTraceFilter.shouldSummarize("/admin/questions")).isTrue();
        assertThat(RequestTraceFilter.shouldSummarize("/actuator/health")).isFalse();
        assertThat(RequestTraceFilter.shouldSummarize("/js/app.js")).isFalse();
    }
}
