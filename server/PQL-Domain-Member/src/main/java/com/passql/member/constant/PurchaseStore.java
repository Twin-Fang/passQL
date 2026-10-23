package com.passql.member.constant;

/**
 * 구매가 일어난 스토어 > 그 구매로 준 등급 경로
 */
public enum PurchaseStore {

    PLAY(EntitlementSource.PLAY_PURCHASE),           // Google Play
    APP_STORE(EntitlementSource.APP_STORE_PURCHASE); // Apple App Store (#578)

    private final EntitlementSource entitlementSource;

    PurchaseStore(EntitlementSource entitlementSource) {
        this.entitlementSource = entitlementSource;
    }

    public EntitlementSource getEntitlementSource() {
        return entitlementSource;
    }
}
