package com.passql.application.constant;

import com.fasterxml.jackson.annotation.JsonValue;

import java.util.Locale;

/**
 * 관제소 attention v1 항목 수준: ok, info, warning, critical (JSON 은 소문자)
 */
public enum ControlTowerAttentionLevel {
    OK,
    INFO,
    WARNING,
    CRITICAL;

    @JsonValue
    public String toJsonValue() {
        return name().toLowerCase(Locale.ROOT);
    }
}
