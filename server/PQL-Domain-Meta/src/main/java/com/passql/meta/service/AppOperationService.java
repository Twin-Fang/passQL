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
    // 점검 문구 최대 길이 (문자 수)
    private static final int MAINTENANCE_MESSAGE_MAX_LENGTH = 500;

    private final AppSettingService appSettingService;
    private final AppNoticeService appNoticeService;

    /**
     * 앱 시작 설정: 플랫폼별 버전 정책 + 점검 상태 + 노출 공지
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
                appNoticeService.getVisibleNotices()
        );
    }

    /**
     * 점검 중 여부 (설정 조회 실패 시 false — 설정 장애로 서비스 전체가 막히지 않게)
     */
    public boolean isUnderMaintenance() {
        return Boolean.parseBoolean(readSettingOrDefault(AppSettingKeys.APP_MAINTENANCE_ENABLED, "false").trim());
    }

    public AppOperationSettingsResponse getOperationSettings() {
        return new AppOperationSettingsResponse(
                readVersion(AppSettingKeys.APP_MINIMUM_VERSION_IOS),
                readVersion(AppSettingKeys.APP_RECOMMENDED_VERSION_IOS),
                readVersion(AppSettingKeys.APP_MINIMUM_VERSION_ANDROID),
                readVersion(AppSettingKeys.APP_RECOMMENDED_VERSION_ANDROID),
                isUnderMaintenance(),
                readSettingOrDefault(AppSettingKeys.APP_MAINTENANCE_MESSAGE, "")
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

        // 저장
        appSettingService.save(AppSettingKeys.APP_MINIMUM_VERSION_IOS, iosMinimum);
        appSettingService.save(AppSettingKeys.APP_RECOMMENDED_VERSION_IOS, iosRecommended);
        appSettingService.save(AppSettingKeys.APP_MINIMUM_VERSION_ANDROID, androidMinimum);
        appSettingService.save(AppSettingKeys.APP_RECOMMENDED_VERSION_ANDROID, androidRecommended);
        appSettingService.save(AppSettingKeys.APP_MAINTENANCE_ENABLED, String.valueOf(isMaintenanceEnabled));
        appSettingService.save(AppSettingKeys.APP_MAINTENANCE_MESSAGE, message);
        log.info("[app operation] settings saved : maintenance={}, ios={}/{}, android={}/{}",
                isMaintenanceEnabled, iosMinimum, iosRecommended, androidMinimum, androidRecommended);
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
