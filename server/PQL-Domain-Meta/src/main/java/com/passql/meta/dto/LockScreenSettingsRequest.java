package com.passql.meta.dto;

import com.passql.meta.constant.AppSettingValueRanges;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

/** 관리자 잠금화면 문제 설정 저장 요청 (#990, 간격 0~1440분, 0 은 화면 켤 때마다) */
public record LockScreenSettingsRequest(
        @NotNull Boolean isEnabled,
        @NotNull @Min(AppSettingValueRanges.LOCKSCREEN_INTERVAL_MINUTES_MINIMUM)
        @Max(AppSettingValueRanges.LOCKSCREEN_INTERVAL_MINUTES_MAXIMUM) Integer defaultIntervalMinutes,
        @NotNull Boolean isExecutableIncluded
) {
}
