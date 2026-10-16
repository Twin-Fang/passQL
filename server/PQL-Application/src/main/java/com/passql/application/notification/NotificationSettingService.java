package com.passql.application.notification;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 알림 설정(app_setting): 보관 기간, 자동 알림 2종 사용 여부 조회·저장
 * 저장은 AppSettingService.save 경유 (값 형식 검사, 설정 변경 감사 로그)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class NotificationSettingService {

    // 알림 보관 기간 기본값·허용 범위 (일)
    public static final int DEFAULT_RETENTION_DAYS = 90;
    public static final int MIN_RETENTION_DAYS = 7;
    public static final int MAX_RETENTION_DAYS = 365;

    private final AppSettingService appSettingService;

    /** 관리자 화면용 설정 3개: 보관 일수, 신고 처리 결과 알림, 오늘의 세트 리마인드 */
    public record NotificationSettings(int retentionDays, boolean isReportResolvedEnabled, boolean isDailySetReminderEnabled) {
    }

    public NotificationSettings getSettings() {
        return new NotificationSettings(getRetentionDays(), isReportResolvedEnabled(),
                appSettingService.getBooleanOrDefault(AppSettingKeys.NOTIFICATION_DAILY_SET_REMINDER_ENABLED, false));
    }

    public int getRetentionDays() {
        int configuredDays = appSettingService.getIntOrDefault(AppSettingKeys.NOTIFICATION_RETENTION_DAYS, DEFAULT_RETENTION_DAYS);
        return isRetentionDaysInRange(configuredDays) ? configuredDays : DEFAULT_RETENTION_DAYS;
    }

    public boolean isReportResolvedEnabled() {
        return appSettingService.getBooleanOrDefault(AppSettingKeys.NOTIFICATION_REPORT_RESOLVED_ENABLED, true);
    }

    /** 저장: 보관 일수 범위 검증 > 바뀐 키만 저장 */
    @Transactional
    public void updateSettings(NotificationSettings requested) {
        if (!isRetentionDaysInRange(requested.retentionDays())) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE,
                    "보관 기간은 " + MIN_RETENTION_DAYS + "~" + MAX_RETENTION_DAYS + "일이어야 합니다.");
        }
        NotificationSettings current = getSettings();
        if (current.retentionDays() != requested.retentionDays()) {
            appSettingService.save(AppSettingKeys.NOTIFICATION_RETENTION_DAYS, String.valueOf(requested.retentionDays()));
        }
        if (current.isReportResolvedEnabled() != requested.isReportResolvedEnabled()) {
            appSettingService.save(AppSettingKeys.NOTIFICATION_REPORT_RESOLVED_ENABLED,
                    String.valueOf(requested.isReportResolvedEnabled()));
        }
        if (current.isDailySetReminderEnabled() != requested.isDailySetReminderEnabled()) {
            appSettingService.save(AppSettingKeys.NOTIFICATION_DAILY_SET_REMINDER_ENABLED,
                    String.valueOf(requested.isDailySetReminderEnabled()));
        }
    }

    private static boolean isRetentionDaysInRange(int retentionDays) {
        return retentionDays >= MIN_RETENTION_DAYS && retentionDays <= MAX_RETENTION_DAYS;
    }
}
