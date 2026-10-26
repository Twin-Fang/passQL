package com.passql.application.billing;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

/**
 * Google Play Developer API 경계: 구매 조회, 주문 금액 조회, 소모, 환불 목록
 * Play 라이브러리 타입은 구현체 안에만 둠 (테스트는 가짜 구현)
 */
public interface PlayDeveloperApiClient {

    /** 서비스 계정 키 설정 여부 (없으면 Play 호출 불가) */
    boolean isConfigured();

    /** 일회성 상품 구매 조회 (purchases.products.get) */
    PlayPurchaseSnapshot getProductPurchase(String productId, String purchaseToken);

    /**
     * 주문 결제 금액 조회 (orders.get 의 total: 할인·세금 반영 고객 결제액)
     * 조회 실패(권한 없음·주문 없음·통신 오류)는 예외 없이 empty (금액은 매출 집계용이라 구매 확인을 막지 않음)
     */
    Optional<StorePrice> findOrderPrice(String orderId);

    /** 구매 소모 처리 (purchases.products.consume, 소모해야 같은 상품 재구매 가능) */
    void consume(String productId, String purchaseToken);

    /** since 이후 환불·취소된 구매 토큰 목록 (purchases.voidedpurchases.list) */
    List<String> listVoidedPurchaseTokens(Instant since);
}
