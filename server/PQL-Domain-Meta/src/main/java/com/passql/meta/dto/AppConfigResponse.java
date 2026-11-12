package com.passql.meta.dto;

import java.util.List;

/**
 * 앱 시작 시 1회 조회하는 운영 설정: 플랫폼별 버전 정책, 점검 상태, 노출 공지, Android 결제 스위치, 사업자 정보, 잠금화면 문제 설정
 */
public record AppConfigResponse(
        AppPlatformVersionResponse ios,
        AppPlatformVersionResponse android,
        AppMaintenanceResponse maintenance,
        List<AppNoticeResponse> notices,
        boolean isAndroidBillingEnabled,
        BusinessInfoResponse businessInfo,
        // 잠금화면 문제 (#990): 전체 스위치, 기본 표시 간격(분), 실행형 SQL 출제 여부
        boolean isLockScreenEnabled,
        int lockScreenDefaultIntervalMinutes,
        boolean isLockScreenExecutableIncluded
) {
}
