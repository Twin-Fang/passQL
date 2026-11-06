package com.passql.meta.dto;

import jakarta.validation.constraints.NotNull;

/** 앱 공지 활성 전환 요청 */
public record AppNoticeActiveRequest(@NotNull Boolean isActive) {
}
