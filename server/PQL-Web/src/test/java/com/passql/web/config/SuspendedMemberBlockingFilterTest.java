package com.passql.web.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.member.constant.MemberRole;
import com.passql.member.service.MemberSuspensionService;
import jakarta.servlet.FilterChain;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/** 제재 회원 공통 차단 (#470): 회원 API 403, 예외 경로(인증·meta·탈퇴) 통과 */
class SuspendedMemberBlockingFilterTest {

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final MemberSuspensionService memberSuspensionService = mock(MemberSuspensionService.class);
    private final SuspendedMemberBlockingFilter filter =
            new SuspendedMemberBlockingFilter(memberSuspensionService, new ApiSecurityErrorHandler(objectMapper));
    private final UUID suspendedMemberUuid = UUID.randomUUID();

    @BeforeEach
    void loginAsSuspendedMember() {
        LoginMember loginMember = new LoginMember(suspendedMemberUuid, MemberRole.USER);
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(loginMember, null, List.of()));
        when(memberSuspensionService.isMemberBlockedBySuspension(suspendedMemberUuid)).thenReturn(true);
    }

    @AfterEach
    void clearSecurityContext() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void 제재_회원의_회원_API는_MEMBER_SUSPENDED_403() throws Exception {
        MockHttpServletResponse response = runFilter("POST", "/api/questions/x/submit");

        assertThat(response.getStatus()).isEqualTo(403);
        Map<?, ?> body = objectMapper.readValue(response.getContentAsString(), Map.class);
        assertThat(body.get("errorCode")).isEqualTo("MEMBER_SUSPENDED");
    }

    @Test
    void 제재_회원도_재발급_공개_meta_탈퇴는_통과() throws Exception {
        assertThat(runFilter("POST", "/api/auth/reissue").getStatus()).isEqualTo(200);
        assertThat(runFilter("GET", "/api/meta/topics").getStatus()).isEqualTo(200);
        assertThat(runFilter("DELETE", "/api/members/me").getStatus()).isEqualTo(200);
    }

    @Test
    void 제재_아닌_회원은_통과() throws Exception {
        when(memberSuspensionService.isMemberBlockedBySuspension(suspendedMemberUuid)).thenReturn(false);

        assertThat(runFilter("GET", "/api/members/me").getStatus()).isEqualTo(200);
    }

    /** 필터 통과 시 체인 도달 여부를 200 으로 표시 */
    private MockHttpServletResponse runFilter(String method, String path) throws Exception {
        MockHttpServletResponse response = new MockHttpServletResponse();
        FilterChain chain = (request, chainResponse) -> ((MockHttpServletResponse) chainResponse).setStatus(200);
        response.setStatus(0);
        filter.doFilter(new MockHttpServletRequest(method, path), response, chain);
        return response;
    }
}
