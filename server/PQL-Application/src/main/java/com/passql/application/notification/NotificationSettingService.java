package com.passql.application.notification;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.constant.AppSettingValueRanges;
import com.passql.meta.service.AppSettingService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 알림 설정(app_setting): 보관 기간, 신고 처리 결과 알림 사용 여부, 자동 알림 하루 상한 조회·저장
 * 저장은 AppSettingService.save 경유 (값 형식 검사, 설정 변경 감사 로그)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class NotificationSettingService {

    // 알림 보관 기간 기본값·허용 범위 (일)
    public static final int DEFAULT_RETENTION_DAYS = 90;
    public static final int MIN_RETENTION_DAYS = AppSettingValueRanges.NOTIFICATION_RETENTION_DAYS_MINIMUM;
    public static final int MAX_RETENTION_DAYS = AppSettingValueRanges.NOTIFICATION_RETENTION_DAYS_MAXIMUM;
    // 회원당 하루 자동 알림 기본값·허용 범위 (건)
    public static final int DEFAULT_AUTO_DAILY_LIMIT_PER_MEMBER = 1;
    public static final int MIN_AUTO_DAILY_LIMIT_PER_MEMBER =
            AppSettingValueRanges.AUTO_NOTIFICATION_DAILY_LIMIT_PER_MEMBER_MINIMUM;
    public static final int MAX_AUTO_DAILY_LIMIT_PER_MEMBER =
            AppSettingValueRanges.AUTO_NOTIFICATION_DAILY_LIMIT_PER_MEMBER_MAXIMUM;

    private final AppSettingService appSettingService;

    /** 관리자 화면용 설정 2개: 보관 일수, 신고 처리 결과 알림 (자동 알림은 AutoNotificationService 규칙으로 제어) */
    public record NotificationSettings(int retentionDays, boolean isReportResolvedEnabled) {
    }

    public NotificationSettings getSettings() {
        return new NotificationSettings(getRetentionDays(), isReportResolvedEnabled());
    }

    public int getRetentionDays() {
        int configuredDays = appSettingService.getIntOrDefault(AppSettingKeys.NOTIFICATION_RETENTION_DAYS, DEFAULT_RETENTION_DAYS);
        return isRetentionDaysInRange(configuredDays) ? configuredDays : DEFAULT_RETENTION_DAYS;
    }

    public boolean isReportResolvedEnabled() {
        return appSettingService.getBooleanOrDefault(AppSettingKeys.NOTIFICATION_REPORT_RESOLVED_ENABLED, true);
    }

    /** 회원당 하루 자동 알림 상한 (범위 밖·형식 오류면 기본 1건) */
    public int getAutoDailyLimitPerMember() {
        int configuredLimit = appSettingService.getIntOrDefault(AppSettingKeys.NOTIFICATION_AUTO_DAILY_LIMIT_PER_MEMBER,
                DEFAULT_AUTO_DAILY_LIMIT_PER_MEMBER);
        return isAutoDailyLimitInRange(configuredLimit) ? configuredLimit : DEFAULT_AUTO_DAILY_LIMIT_PER_MEMBER;
    }

    /** 하루 상한 저장: 범위 검증 > 저장 (감사 로그는 AppSettingService.save) */
    @Transactional
    public void updateAutoDailyLimitPerMember(Integer dailyLimitPerMember) {
        if (dailyLimitPerMember == null || !isAutoDailyLimitInRange(dailyLimitPerMember)) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "하루 자동 알림 상한은 "
                    + MIN_AUTO_DAILY_LIMIT_PER_MEMBER + "~" + MAX_AUTO_DAILY_LIMIT_PER_MEMBER + "건이어야 합니다.");
        }
        appSettingService.save(AppSettingKeys.NOTIFICATION_AUTO_DAILY_LIMIT_PER_MEMBER, String.valueOf(dailyLimitPerMember));
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
    }

    private static boolean isAutoDailyLimitInRange(int dailyLimitPerMember) {
        return dailyLimitPerMember >= MIN_AUTO_DAILY_LIMIT_PER_MEMBER && dailyLimitPerMember <= MAX_AUTO_DAILY_LIMIT_PER_MEMBER;
    }

    private static boolean isRetentionDaysInRange(int retentionDays) {
        return retentionDays >= MIN_RETENTION_DAYS && retentionDays <= MAX_RETENTION_DAYS;
    }
}
