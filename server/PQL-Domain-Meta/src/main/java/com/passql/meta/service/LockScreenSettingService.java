package com.passql.meta.service;

import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.dto.LockScreenSettingsRequest;
import com.passql.meta.dto.LockScreenSettingsResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 잠금화면 문제 설정 (#990): 전체 스위치, 기본 표시 간격, 실행형 출제 여부 읽기·관리자 저장
 * 설정 읽기 실패 > 안전 기본값 (스위치 꺼짐, 간격 30분, 실행형 포함)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class LockScreenSettingService {

    // 스위치 기본값: 꺼짐 (설정 장애로 잠금화면이 갑자기 켜지지 않게)
    private static final boolean DEFAULT_IS_ENABLED = false;
    // 기본 표시 간격 (분)
    public static final int DEFAULT_INTERVAL_MINUTES = 30;
    // 실행형 SQL 출제 기본값: 포함
    private static final boolean DEFAULT_IS_EXECUTABLE_INCLUDED = true;

    private final AppSettingService appSettingService;

    public boolean isEnabled() {
        return readBooleanOrDefault(AppSettingKeys.LOCKSCREEN_ENABLED, DEFAULT_IS_ENABLED);
    }

    public boolean isExecutableIncluded() {
        return readBooleanOrDefault(AppSettingKeys.LOCKSCREEN_INCLUDE_EXECUTABLE, DEFAULT_IS_EXECUTABLE_INCLUDED);
    }

    /** 기본 표시 간격 (분, 0 은 화면 켤 때마다, 음수·읽기 실패 > 30) */
    public int getDefaultIntervalMinutes() {
        int intervalMinutes;
        try {
            intervalMinutes = appSettingService.getIntOrDefault(AppSettingKeys.LOCKSCREEN_DEFAULT_INTERVAL_MINUTES, DEFAULT_INTERVAL_MINUTES);
        } catch (RuntimeException e) {
            log.warn("[lockscreen setting] interval read failed, using default : reason={}", e.getClass().getSimpleName());
            return DEFAULT_INTERVAL_MINUTES;
        }
        return intervalMinutes < 0 ? DEFAULT_INTERVAL_MINUTES : intervalMinutes;
    }

    public LockScreenSettingsResponse getSettings() {
        return new LockScreenSettingsResponse(isEnabled(), getDefaultIntervalMinutes(), isExecutableIncluded());
    }

    /** 관리자 저장: 3개 키 (형식 검증은 요청 @Valid, 변경 이력은 감사 로그) */
    @Transactional
    public void updateSettings(LockScreenSettingsRequest request) {
        LockScreenSettingsResponse before = getSettings();
        appSettingService.save(AppSettingKeys.LOCKSCREEN_ENABLED, String.valueOf(request.isEnabled()));
        appSettingService.save(AppSettingKeys.LOCKSCREEN_DEFAULT_INTERVAL_MINUTES, String.valueOf(request.defaultIntervalMinutes()));
        appSettingService.save(AppSettingKeys.LOCKSCREEN_INCLUDE_EXECUTABLE, String.valueOf(request.isExecutableIncluded()));
        log.info("[lockscreen setting] saved : enabled {} -> {}, interval {} -> {}, executable {} -> {}",
                before.isEnabled(), request.isEnabled(),
                before.defaultIntervalMinutes(), request.defaultIntervalMinutes(),
                before.isExecutableIncluded(), request.isExecutableIncluded());
    }

    private boolean readBooleanOrDefault(String key, boolean isTrueByDefault) {
        try {
            return appSettingService.getBooleanOrDefault(key, isTrueByDefault);
        } catch (RuntimeException e) {
            log.warn("[lockscreen setting] read failed, using default : key={}, reason={}", key, e.getClass().getSimpleName());
            return isTrueByDefault;
        }
    }
}
