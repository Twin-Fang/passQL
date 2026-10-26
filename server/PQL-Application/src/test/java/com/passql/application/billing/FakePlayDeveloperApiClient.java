package com.passql.application.billing;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/** 가짜 Play API: 응답 고정, 호출 수 기록, 소모 실패·주문 금액 조회 실패 전환 */
class FakePlayDeveloperApiClient implements PlayDeveloperApiClient {

    // 주문 금액 고정값 (테스트용 1,100 KRW)
    static final StorePrice ORDER_PRICE = StorePrice.fromPlayMoney(1_100L, 0, "KRW");

    PlayPurchaseSnapshot snapshot;
    boolean isOrderPriceUnavailable;
    final List<String> findOrderPriceOrderIds = new ArrayList<>();
    boolean isConsumeFailing;
    int getProductPurchaseCallCount;
    int consumeAttemptCount;
    final List<String> voidedPurchaseTokens = new ArrayList<>();

    @Override
    public boolean isConfigured() {
        return true;
    }

    @Override
    public PlayPurchaseSnapshot getProductPurchase(String productId, String purchaseToken) {
        getProductPurchaseCallCount++;
        return snapshot;
    }

    @Override
    public Optional<StorePrice> findOrderPrice(String orderId) {
        findOrderPriceOrderIds.add(orderId);
        return isOrderPriceUnavailable ? Optional.empty() : Optional.of(ORDER_PRICE);
    }

    @Override
    public void consume(String productId, String purchaseToken) {
        consumeAttemptCount++;
        if (isConsumeFailing) {
            throw new CustomException(ErrorCode.EXTERNAL_API_ERROR);
        }
    }

    @Override
    public List<String> listVoidedPurchaseTokens(Instant since) {
        return voidedPurchaseTokens;
    }
}
