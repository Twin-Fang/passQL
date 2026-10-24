package com.passql.meta.dto;

import java.time.LocalDateTime;

/**
 * 관리자 앱 운영 설정 저장 요청 (버전은 x.y.z)
 * 점검 예약 maintenanceStartsAt·EndsAt: KST, 비면 예약 없음 (종료만 지정 불가)
 */
public record AppOperationSettingsRequest(
        String iosMinimumVersion,
        String iosRecommendedVersion,
        String androidMinimumVersion,
        String androidRecommendedVersion,
        Boolean isMaintenanceEnabled,
        String maintenanceMessage,
        LocalDateTime maintenanceStartsAt,
        LocalDateTime maintenanceEndsAt
) {
    /** 점검 예약 없는 요청 */
    public AppOperationSettingsRequest(String iosMinimumVersion, String iosRecommendedVersion,
                                       String androidMinimumVersion, String androidRecommendedVersion,
                                       Boolean isMaintenanceEnabled, String maintenanceMessage) {
        this(iosMinimumVersion, iosRecommendedVersion, androidMinimumVersion, androidRecommendedVersion,
                isMaintenanceEnabled, maintenanceMessage, null, null);
    }
}
