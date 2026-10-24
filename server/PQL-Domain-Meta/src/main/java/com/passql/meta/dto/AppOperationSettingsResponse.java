package com.passql.meta.dto;

import java.time.LocalDateTime;

/**
 * 관리자 앱 운영 화면의 현재 설정값
 * isMaintenanceEnabled: 수동 스위치, isUnderMaintenanceNow: 스위치 또는 예약 구간 안
 */
public record AppOperationSettingsResponse(
        String iosMinimumVersion,
        String iosRecommendedVersion,
        String androidMinimumVersion,
        String androidRecommendedVersion,
        Boolean isMaintenanceEnabled,
        String maintenanceMessage,
        LocalDateTime maintenanceStartsAt,
        LocalDateTime maintenanceEndsAt,
        Boolean isUnderMaintenanceNow
) {
}
