package com.passql.member.repository;

import com.passql.member.constant.PurchaseStatus;
import com.passql.member.entity.EntitlementPurchase;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface EntitlementPurchaseRepository extends JpaRepository<EntitlementPurchase, UUID> {

    /** 구매 토큰으로 이력 조회 (재검증 시 중복 반영 확인) */
    Optional<EntitlementPurchase> findByPurchaseToken(String purchaseToken);

    /** 주문 번호로 이력 조회 (환불 알림 대응) */
    Optional<EntitlementPurchase> findByOrderId(String orderId);

    /** 회원의 상태별 구매 이력 (환불 후 남은 유효 구매로 만료일 재계산) */
    List<EntitlementPurchase> findByMemberUuidAndStatus(UUID memberUuid, PurchaseStatus status);
}
