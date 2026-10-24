package com.passql.application.monitor;

import com.passql.ai.dto.AiStats;
import com.passql.ai.service.AiCallLogService;
import com.passql.application.statistics.AdminAiStatisticsService;
import com.passql.application.statistics.dto.AiUsageTotal;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import com.passql.meta.service.ServerErrorLogService;
import org.junit.jupiter.api.Test;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 장애 알림: 꺼짐·웹훅 없음 무발송, 기준 초과 발송, 대기 시간 중 재발송 없음, 예산은 달마다 1회 */
class MonitorAlertServiceTest {

    private static final String WEBHOOK_URL = "https://hooks.slack.com/services/T000/B000/XXXX";

    private final AppSettingService appSettingService = mock(AppSettingService.class);
    private final ServerErrorLogService serverErrorLogService = mock(ServerErrorLogService.class);
    private final AiCallLogService aiCallLogService = mock(AiCallLogService.class);
    private final AdminAiStatisticsService adminAiStatisticsService = mock(AdminAiStatisticsService.class);
    private final SlackWebhookClient slackWebhookClient = mock(SlackWebhookClient.class);
    private final MonitorAlertService service = new MonitorAlertService(
            appSettingService, serverErrorLogService, aiCallLogService, adminAiStatisticsService, slackWebhookClient);

    private void givenEnabledWithWebhook() {
        when(appSettingService.getBooleanOrDefault(AppSettingKeys.MONITOR_ALERT_ENABLED, false)).thenReturn(true);
        when(appSettingService.getSecret(AppSettingKeys.MONITOR_ALERT_SLACK_WEBHOOK_URL)).thenReturn(WEBHOOK_URL);
        // 설정 기본값 그대로 사용
        when(appSettingService.getIntOrDefault(anyString(), anyInt())).thenAnswer(invocation -> invocation.getArgument(1));
        when(aiCallLogService.getStatsSince(any())).thenReturn(AiStats.empty());
        when(adminAiStatisticsService.getMonthlyBudgetUsd()).thenReturn(10.0);
        when(adminAiStatisticsService.summarizeUsage(any(), any())).thenReturn(new AiUsageTotal(0, 0, 0));
        when(slackWebhookClient.sendText(anyString(), anyString())).thenReturn(true);
    }

    @Test
    void 꺼져_있으면_아무것도_보내지_않는다() {
        when(appSettingService.getBooleanOrDefault(AppSettingKeys.MONITOR_ALERT_ENABLED, false)).thenReturn(false);

        service.checkAndNotify();

        verify(slackWebhookClient, never()).sendText(anyString(), anyString());
    }

    @Test
    void 웹훅_주소가_비어_있으면_보내지_않는다() {
        when(appSettingService.getBooleanOrDefault(AppSettingKeys.MONITOR_ALERT_ENABLED, false)).thenReturn(true);
        when(appSettingService.getSecret(AppSettingKeys.MONITOR_ALERT_SLACK_WEBHOOK_URL)).thenReturn("");

        service.checkAndNotify();

        verify(slackWebhookClient, never()).sendText(anyString(), anyString());
    }

    @Test
    void 서버_오류가_기준_이상이면_보내고_대기_시간_안에는_다시_보내지_않는다() {
        givenEnabledWithWebhook();
        when(serverErrorLogService.countSince(any())).thenReturn(12L);

        service.checkAndNotify();
        service.checkAndNotify();

        verify(slackWebhookClient, times(1)).sendText(eq(WEBHOOK_URL), anyString());
    }

    @Test
    void 서버_오류가_기준_미만이면_보내지_않는다() {
        givenEnabledWithWebhook();
        when(serverErrorLogService.countSince(any())).thenReturn(3L);

        service.checkAndNotify();

        verify(slackWebhookClient, never()).sendText(anyString(), anyString());
    }

    @Test
    void AI_실패율이_기준_이상이어도_호출이_5건_미만이면_보내지_않는다() {
        givenEnabledWithWebhook();
        when(serverErrorLogService.countSince(any())).thenReturn(0L);
        when(aiCallLogService.getStatsSince(any())).thenReturn(new AiStats(4, 0, 4, 100, 100));

        service.checkAndNotify();

        verify(slackWebhookClient, never()).sendText(anyString(), anyString());
    }

    @Test
    void AI_실패율이_기준_이상이면_보낸다() {
        givenEnabledWithWebhook();
        when(serverErrorLogService.countSince(any())).thenReturn(0L);
        when(aiCallLogService.getStatsSince(any())).thenReturn(new AiStats(10, 4, 6, 100, 100));

        service.checkAndNotify();

        verify(slackWebhookClient, times(1)).sendText(eq(WEBHOOK_URL), anyString());
    }

    @Test
    void 예산_초과_알림은_달마다_한_번만_보낸다() {
        givenEnabledWithWebhook();
        when(serverErrorLogService.countSince(any())).thenReturn(0L);
        when(adminAiStatisticsService.summarizeUsage(any(), any())).thenReturn(new AiUsageTotal(100, 0, 12.5));

        service.checkAndNotify();
        service.checkAndNotify();

        verify(slackWebhookClient, times(1)).sendText(eq(WEBHOOK_URL), anyString());
    }
}
