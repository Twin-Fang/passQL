package com.passql.web.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.meta.service.AppOperationService;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/** 점검 중 회원 API 503, meta·auth·비 API 경로는 통과 (#464) */
class MaintenanceModeFilterTest {

    private final ObjectMapper objectMapper = new ObjectMapper();

    private MockHttpServletResponse request(boolean isUnderMaintenance, String uri) throws Exception {
        AppOperationService appOperationService = mock(AppOperationService.class);
        when(appOperationService.isUnderMaintenance()).thenReturn(isUnderMaintenance);
        MockHttpServletResponse response = new MockHttpServletResponse();
        new MaintenanceModeFilter(appOperationService, objectMapper)
                .doFilter(new MockHttpServletRequest("GET", uri), response, new MockFilterChain());
        return response;
    }

    @Test
    void 점검_중_회원_API는_503_SERVICE_UNDER_MAINTENANCE() throws Exception {
        MockHttpServletResponse response = request(true, "/api/home/summary");

        assertThat(response.getStatus()).isEqualTo(503);
        Map<?, ?> body = objectMapper.readValue(response.getContentAsString(), Map.class);
        assertThat(body.get("errorCode")).isEqualTo("SERVICE_UNDER_MAINTENANCE");
    }

    @Test
    void 점검_중에도_앱_시작_설정과_인증은_통과() throws Exception {
        assertThat(request(true, "/api/meta/app-config").getStatus()).isEqualTo(200);
        assertThat(request(true, "/api/auth/refresh").getStatus()).isEqualTo(200);
        assertThat(request(true, "/actuator/health").getStatus()).isEqualTo(200);
    }

    @Test
    void 점검이_아니면_통과() throws Exception {
        assertThat(request(false, "/api/home/summary").getStatus()).isEqualTo(200);
    }
}
