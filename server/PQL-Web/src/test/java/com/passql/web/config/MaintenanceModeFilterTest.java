package com.passql.web.config;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 점검 모드 통과 경로 규칙 (#867): 외부 콜백·설정·인증은 통과, 회원 API 는 차단 대상
 */
class MaintenanceModeFilterTest {

    @Test
    void 외부_콜백은_점검_중에도_통과한다() {
        assertThat(ExternalCallbackPaths.ALL).allMatch(MaintenanceModeFilter::isMaintenanceBypassPath);
    }

    @Test
    void 설정과_인증_경로는_통과한다() {
        assertThat(MaintenanceModeFilter.isMaintenanceBypassPath("/api/meta/app-config")).isTrue();
        assertThat(MaintenanceModeFilter.isMaintenanceBypassPath("/api/auth/reissue")).isTrue();
    }

    @Test
    void 회원_API_는_통과하지_않는다() {
        assertThat(MaintenanceModeFilter.isMaintenanceBypassPath("/api/members/me/plan/ad-bonus")).isFalse();
        assertThat(MaintenanceModeFilter.isMaintenanceBypassPath("/api/ads/admob/reward-callback/extra")).isFalse();
        assertThat(MaintenanceModeFilter.isMaintenanceBypassPath("/api/billing/google-play/verify")).isFalse();
    }
}
