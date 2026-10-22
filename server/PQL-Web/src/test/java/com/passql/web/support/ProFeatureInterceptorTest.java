package com.passql.web.support;

import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.application.entitlement.ProFeature;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.GlobalExceptionHandler;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.member.constant.MemberRole;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** 프로 기능 잠금 인터셉터: 어노테이션 엔드포인트만 정책 확인 (무료 403 PRO_REQUIRED) */
class ProFeatureInterceptorTest {

    private static final UUID MEMBER_UUID = UUID.randomUUID();

    private FeatureAccessPolicy featureAccessPolicy;
    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        featureAccessPolicy = mock(FeatureAccessPolicy.class);
        mockMvc = MockMvcBuilders.standaloneSetup(new TestController())
            .addInterceptors(new ProFeatureInterceptor(featureAccessPolicy))
            .setControllerAdvice(new GlobalExceptionHandler())
            .build();
        SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken(
            new LoginMember(MEMBER_UUID, MemberRole.USER), null, List.of()));
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void annotatedEndpoint_whenFree_returns403ProRequired() throws Exception {
        doThrow(new CustomException(ErrorCode.PRO_REQUIRED))
            .when(featureAccessPolicy).requireFeature(MEMBER_UUID, ProFeature.SQL_EXECUTION);

        mockMvc.perform(get("/api/test/locked").accept(MediaType.APPLICATION_JSON))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.errorCode").value("PRO_REQUIRED"));
    }

    @Test
    void annotatedEndpoint_whenPro_passes() throws Exception {
        mockMvc.perform(get("/api/test/locked"))
            .andExpect(status().isOk());

        verify(featureAccessPolicy).requireFeature(MEMBER_UUID, ProFeature.SQL_EXECUTION);
    }

    @Test
    void unannotatedEndpoint_neverCallsPolicy() throws Exception {
        mockMvc.perform(get("/api/test/open"))
            .andExpect(status().isOk());

        verifyNoInteractions(featureAccessPolicy);
    }

    @Test
    void annotatedEndpoint_withoutMember_whenBillingEnabled_returns403ProRequired() throws Exception {
        SecurityContextHolder.clearContext();
        when(featureAccessPolicy.isBillingEnabled()).thenReturn(true);

        mockMvc.perform(get("/api/test/locked").accept(MediaType.APPLICATION_JSON))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.errorCode").value("PRO_REQUIRED"));
        verify(featureAccessPolicy, never()).requireFeature(any(), any());
    }

    @RestController
    @RequestMapping("/api/test")
    static class TestController {

        @RequiresProFeature(ProFeature.SQL_EXECUTION)
        @GetMapping("/locked")
        String locked() {
            return "ok";
        }

        @GetMapping("/open")
        String open() {
            return "ok";
        }
    }
}
