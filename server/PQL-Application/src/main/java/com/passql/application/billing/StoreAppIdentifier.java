package com.passql.application.billing;

/**
 * 스토어 앱 식별자 단일 원본: iOS 번들 ID, Android 패키지 이름 공통 값
 * app/ 의 iOS PRODUCT_BUNDLE_IDENTIFIER·Android applicationId 와 같은 값
 */
final class StoreAppIdentifier {

    // iOS 번들 ID = Android 패키지 이름 (App Store Connect·Play Console 앱 정보)
    static final String APPLICATION_ID = "com.coldredrice.passql";

    private StoreAppIdentifier() {
    }
}
