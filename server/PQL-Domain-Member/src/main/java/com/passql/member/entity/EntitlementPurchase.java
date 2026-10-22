package com.passql.member.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 스토어 구매 이력: 구매 1건당 1행, orderId·purchaseToken 중복 불가 (같은 구매의 재반영 차단)
 * 구매 토큰은 로그에 남기지 않음
 */
@Entity
@Table(
    name = "entitlement_purchase",
    indexes = @Index(name = "idx_entitlement_purchase_member", columnList = "member_uuid"),
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_entitlement_purchase_order_id", columnNames = "order_id"),
        @UniqueConstraint(name = "uk_entitlement_purchase_purchase_token", columnNames = "purchase_token")
    }
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class EntitlementPurchase extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID entitlementPurchaseUuid;

    @Column(nullable = false)
    private UUID memberUuid;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private PurchaseStore store;

    @Column(length = 100, nullable = false)
    private String productId;

    @Column(length = 100, nullable = false)
    private String orderId;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String purchaseToken;

    @Column(nullable = false)
    private LocalDateTime purchasedAt;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private PurchaseStatus status;

    // 이 구매로 부여한 프로 만료 시각
    private LocalDateTime grantedExpiresAt;

    public static EntitlementPurchase granted(UUID memberUuid, PurchaseStore store, String productId, String orderId,
                                              String purchaseToken, LocalDateTime purchasedAt,
                                              LocalDateTime grantedExpiresAt) {
        EntitlementPurchase purchase = new EntitlementPurchase();
        purchase.memberUuid = memberUuid;
        purchase.store = store;
        purchase.productId = productId;
        purchase.orderId = orderId;
        purchase.purchaseToken = purchaseToken;
        purchase.purchasedAt = purchasedAt;
        purchase.status = PurchaseStatus.GRANTED;
        purchase.grantedExpiresAt = grantedExpiresAt;
        return purchase;
    }

    /** 환불 회수 표시 */
    public void markRefunded() {
        this.status = PurchaseStatus.REFUNDED;
    }
}
