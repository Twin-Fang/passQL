package com.passql.application.monitor;

import com.passql.ai.dto.AiStats;
import com.passql.ai.service.AiCallLogService;
import com.passql.application.statistics.AdminAiStatisticsService;
import com.passql.application.statistics.dto.AiUsageTotal;
import com.passql.common.exception.CustomException;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import com.passql.meta.service.ServerErrorLogService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.EnumMap;
import java.util.Map;

/**
 * 모니터링 장애 알림: 서버 오류 급증, AI 실패율 초과, AI 월 예산 초과 > Slack 발송
 * 기본 꺼짐 (monitor.alert.enabled), 같은 종류는 대기 시간 동안 재발송 안 함 (예산 초과는 달마다 1회)
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class MonitorAlertService {

    // 장애 판정 기본값 (설정 행 없음·형식 오류 시)
    static final int DEFAULT_WINDOW_MINUTES = 10;
    static final int DEFAULT_SERVER_ERROR_THRESHOLD_COUNT = 10;
    static final int DEFAULT_AI_FAILURE_RATE_THRESHOLD_PERCENT = 50;
    static final int DEFAULT_AI_BUDGET_THRESHOLD_PERCENT = 100;
    static final int DEFAULT_COOLDOWN_MINUTES = 60;
    // AI 실패율 판정에 필요한 최소 호출 수 (표본이 너무 적으면 판정 안 함)
    static final long MIN_AI_CALL_COUNT_FOR_FAILURE_RATE = 5;

    // 알림 종류
    enum AlertKind { SERVER_ERROR_SPIKE, AI_FAILURE_RATE, AI_BUDGET_EXCEEDED }

    private final AppSettingService appSettingService;
    private final ServerErrorLogService serverErrorLogService;
    private final AiCallLogService aiCallLogService;
    private final AdminAiStatisticsService adminAiStatisticsService;
    private final SlackWebhookClient slackWebhookClient;

    // 종류별 마지막 발송 시각 (서버 1대 기준, 재시작하면 초기화)
    private final Map<AlertKind, LocalDateTime> lastSentAtByKind = new EnumMap<>(AlertKind.class);
    // 예산 초과 알림을 보낸 달
    private YearMonth lastBudgetAlertMonth;

    /** 켜짐·웹훅 확인 > 종류별 판정 > 조건 충족 시 발송 (스케줄러가 주기 호출) */
    public synchronized void checkAndNotify() {
        if (!appSettingService.getBooleanOrDefault(AppSettingKeys.MONITOR_ALERT_ENABLED, false)) {
            return;
        }
        String webhookUrl = readWebhookUrlOrEmpty();
        if (!SlackWebhookClient.isAllowedWebhookUrl(webhookUrl)) {
            return;
        }
        LocalDateTime now = LocalDateTime.now();
        int windowMinutes = appSettingService.getIntOrDefault(AppSettingKeys.MONITOR_ALERT_WINDOW_MINUTES, DEFAULT_WINDOW_MINUTES);
        LocalDateTime windowStart = now.minusMinutes(windowMinutes);

        notifyServerErrorSpike(webhookUrl, now, windowStart, windowMinutes);
        notifyAiFailureRate(webhookUrl, now, windowStart, windowMinutes);
        notifyAiBudgetExceeded(webhookUrl, now);
    }

    // 서버 오류 건수 >= 기준
    private void notifyServerErrorSpike(String webhookUrl, LocalDateTime now, LocalDateTime windowStart, int windowMinutes) {
        int thresholdCount = appSettingService.getIntOrDefault(
                AppSettingKeys.MONITOR_ALERT_SERVER_ERROR_THRESHOLD_COUNT, DEFAULT_SERVER_ERROR_THRESHOLD_COUNT);
        long serverErrorCount = serverErrorLogService.countSince(windowStart);
        if (serverErrorCount >= thresholdCount && isCooldownOver(AlertKind.SERVER_ERROR_SPIKE, now)) {
            sendAndRecord(webhookUrl, AlertKind.SERVER_ERROR_SPIKE, now,
                    "[passQL 장애 알림] 서버 오류 " + serverErrorCount + "건 (최근 " + windowMinutes + "분, 기준 " + thresholdCount + "건)");
        }
    }

    // AI 호출 실패율 >= 기준 (표본 5건 이상)
    private void notifyAiFailureRate(String webhookUrl, LocalDateTime now, LocalDateTime windowStart, int windowMinutes) {
        int thresholdPercent = appSettingService.getIntOrDefault(
                AppSettingKeys.MONITOR_ALERT_AI_FAILURE_RATE_THRESHOLD_PERCENT, DEFAULT_AI_FAILURE_RATE_THRESHOLD_PERCENT);
        AiStats aiStats = aiCallLogService.getStatsSince(windowStart);
        if (aiStats.totalCallCount() >= MIN_AI_CALL_COUNT_FOR_FAILURE_RATE
                && aiStats.failureRatePercent() >= thresholdPercent
                && isCooldownOver(AlertKind.AI_FAILURE_RATE, now)) {
            sendAndRecord(webhookUrl, AlertKind.AI_FAILURE_RATE, now,
                    "[passQL 장애 알림] AI 호출 실패율 " + Math.round(aiStats.failureRatePercent()) + "% ("
                            + aiStats.failureCount() + "/" + aiStats.totalCallCount() + "건, 최근 " + windowMinutes
                            + "분, 기준 " + thresholdPercent + "%)");
        }
    }

    // 이번 달 추정 비용 / 월 예산 >= 기준 (달마다 1회)
    private void notifyAiBudgetExceeded(String webhookUrl, LocalDateTime now) {
        YearMonth thisMonth = YearMonth.from(now);
        if (thisMonth.equals(lastBudgetAlertMonth)) {
            return;
        }
        double monthlyBudgetUsd = adminAiStatisticsService.getMonthlyBudgetUsd();
        if (monthlyBudgetUsd <= 0) {
            return;
        }
        int thresholdPercent = appSettingService.getIntOrDefault(
                AppSettingKeys.MONITOR_ALERT_AI_BUDGET_THRESHOLD_PERCENT, DEFAULT_AI_BUDGET_THRESHOLD_PERCENT);
        AiUsageTotal monthUsage = adminAiStatisticsService.summarizeUsage(
                thisMonth.atDay(1).atStartOfDay(), thisMonth.plusMonths(1).atDay(1).atStartOfDay());
        double usedPercent = monthUsage.estimatedCostUsd() / monthlyBudgetUsd * 100;
        if (usedPercent >= thresholdPercent && slackWebhookClient.sendText(webhookUrl,
                "[passQL 장애 알림] AI 월 예산 " + Math.round(usedPercent) + "% 사용 ($"
                        + String.format("%.2f", monthUsage.estimatedCostUsd()) + " / $" + String.format("%.2f", monthlyBudgetUsd)
                        + ", 기준 " + thresholdPercent + "%)")) {
            lastBudgetAlertMonth = thisMonth;
            log.info("[monitor alert] sent : kind={}, usedPercent={}", AlertKind.AI_BUDGET_EXCEEDED, Math.round(usedPercent));
        }
    }

    private boolean isCooldownOver(AlertKind kind, LocalDateTime now) {
        LocalDateTime lastSentAt = lastSentAtByKind.get(kind);
        int cooldownMinutes = appSettingService.getIntOrDefault(AppSettingKeys.MONITOR_ALERT_COOLDOWN_MINUTES, DEFAULT_COOLDOWN_MINUTES);
        return lastSentAt == null || lastSentAt.plusMinutes(cooldownMinutes).isBefore(now);
    }

    // 발송 성공 시에만 마지막 발송 시각 기록 (실패하면 다음 주기에 재시도)
    private void sendAndRecord(String webhookUrl, AlertKind kind, LocalDateTime now, String text) {
        if (slackWebhookClient.sendText(webhookUrl, text)) {
            lastSentAtByKind.put(kind, now);
            log.info("[monitor alert] sent : kind={}", kind);
        }
    }

    // 웹훅 URL (SECRET 복호화, 행 없음·복호화 실패·조회 장애는 빈 값)
    private String readWebhookUrlOrEmpty() {
        try {
            return appSettingService.getSecret(AppSettingKeys.MONITOR_ALERT_SLACK_WEBHOOK_URL);
        } catch (CustomException exception) {
            // 행 없음은 미설정 정상 상태, 복호화 실패는 SettingSecretCipher 가 이미 기록
            return "";
        } catch (RuntimeException exception) {
            log.warn("[monitor alert] webhook url read failed : alert skipped : cause={}", exception.getClass().getSimpleName());
            return "";
        }
    }
}
