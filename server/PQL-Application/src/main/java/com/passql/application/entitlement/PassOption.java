package com.passql.application.entitlement;

import java.time.LocalDateTime;

/**
 * 결제 시트 이용권 1칸: Play 상품 ID, 이용 일수, 지금 사면 될 만료일 (PassProduct > 응답)
 *
 * @param productId            Play 상품 ID (pro_pass_3m, pro_pass_1m)
 * @param durationDays         이용 일수 (90, 30)
 * @param expiresAtIfPurchased 지금 구매하면 될 프로 만료 시각 KST (보유 중이면 현재 만료일 뒤로 이어 붙인 값)
 */
public record PassOption(
    String productId,
    int durationDays,
    LocalDateTime expiresAtIfPurchased
) {
}
