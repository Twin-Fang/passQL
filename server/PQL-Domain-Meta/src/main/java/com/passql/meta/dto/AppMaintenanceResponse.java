package com.passql.meta.dto;

/**
 * 점검 상태: 점검 여부, 점검 문구(비면 앱 기본 문구)
 */
public record AppMaintenanceResponse(
        Boolean isUnderMaintenance,
        String message
) {
}
