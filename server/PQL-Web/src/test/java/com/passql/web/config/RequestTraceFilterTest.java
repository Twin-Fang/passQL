package com.passql.web.config;

import com.passql.common.exception.GlobalExceptionHandler;
import com.passql.meta.service.ServerErrorLogService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import org.junit.jupiter.api.Test;
import org.slf4j.MDC;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

/** 요청 ID 추적(#436)과 서버 오류 기록(#440) — 요청 하나의 상태가 로그·DB에 사실대로 남는지 확인한다. */
class RequestTraceFilterTest {

    private final ServerErrorLogService errorLog = mock(ServerErrorLogService.class);
    private final RequestTraceFilter filter = new RequestTraceFilter(errorLog);

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
        verify(errorLog, never()).record(any(), any(), any(), any(), anyInt(), any());
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
    void 처리되지_않은_예외는_500으로_기록하고_그대로_던진다() {
        MockHttpServletRequest req = new MockHttpServletRequest("POST", "/api/practice");
        req.addHeader(RequestTraceFilter.HEADER, "boom-0000001");
        MockHttpServletResponse res = new MockHttpServletResponse(); // 상태는 아직 200
        FilterChain chain = (rq, rs) -> {
            MDC.put(RequestTraceFilter.MDC_MEMBER_ID, "abcd1234");
            throw new ServletException(new IllegalStateException("db down"));
        };

        assertThatThrownBy(() -> filter.doFilter(req, res, chain)).isInstanceOf(ServletException.class);

        verify(errorLog).record(eq("boom-0000001"), eq("abcd1234"), eq("POST"), eq("/api/practice"), eq(500),
                eq("java.lang.IllegalStateException: db down"));
        assertThat(MDC.get(RequestTraceFilter.MDC_MEMBER_ID)).isNull();
    }

    @Test
    void 예외_핸들러가_만든_5xx는_핸들러가_남긴_원인으로_기록한다() throws Exception {
        MockHttpServletRequest req = new MockHttpServletRequest("GET", "/api/ai/explain");
        MockHttpServletResponse res = new MockHttpServletResponse();
        FilterChain chain = (rq, rs) -> {
            rq.setAttribute(GlobalExceptionHandler.ERROR_DETAIL_ATTR, "AI_SERVER_ERROR: 응답 없음");
            ((MockHttpServletResponse) rs).setStatus(502);
        };

        filter.doFilter(req, res, chain);

        verify(errorLog).record(anyString(), eq(null), eq("GET"), eq("/api/ai/explain"), eq(502),
                eq("AI_SERVER_ERROR: 응답 없음"));
    }

    @Test
    void 클라이언트오류와_헬스체크는_기록하지_않는다() throws Exception {
        MockHttpServletResponse res = new MockHttpServletResponse();
        filter.doFilter(new MockHttpServletRequest("GET", "/api/x"), res, (rq, rs) -> ((MockHttpServletResponse) rs).setStatus(404));
        MockHttpServletResponse health = new MockHttpServletResponse();
        filter.doFilter(new MockHttpServletRequest("GET", "/actuator/health"), health,
                (rq, rs) -> ((MockHttpServletResponse) rs).setStatus(503));

        verify(errorLog, never()).record(any(), any(), any(), any(), anyInt(), any());
    }

    @Test
    void 헬스체크와_정적파일은_요약하지_않는다() {
        assertThat(RequestTraceFilter.shouldSummarize("/api/members/me")).isTrue();
        assertThat(RequestTraceFilter.shouldSummarize("/admin/questions")).isTrue();
        assertThat(RequestTraceFilter.shouldSummarize("/actuator/health")).isFalse();
        assertThat(RequestTraceFilter.shouldSummarize("/js/app.js")).isFalse();
    }
}
