package com.passql.application.billing;

import java.time.Instant;
import java.util.UUID;

/**
 * 서명 검증된 App Store 거래 (Apple 라이브러리 타입과 분리)
 *
 * @param transactionId         거래 ID (구매 1건 고유, 주문 번호로 저장)
 * @param originalTransactionId 최초 거래 ID (비갱신 이용권은 거래 ID 와 같음)
 * @param bundleId              앱 번들 ID
 * @param productId             상품 ID
 * @param type                  상품 유형 원문 (예: "Non-Renewing Subscription")
 * @param purchasedAt           구매 시각 (없으면 null)
 * @param appAccountToken       앱이 결제 때 넣은 회원 uuid (없으면 null)
 * @param revokedAt             환불·회수 시각 (정상 거래는 null)
 * @param environment           거래 환경 원문 (Production, Sandbox)
 * @param price                 고객 결제 금액·통화 (Apple price·currency, 없으면 null)
 */
public record AppStoreTransaction(String transactionId, String originalTransactionId, String bundleId, String productId,
                                  String type, Instant purchasedAt, UUID appAccountToken, Instant revokedAt,
                                  String environment, StorePrice price) {
}
