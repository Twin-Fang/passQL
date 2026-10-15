package com.passql.meta.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

/** 관리자 계정 추가 요청 (role: ADMIN | VIEWER) */
public record AdminAccountCreateRequest(
        @NotBlank @Pattern(regexp = "^[A-Za-z0-9._-]{3,50}$", message = "아이디는 영문·숫자·._- 3~50자") String username,
        @NotBlank String password,
        @NotBlank String role
) {}
