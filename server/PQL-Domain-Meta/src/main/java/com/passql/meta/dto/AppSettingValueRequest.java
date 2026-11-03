package com.passql.meta.dto;

import jakarta.validation.constraints.NotNull;

/**
 * 관리자 설정값 변경 요청 (일반·비밀 공통, 빈 문자열 허용 여부는 AppSettingService 가 판정)
 */
public record AppSettingValueRequest(
    @NotNull String value
) {}
