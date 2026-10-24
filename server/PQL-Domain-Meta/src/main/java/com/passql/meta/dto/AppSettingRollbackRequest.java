package com.passql.meta.dto;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

/** 설정 롤백 요청: 되돌릴 변경 이력(감사 로그) UUID */
public record AppSettingRollbackRequest(@NotNull UUID auditLogUuid) {
}
