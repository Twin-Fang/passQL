package com.passql.meta.dto;

/** 잠금화면 문제 설정 현재값 (#990, 관리자 앱 운영 화면 표시) */
public record LockScreenSettingsResponse(
        boolean isEnabled,
        int defaultIntervalMinutes,
        boolean isExecutableIncluded
) {
}
