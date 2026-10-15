package com.passql.meta.dto;

/**
 * 관리자 앱 운영 화면의 현재 설정값
 */
public record AppOperationSettingsResponse(
        String iosMinimumVersion,
        String iosRecommendedVersion,
        String androidMinimumVersion,
        String androidRecommendedVersion,
        Boolean isMaintenanceEnabled,
        String maintenanceMessage
) {
}
