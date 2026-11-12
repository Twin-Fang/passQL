package com.passql.application.billing.management;

import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 결제 목록 1행 (#1032): 스토어·상품·상태·금액·구매·만료·회수 시각·주문 번호(가운데 가림)·회원
 * amount: 통화 단위 (금액 미확인 null), refundRequestState: App Store 환불 요청 상태 (REQUESTED 요청 중, DECLINED 거절, 없으면 null)
 */
public record AdminPurchaseRowResponse(
    UUID entitlementPurchaseUuid,
    UUID memberUuid,
    String memberNickname,
    Boolean isTestAccount,
    PurchaseStore store,
    String productId,
    PurchaseStatus status,
    Double amount,
    String currencyCode,
    LocalDateTime purchasedAt,
    LocalDateTime grantedExpiresAt,
    LocalDateTime revokedAt,
    String maskedOrderId,
    String refundRequestState) {
}
