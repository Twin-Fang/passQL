package com.passql.application.billing;

/**
 * App Store JWS 서명 검증 경계: 거래, 서버 알림
 * Apple 라이브러리 타입은 구현체 안에만 둠 (테스트는 가짜 구현)
 */
public interface AppStoreSignedDataVerifier {

    /** StoreKit 2 거래 JWS 검증·해석 (서명·번들 ID·환경 불일치 > INVALID_INPUT_VALUE) */
    AppStoreTransaction verifyTransaction(String signedTransaction);

    /** 서버 알림 V2 JWS 검증·해석, 담긴 거래도 같은 환경으로 검증 (불일치 > INVALID_INPUT_VALUE) */
    AppStoreNotification verifyNotification(String signedPayload);
}
