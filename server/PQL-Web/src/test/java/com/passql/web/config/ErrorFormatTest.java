package com.passql.web.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.boot.web.error.ErrorAttributeOptions;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.InsufficientAuthenticationException;
import org.springframework.web.context.request.ServletWebRequest;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/** 에러 응답 형식 통일 (#406) — 컨텍스트 없이 도는 단위 테스트 */
class ErrorFormatTest {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    void 미인증_요청은_UNAUTHORIZED_본문과_401() throws Exception {
        MockHttpServletResponse res = new MockHttpServletResponse();
        new ApiSecurityErrorHandler(objectMapper).commence(
                new MockHttpServletRequest("GET", "/api/members/me"), res, new InsufficientAuthenticationException("x"));

        assertThat(res.getStatus()).isEqualTo(401);
        Map<?, ?> body = objectMapper.readValue(res.getContentAsString(), Map.class);
        assertThat(body.get("errorCode")).isEqualTo("UNAUTHORIZED");
        assertThat(body.get("message")).isEqualTo("로그인이 필요합니다.");
    }

    @Test
    void 권한_없는_요청은_ACCESS_DENIED_본문과_403() throws Exception {
        MockHttpServletResponse res = new MockHttpServletResponse();
        new ApiSecurityErrorHandler(objectMapper).handle(
                new MockHttpServletRequest("GET", "/api/x"), res, new AccessDeniedException("x"));

        assertThat(res.getStatus()).isEqualTo(403);
        assertThat(objectMapper.readValue(res.getContentAsString(), Map.class).get("errorCode")).isEqualTo("ACCESS_DENIED");
    }

    @Test
    void 기본_오류_응답에_errorCode와_message가_들어가고_timestamp는_빠진다() {
        MockHttpServletRequest req = new MockHttpServletRequest("GET", "/api/no-such");
        req.setAttribute("jakarta.servlet.error.status_code", 404);
        req.setAttribute("jakarta.servlet.error.request_uri", "/api/no-such");

        Map<String, Object> attrs = new PassqlErrorAttributes()
                .getErrorAttributes(new ServletWebRequest(req), ErrorAttributeOptions.defaults());

        assertThat(attrs).containsEntry("errorCode", "RESOURCE_NOT_FOUND")
                .containsEntry("status", 404)
                .containsEntry("path", "/api/no-such")
                .doesNotContainKeys("timestamp", "error");
    }
}
