package com.passql.meta.dto;

import jakarta.validation.constraints.NotBlank;

/** 관리자 비밀번호 재설정 요청 */
public record AdminPasswordResetRequest(@NotBlank String password) {}
