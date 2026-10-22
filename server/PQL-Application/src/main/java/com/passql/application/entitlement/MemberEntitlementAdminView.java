package com.passql.application.entitlement;

import com.passql.member.constant.EntitlementSource;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 관리자 회원 상세용 등급·구매 이력 (구매 토큰은 담지 않음)
 * isActivePro: PRO 이고 만료 전 (결제 스위치와 무관한 실제 등급 행 기준)
 * todayInServiceZone: KST 오늘 (부여 폼 최소 날짜, JVM 기본 시간대와 무관)
 */
public record MemberEntitlementAdminView(
    boolean isActivePro,
    LocalDateTime expiresAt,
    EntitlementSource source,
    List<PurchaseRow> purchases,
    LocalDate todayInServiceZone
) {

    /** 구매 이력 1행 (entitlementPurchaseUuid: 관리자 구매 1건 회수 대상) */
    public record PurchaseRow(
        UUID entitlementPurchaseUuid,
        PurchaseStore store,
        String productId,
        String orderId,
        LocalDateTime purchasedAt,
        PurchaseStatus status,
        LocalDateTime grantedExpiresAt,
        boolean isConsumed
    ) {
    }
}
