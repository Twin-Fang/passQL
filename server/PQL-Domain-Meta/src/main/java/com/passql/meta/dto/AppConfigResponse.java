package com.passql.meta.dto;

import java.util.List;

/**
 * 앱 시작 시 1회 조회하는 운영 설정: 플랫폼별 버전 정책, 점검 상태, 노출 공지
 */
public record AppConfigResponse(
        AppPlatformVersionResponse ios,
        AppPlatformVersionResponse android,
        AppMaintenanceResponse maintenance,
        List<AppNoticeResponse> notices
) {
}
