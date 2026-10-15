package com.passql.meta.dto;

/**
 * 관리자 앱 운영 설정 저장 요청 (버전은 x.y.z)
 */
public record AppOperationSettingsRequest(
        String iosMinimumVersion,
        String iosRecommendedVersion,
        String androidMinimumVersion,
        String androidRecommendedVersion,
        Boolean isMaintenanceEnabled,
        String maintenanceMessage
) {
}
