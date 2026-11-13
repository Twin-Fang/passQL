package com.passql.meta.constant;

import java.math.BigDecimal;

/**
 * app_setting 숫자 값 허용 범위 1개 (최소·최대 모두 포함)
 */
public record AppSettingValueRange(BigDecimal minimumValue, BigDecimal maximumValue) {

    public static AppSettingValueRange between(long minimumValue, long maximumValue) {
        return new AppSettingValueRange(BigDecimal.valueOf(minimumValue), BigDecimal.valueOf(maximumValue));
    }

    public boolean contains(BigDecimal value) {
        return value.compareTo(minimumValue) >= 0 && value.compareTo(maximumValue) <= 0;
    }

    /** 입력 컨트롤 min 속성·안내 문구용 (지수 표기 없이) */
    public String toMinimumText() {
        return minimumValue.toPlainString();
    }

    public String toMaximumText() {
        return maximumValue.toPlainString();
    }
}
