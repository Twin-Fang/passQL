package com.passql.meta.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.dto.AppConfigResponse;
import com.passql.meta.dto.AppLinksResponse;
import com.passql.meta.dto.AppMaintenanceResponse;
import com.passql.meta.dto.AppOperationSettingsRequest;
import com.passql.meta.dto.AppOperationSettingsResponse;
import com.passql.meta.dto.AppPlatformVersionResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.regex.Pattern;

/**
 * 앱 운영 설정: 앱 시작 설정 조회, 점검 여부 판정, 관리자 설정 저장
 * 원본은 app_setting (AppSettingKeys), 행 없음·잘못된 값은 차단 없는 기본값으로 읽음
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AppOperationService {

    // 차단·안내 없음을 뜻하는 버전 (모든 앱 버전이 이 이상)
    public static final String NO_REQUIREMENT_VERSION = "0.0.0";
    // 버전 형식: 숫자 3개 (x.y.z)
    private static final Pattern VERSION_PATTERN = Pattern.compile("\\d{1,4}\\.\\d{1,4}\\.\\d{1,4}");
    // 예약 시각은 관리자가 한국 시각으로 입력 > KST 기준 비교
    private static final ZoneId KST = ZoneId.of("Asia/Seoul");
    // 점검 문구 최대 길이 (문자 수)
    private static final int MAINTENANCE_MESSAGE_MAX_LENGTH = 500;

    private final AppSettingService appSettingService;
    private final AppNoticeService appNoticeService;

    /**
     * 앱 시작 설정: 플랫폼별 버전 정책 + 점검 상태 + 노출 공지 + Android 결제 스위치
     */
    public AppConfigResponse getAppConfig() {
        AppLinksResponse storeLinks = appSettingService.getAppLinks();
        return new AppConfigResponse(
                new AppPlatformVersionResponse(
                        readVersion(AppSettingKeys.APP_MINIMUM_VERSION_IOS),
                        readVersion(AppSettingKeys.APP_RECOMMENDED_VERSION_IOS),
                        storeLinks.iosUrl()),
                new AppPlatformVersionResponse(
                        readVersion(AppSettingKeys.APP_MINIMUM_VERSION_ANDROID),
                        readVersion(AppSettingKeys.APP_RECOMMENDED_VERSION_ANDROID),
                        storeLinks.androidUrl()),
                new AppMaintenanceResponse(isUnderMaintenance(), readSettingOrDefault(AppSettingKeys.APP_MAINTENANCE_MESSAGE, "")),
                appNoticeService.getVisibleNotices(),
                isAndroidBillingEnabled()
        );
    }

    /**
     * 점검 중 여부: 수동 스위치 켜짐 또는 예약 구간 안 (설정 조회 실패 시 false — 설정 장애로 서비스 전체가 막히지 않게)
     */
    public boolean isUnderMaintenance() {
        return isMaintenanceSwitchOn() || isInScheduledMaintenance(LocalDateTime.now(KST));
    }

    private boolean isMaintenanceSwitchOn() {
        return Boolean.parseBoolean(readSettingOrDefault(AppSettingKeys.APP_MAINTENANCE_ENABLED, "false").trim());
    }

    /** 예약 구간 안: 시작 <= 지금 < 종료 (종료 비면 수동 해제 전까지, 시작 없으면 예약 없음) */
    private boolean isInScheduledMaintenance(LocalDateTime now) {
        LocalDateTime startsAt = readScheduleTime(AppSettingKeys.APP_MAINTENANCE_STARTS_AT);
        LocalDateTime endsAt = readScheduleTime(AppSettingKeys.APP_MAINTENANCE_ENDS_AT);
        return startsAt != null && !now.isBefore(startsAt) && (endsAt == null || now.isBefore(endsAt));
    }

    /** 저장된 예약 시각 (빈 값·형식 오류 > null) */
    private LocalDateTime readScheduleTime(String key) {
        String stored = readSettingOrDefault(key, "").trim();
        if (stored.isEmpty()) {
            return null;
        }
        try {
            return LocalDateTime.parse(stored);
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    /**
     * Android 결제 사용 여부 (행 없음·저장소 장애 > false, 결제 없이 전부 열린 상태)
     */
    private boolean isAndroidBillingEnabled() {
        return Boolean.parseBoolean(readSettingOrDefault(AppSettingKeys.BILLING_ANDROID_ENABLED, "false").trim());
    }

    public AppOperationSettingsResponse getOperationSettings() {
        return new AppOperationSettingsResponse(
                readVersion(AppSettingKeys.APP_MINIMUM_VERSION_IOS),
                readVersion(AppSettingKeys.APP_RECOMMENDED_VERSION_IOS),
                readVersion(AppSettingKeys.APP_MINIMUM_VERSION_ANDROID),
                readVersion(AppSettingKeys.APP_RECOMMENDED_VERSION_ANDROID),
                isMaintenanceSwitchOn(),
                readSettingOrDefault(AppSettingKeys.APP_MAINTENANCE_MESSAGE, ""),
                readScheduleTime(AppSettingKeys.APP_MAINTENANCE_STARTS_AT),
                readScheduleTime(AppSettingKeys.APP_MAINTENANCE_ENDS_AT),
                isUnderMaintenance()
        );
    }

    /**
     * 관리자 설정 저장: 형식 검증(버전 4개, 문구 길이) > 6개 키 저장
     */
    @Transactional
    public void updateOperationSettings(AppOperationSettingsRequest request) {
        // 검증 먼저 (일부만 저장되는 일 방지)
        String iosMinimum = requireVersion(request.iosMinimumVersion());
        String iosRecommended = requireVersion(request.iosRecommendedVersion());
        String androidMinimum = requireVersion(request.androidMinimumVersion());
        String androidRecommended = requireVersion(request.androidRecommendedVersion());
        String message = request.maintenanceMessage() == null ? "" : request.maintenanceMessage().trim();
        if (message.length() > MAINTENANCE_MESSAGE_MAX_LENGTH) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }
        boolean isMaintenanceEnabled = Boolean.TRUE.equals(request.isMaintenanceEnabled());
        validateMaintenancePeriod(request.maintenanceStartsAt(), request.maintenanceEndsAt());

        // 저장
        appSettingService.save(AppSettingKeys.APP_MINIMUM_VERSION_IOS, iosMinimum);
        appSettingService.save(AppSettingKeys.APP_RECOMMENDED_VERSION_IOS, iosRecommended);
        appSettingService.save(AppSettingKeys.APP_MINIMUM_VERSION_ANDROID, androidMinimum);
        appSettingService.save(AppSettingKeys.APP_RECOMMENDED_VERSION_ANDROID, androidRecommended);
        appSettingService.save(AppSettingKeys.APP_MAINTENANCE_ENABLED, String.valueOf(isMaintenanceEnabled));
        appSettingService.save(AppSettingKeys.APP_MAINTENANCE_MESSAGE, message);
        appSettingService.save(AppSettingKeys.APP_MAINTENANCE_STARTS_AT, toScheduleText(request.maintenanceStartsAt()));
        appSettingService.save(AppSettingKeys.APP_MAINTENANCE_ENDS_AT, toScheduleText(request.maintenanceEndsAt()));
        log.info("[app operation] settings saved : maintenance={}, ios={}/{}, android={}/{}",
                isMaintenanceEnabled, iosMinimum, iosRecommended, androidMinimum, androidRecommended);
    }

    /** 점검 예약 검증: 종료만 지정 불가, 종료는 시작 이후 */
    private static void validateMaintenancePeriod(LocalDateTime startsAt, LocalDateTime endsAt) {
        if (endsAt != null && (startsAt == null || !endsAt.isAfter(startsAt))) {
            throw new CustomException(ErrorCode.APP_MAINTENANCE_PERIOD_INVALID);
        }
    }

    /** 예약 시각 > 저장 문자열 (분 단위 ISO, null > 빈 값) */
    private static String toScheduleText(LocalDateTime scheduleTime) {
        return scheduleTime == null ? "" : scheduleTime.truncatedTo(ChronoUnit.MINUTES).toString();
    }

    /** x.y.z 형식이면 true */
    public static boolean isValidVersion(String version) {
        return version != null && VERSION_PATTERN.matcher(version.trim()).matches();
    }

    private String requireVersion(String version) {
        if (!isValidVersion(version)) {
            throw new CustomException(ErrorCode.APP_VERSION_FORMAT_INVALID);
        }
        return version.trim();
    }

    /** 저장된 버전 (형식이 틀리면 차단 없음으로 읽음) */
    private String readVersion(String key) {
        String version = readSettingOrDefault(key, NO_REQUIREMENT_VERSION);
        return isValidVersion(version) ? version.trim() : NO_REQUIREMENT_VERSION;
    }

    /** 설정값 (행 없음·저장소 장애 > 기본값) */
    private String readSettingOrDefault(String key, String defaultValue) {
        try {
            String value = appSettingService.getString(key);
            return value == null ? defaultValue : value;
        } catch (RuntimeException e) {
            log.warn("[app operation] setting read failed, using default : key={}, reason={}", key, e.getClass().getSimpleName());
            return defaultValue;
        }
    }
}
