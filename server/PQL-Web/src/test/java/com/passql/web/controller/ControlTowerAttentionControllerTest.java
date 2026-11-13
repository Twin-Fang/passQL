package com.passql.web.controller;

import com.passql.application.billing.PlayRefundCheckService;
import com.passql.application.controltower.ControlTowerAttentionProperties;
import com.passql.application.controltower.ControlTowerAttentionService;
import com.passql.application.controltower.ControlTowerAttentionTokenVerifier;
import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.common.exception.GlobalExceptionHandler;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.constant.FeedbackStatus;
import com.passql.meta.service.AppSettingService;
import com.passql.meta.service.FeedbackService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.info.BuildProperties;
import org.springframework.http.MediaType;
import org.springframework.mock.env.MockEnvironment;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.EnumMap;
import java.util.Map;

import static org.hamcrest.Matchers.matchesPattern;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * GET /control/attention 응답 (#959): 401 토큰 없음·틀림, 이전 토큰 허용, 404 꺼짐, 200 attention v1 JSON 모양
 */
class ControlTowerAttentionControllerTest {

    private static final String ATTENTION_PATH = "/control/attention";
    private static final String TOKEN_HEADER = "X-Control-Token";
    private static final String TOKEN = "control-token";
    private static final String PREVIOUS_TOKEN = "previous-token";
    // generated_at: UTC ISO 8601 문자열 (2026-11-08T12:00:00.123Z)
    private static final String UTC_ISO_INSTANT_PATTERN = "\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d{1,9})?Z";

    private final AppSettingService appSettingService = mock(AppSettingService.class);
    private final FeedbackService feedbackService = mock(FeedbackService.class);
    private MockMvc mockMvc;

    @BeforeEach
    @SuppressWarnings("unchecked")
    void setUp() {
        ControlTowerAttentionProperties properties =
            new ControlTowerAttentionProperties(TOKEN, PREVIOUS_TOKEN, "https://api.passql.example");
        ObjectProvider<BuildProperties> buildPropertiesProvider = mock(ObjectProvider.class);
        ControlTowerAttentionService service = new ControlTowerAttentionService(properties,
            new ControlTowerAttentionTokenVerifier(properties), feedbackService, appSettingService,
            mock(FeatureAccessPolicy.class), mock(PlayRefundCheckService.class), new MockEnvironment(), buildPropertiesProvider);
        mockMvc = MockMvcBuilders.standaloneSetup(new ControlTowerAttentionController(service))
            .setControllerAdvice(new GlobalExceptionHandler())
            .build();

        givenIntegrationEnabled(true);
        Map<FeedbackStatus, Long> countByStatus = new EnumMap<>(FeedbackStatus.class);
        countByStatus.put(FeedbackStatus.PENDING, 2L);
        countByStatus.put(FeedbackStatus.REVIEWED, 0L);
        countByStatus.put(FeedbackStatus.APPLIED, 4L);
        when(feedbackService.countByStatus()).thenReturn(countByStatus);
    }

    @Test
    void 토큰이_없거나_틀리면_401() throws Exception {
        mockMvc.perform(get(ATTENTION_PATH)).andExpect(status().isUnauthorized());
        mockMvc.perform(get(ATTENTION_PATH).header(TOKEN_HEADER, "wrong-token")).andExpect(status().isUnauthorized());
    }

    @Test
    void 이전_토큰도_200() throws Exception {
        mockMvc.perform(get(ATTENTION_PATH).header(TOKEN_HEADER, PREVIOUS_TOKEN)).andExpect(status().isOk());
    }

    @Test
    void 연동이_꺼져_있으면_404() throws Exception {
        givenIntegrationEnabled(false);

        mockMvc.perform(get(ATTENTION_PATH).header(TOKEN_HEADER, TOKEN)).andExpect(status().isNotFound());
    }

    @Test
    void 정상_수집은_attention_v1_모양과_두_항목을_돌려준다() throws Exception {
        mockMvc.perform(get(ATTENTION_PATH).header(TOKEN_HEADER, TOKEN))
            .andExpect(status().isOk())
            .andExpect(header().string("Cache-Control", "no-store"))
            .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
            .andExpect(jsonPath("$.schema").value("attention"))
            .andExpect(jsonPath("$.version").value("1.0"))
            .andExpect(jsonPath("$.generated_at").value(matchesPattern(UTC_ISO_INSTANT_PATTERN)))
            .andExpect(jsonPath("$.source.app").value("passql-server"))
            .andExpect(jsonPath("$.source.environment").value("development"))
            .andExpect(jsonPath("$.source.admin_base_url").value("https://api.passql.example"))
            .andExpect(jsonPath("$.source.app_version").doesNotExist())
            .andExpect(jsonPath("$.items.length()").value(2))
            .andExpect(jsonPath("$.items[0].key").value("feedback.new"))
            .andExpect(jsonPath("$.items[0].kind").value("count"))
            .andExpect(jsonPath("$.items[0].level").value("info"))
            .andExpect(jsonPath("$.items[0].count").value(2))
            .andExpect(jsonPath("$.items[0].total").value(6))
            .andExpect(jsonPath("$.items[0].admin_url").value("/admin/feedbacks?status=PENDING"))
            .andExpect(jsonPath("$.items[1].key").value("feedback.in_progress"))
            .andExpect(jsonPath("$.items[1].level").value("ok"))
            .andExpect(jsonPath("$.items[1].count").value(0))
            .andExpect(jsonPath("$.items[1].total").doesNotExist());
    }

    private void givenIntegrationEnabled(boolean isEnabled) {
        when(appSettingService.getBooleanOrDefault(eq(AppSettingKeys.CONTROL_TOWER_ATTENTION_ENABLED), anyBoolean()))
            .thenReturn(isEnabled);
    }
}
