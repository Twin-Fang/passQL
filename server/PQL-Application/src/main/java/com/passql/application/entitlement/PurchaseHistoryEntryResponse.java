package com.passql.application.entitlement;

import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

/**
 * 내 구매 내역 1건: 스토어 구매 또는 운영 지급 (구매 토큰·주문 번호·지급 사유는 내보내지 않음)
 *
 * @param kind              STORE_PURCHASE 또는 ADMIN_GRANT
 * @param purchasedAt       구매·지급 시각 KST
 * @param productId         스토어 상품 ID (운영 지급이면 null)
 * @param store             PLAY 또는 APP_STORE (운영 지급이면 null)
 * @param status            VERIFIED 또는 REVOKED(환불·회수) (운영 지급이면 null)
 * @param grantedExpiresAt  이 구매·지급으로 정해진 프로 만료 시각 KST (모르면 null)
 * @param grantedDays       더한 이용 일수 (모르면 null, 운영 지급은 이어 붙인 기준일부터 만료일까지)
 * @param priceAmountMicros 결제 금액 x 1,000,000 (스토어가 알려 준 값만, 운영 지급·모르면 null)
 * @param currencyCode      결제 통화 ISO 4217 (예: KRW, 운영 지급·모르면 null)
 */
public record PurchaseHistoryEntryResponse(
    PurchaseHistoryKind kind,
    LocalDateTime purchasedAt,
    @Schema(nullable = true) String productId,
    @Schema(nullable = true) PurchaseStore store,
    @Schema(nullable = true) PurchaseStatus status,
    @Schema(nullable = true) LocalDateTime grantedExpiresAt,
    @Schema(nullable = true) Integer grantedDays,
    @Schema(nullable = true) Long priceAmountMicros,
    @Schema(nullable = true) String currencyCode
) {
}
