package com.passql.meta.constant;

import java.util.function.Predicate;

/**
 * app_setting.value_type 4종 > 저장 값 형식 검사 (AppSettingService.getInt·getBoolean 이 읽을 수 있는 값만 허용)
 * 목록에 없는 타입·빈 타입은 STRING 취급
 */
public enum AppSettingValueType {

    INT(AppSettingValueType::isIntegerText),
    FLOAT(AppSettingValueType::isFiniteDecimalText),
    BOOLEAN(value -> "true".equalsIgnoreCase(value) || "false".equalsIgnoreCase(value)),
    STRING(value -> true);

    private final Predicate<String> valueFormatChecker;

    AppSettingValueType(Predicate<String> valueFormatChecker) {
        this.valueFormatChecker = valueFormatChecker;
    }

    /** value_type 문자열 > enum (대소문자 무시, 모르는 값은 STRING) */
    public static AppSettingValueType fromValueType(String valueType) {
        if (valueType == null) return STRING;
        for (AppSettingValueType type : values()) {
            if (type.name().equalsIgnoreCase(valueType.trim())) return type;
        }
        return STRING;
    }

    public boolean isValidValue(String value) {
        return value != null && valueFormatChecker.test(value);
    }

    private static boolean isIntegerText(String value) {
        try {
            Integer.parseInt(value);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    private static boolean isFiniteDecimalText(String value) {
        try {
            return Double.isFinite(Double.parseDouble(value));
        } catch (NumberFormatException e) {
            return false;
        }
    }
}
