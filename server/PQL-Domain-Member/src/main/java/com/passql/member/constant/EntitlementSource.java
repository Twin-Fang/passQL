package com.passql.member.constant;

/**
 * 등급을 부여한 경로
 */
public enum EntitlementSource {

    PLAY_PURCHASE,       // Google Play 이용권 구매
    APP_STORE_PURCHASE,  // App Store 이용권 구매 (#578)
    ADMIN_GRANT          // 관리자 수동 부여
}
