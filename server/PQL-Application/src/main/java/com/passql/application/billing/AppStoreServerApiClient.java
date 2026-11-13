package com.passql.application.billing;

import java.util.Optional;

/**
 * App Store Server API 경계 (#1032): 거래 조회(환불·회수 시각 확인), 환불 요청 소비 정보 응답
 * Apple 라이브러리 타입은 구현체 안에만 둠 (테스트는 가짜 구현), 인앱 결제 키가 없으면 isConfigured false
 */
public interface AppStoreServerApiClient {

    /** 인앱 결제 키(issuer ID·key ID·개인 키) 설정 여부 (없으면 호출 불가, 서버 기동은 정상) */
    boolean isConfigured();

    /**
     * 거래 조회 (Get Transaction Info): 운영 > 404 이고 isSandboxFallbackEnabled 면 샌드박스
     * 두 환경 모두 없으면 empty, 그 외 실패 EXTERNAL_API_ERROR (서명 검증은 AppStoreSignedDataVerifier)
     */
    Optional<AppStoreTransaction> findTransaction(String transactionId, boolean isSandboxFallbackEnabled);

    /** 환불 요청(CONSUMPTION_REQUEST) 소비 정보 응답 (Send Consumption Information, environment: Production·Sandbox 원문) */
    void sendConsumptionInformation(String transactionId, String environment, AppStoreConsumptionInformation information);
}
