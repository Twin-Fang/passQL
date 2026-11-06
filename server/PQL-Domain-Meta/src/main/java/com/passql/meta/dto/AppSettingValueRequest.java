package com.passql.meta.dto;

import jakarta.validation.constraints.NotNull;

/** 관리자 설정 값 변경 요청 (일반·비밀 공통, 형식·빈 값 검사는 서비스) */
public record AppSettingValueRequest(@NotNull String value) {
}
