package com.passql.member.repository;

import com.passql.member.constant.PurchaseStatus;
import com.passql.member.entity.EntitlementPurchase;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface EntitlementPurchaseRepository extends JpaRepository<EntitlementPurchase, UUID> {

    /** 구매 토큰으로 이력 조회 (재검증 시 중복 반영 확인) */
    Optional<EntitlementPurchase> findByPurchaseToken(String purchaseToken);

    /** 주문 번호로 이력 조회 (환불 알림 대응) */
    Optional<EntitlementPurchase> findByOrderId(String orderId);

    /**
     * 검증 완료 구매 저장 (토큰·주문 번호·PK 충돌 시 무시, 저장 건수 1 또는 0)
     * UNIQUE 위반 예외를 내지 않아 DB·Hibernate 오류 로그에 구매 토큰이 남지 않음
     * store·status 는 enum 이름, is_consumed 는 false 로 시작, granted_days 는 이용권 일수
     */
    @Modifying
    @Query(value = """
            INSERT INTO entitlement_purchase (entitlement_purchase_uuid, member_uuid, store, product_id, order_id,
                purchase_token, purchased_at, status, granted_expires_at, granted_days, is_consumed,
                created_at, updated_at, created_by, updated_by)
            VALUES (:entitlementPurchaseUuid, :memberUuid, :store, :productId, :orderId,
                :purchaseToken, :purchasedAt, :status, :grantedExpiresAt, :grantedDays, FALSE,
                :createdAt, :createdAt, :auditor, :auditor)
            ON CONFLICT DO NOTHING
            """, nativeQuery = true)
    int insertVerifiedIfAbsent(@Param("entitlementPurchaseUuid") UUID entitlementPurchaseUuid,
                               @Param("memberUuid") UUID memberUuid,
                               @Param("store") String store,
                               @Param("productId") String productId,
                               @Param("orderId") String orderId,
                               @Param("purchaseToken") String purchaseToken,
                               @Param("purchasedAt") LocalDateTime purchasedAt,
                               @Param("status") String status,
                               @Param("grantedExpiresAt") LocalDateTime grantedExpiresAt,
                               @Param("grantedDays") Integer grantedDays,
                               @Param("createdAt") LocalDateTime createdAt,
                               @Param("auditor") String auditor);

    /** 회원의 상태별 구매 이력 (환불 후 남은 유효 구매 재생으로 만료일 재계산) */
    List<EntitlementPurchase> findByMemberUuidAndStatus(UUID memberUuid, PurchaseStatus status);

    /** 회원의 상태별 가장 최근 구매 1건 (구매 시각 기준, 이용권 정보의 최근 구매일·주문 번호) */
    Optional<EntitlementPurchase> findFirstByMemberUuidAndStatusOrderByPurchasedAtDesc(UUID memberUuid,
                                                                                        PurchaseStatus status);

    /** 회원의 전체 구매 이력 (관리자 회원 상세) */
    List<EntitlementPurchase> findByMemberUuid(UUID memberUuid, Sort sort);
}
