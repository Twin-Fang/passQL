package com.passql.meta.dto;

import jakarta.validation.constraints.NotNull;

/**
 * 관리자 공지 활성 전환 요청 (true 활성, false 비활성)
 */
public record AppNoticeActiveRequest(
    @NotNull Boolean isActive
) {}
