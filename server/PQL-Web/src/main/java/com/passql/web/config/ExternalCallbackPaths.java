package com.passql.web.config;

import java.util.List;

/**
 * 외부 서비스가 부르는 콜백 경로 2개 (회원 JWT 대신 서명으로 검증): AdMob 보상 서버 검증, App Store 서버 알림
 * API 보안 체인 허용·점검 모드 통과가 같은 목록을 씀 (점검 중 503 이면 보상·환불 알림이 늦거나 사라짐, #867)
 */
public final class ExternalCallbackPaths {

    // AdMob 보상형 광고 서버 검증 콜백 (GET, AdRewardCallbackController, #860)
    public static final String ADMOB_REWARD_CALLBACK = "/api/ads/admob/reward-callback";
    // App Store 서버 알림 (POST, BillingController, #578)
    public static final String APP_STORE_NOTIFICATIONS = "/api/billing/app-store/notifications";

    public static final List<String> ALL = List.of(ADMOB_REWARD_CALLBACK, APP_STORE_NOTIFICATIONS);

    private ExternalCallbackPaths() {
    }
}
