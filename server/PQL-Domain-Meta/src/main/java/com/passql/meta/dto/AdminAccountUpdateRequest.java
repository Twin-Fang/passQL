package com.passql.meta.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/** 관리자 계정 역할·사용 여부 변경 요청 (role: ADMIN | VIEWER) */
public record AdminAccountUpdateRequest(
        @NotBlank String role,
        @NotNull Boolean isEnabled
) {}
