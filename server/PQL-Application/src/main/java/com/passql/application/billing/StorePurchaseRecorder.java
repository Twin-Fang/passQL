package com.passql.application.billing;

import com.passql.application.entitlement.PassExpiryCalculator;
import com.passql.member.constant.MemberPlan;
import com.passql.member.constant.PassProduct;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;
import com.passql.member.entity.MemberEntitlement;
import com.passql.member.repository.EntitlementPurchaseRepository;
import com.passql.member.repository.MemberEntitlementRepository;
import com.passql.member.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Optional;
import java.util.UUID;

/**
 * 스토어 구매(Play·App Store) 기록 + 등급 반영 (호출자 트랜잭션 안): 회원 행 잠금 > 만료일 계산 > 기록 INSERT(이용 일수·결제 금액 포함) > 1건일 때만 등급 반영
 * 같은 토큰·주문 번호 기록이 이미 있으면 ON CONFLICT 로 0건 > 등급을 건드리지 않음
 */
@Component
@RequiredArgsConstructor
class StorePurchaseRecorder {

    // 기록 created_by·updated_by (JpaConfig auditor 의 회원 API 요청 값과 동일)
    private static final String AUDITOR_SYSTEM = "system";
    // 서비스 기준 시간대 (구매 시각·만료일은 KST 로컬 저장값)
    private static final ZoneId SERVICE_ZONE = ZoneId.of("Asia/Seoul");

    private final EntitlementPurchaseRepository entitlementPurchaseRepository;
    private final MemberEntitlementRepository memberEntitlementRepository;
    private final MemberRepository memberRepository;
    private final PassExpiryCalculator passExpiryCalculator;

    /** 구매 기록·등급 반영, 기록이 이미 있으면 empty (now: 구매 시각 없을 때 기준·기록 시각) */
    Optional<PlanExtension> recordPurchaseAndExtendPlan(UUID memberUuid, VerifiedStorePurchase purchase, Instant now) {
        // 같은 회원 동시 구매 직렬화 (첫 구매는 등급 행이 없어 회원 행을 잠금)
        memberRepository.lockByMemberUuid(memberUuid);

        // 만료일 계산 (스토어 구매 시각 없으면 지금, 보유 중이면 현재 프로 만료일 뒤로 이용 일수만큼)
        PassProduct passProduct = purchase.passProduct();
        Instant purchasedInstant = purchase.purchasedAt() != null ? purchase.purchasedAt() : now;
        LocalDateTime purchasedAt = LocalDateTime.ofInstant(purchasedInstant, SERVICE_ZONE);
        Optional<MemberEntitlement> entitlement = memberEntitlementRepository.findForUpdateByMemberUuid(memberUuid);
        LocalDateTime currentProExpiresAt = entitlement
            .filter(existing -> existing.getPlan() == MemberPlan.PRO)
            .map(MemberEntitlement::getExpiresAt)
            .orElse(null);
        LocalDateTime newExpiresAt = passExpiryCalculator.calculateExpiresAt(
            purchasedAt, currentProExpiresAt, passProduct.getDurationDays());

        // 구매 기록 먼저 (토큰·주문 번호 충돌이면 0건, 예외·오류 로그 없음, 금액 모르면 NULL > 매출 집계 제외)
        StorePrice price = purchase.price();
        int insertedCount = entitlementPurchaseRepository.insertVerifiedIfAbsent(
            UUID.randomUUID(), memberUuid, purchase.store().name(), passProduct.getProductId(), purchase.orderId(),
            purchase.purchaseToken(), purchasedAt, PurchaseStatus.VERIFIED.name(), newExpiresAt,
            passProduct.getDurationDays(), purchase.isConsumed(), LocalDateTime.ofInstant(now, SERVICE_ZONE), AUDITOR_SYSTEM,
            price != null ? price.amountMicros() : null, price != null ? price.currencyCode() : null);
        if (insertedCount == 0) {
            return Optional.empty();
        }

        // 등급 행 없으면 생성, 있으면 연장 (등급 경로는 스토어별)
        if (entitlement.isPresent()) {
            entitlement.get().extendTo(newExpiresAt, purchase.store().getEntitlementSource());
        } else {
            memberEntitlementRepository.save(MemberEntitlement.of(
                memberUuid, MemberPlan.PRO, newExpiresAt, purchase.store().getEntitlementSource()));
        }
        return Optional.of(new PlanExtension(purchase.orderId(), currentProExpiresAt, newExpiresAt));
    }

    /**
     * 스토어에서 확인된 구매 1건
     *
     * @param store         구매 스토어
     * @param passProduct   검증된 이용권 (상품 ID·이용 일수)
     * @param orderId       주문 번호 (Play 주문 번호·대체값, App Store transactionId)
     * @param purchaseToken 구매 토큰 (Play 토큰, App Store "appstore:" + transactionId, 로그 금지)
     * @param purchasedAt   스토어 구매 시각 (없으면 null > 기록 시각)
     * @param isConsumed    소모 완료로 저장할지 (Play false 로 시작, App Store true)
     * @param price         스토어가 알려 준 결제 금액·통화 (모르면 null)
     */
    record VerifiedStorePurchase(PurchaseStore store, PassProduct passProduct, String orderId, String purchaseToken,
                                 Instant purchasedAt, Boolean isConsumed, StorePrice price) {
    }

    /** 반영 결과: 저장한 주문 번호, 등급 만료일 변경 전후 (이전 값은 없으면 null) */
    record PlanExtension(String orderId, LocalDateTime beforeExpiresAt, LocalDateTime afterExpiresAt) {
    }
}
