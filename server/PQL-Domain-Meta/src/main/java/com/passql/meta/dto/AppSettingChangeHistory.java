package com.passql.meta.dto;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 설정 변경 이력 1건 (감사 로그 기반): 변경 전 값 > 변경 후 값
 * canRollback: 민감 값(마스킹 저장)·잘린 값·이전 값 없음이면 false
 */
public record AppSettingChangeHistory(
        UUID auditLogUuid,
        LocalDateTime occurredAt,
        String adminUsername,
        String beforeValue,
        String afterValue,
        boolean canRollback
) {
}
