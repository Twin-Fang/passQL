package com.passql.application.entitlement;

import com.passql.member.constant.EntitlementSource;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.entity.EntitlementPurchase;
import com.passql.member.entity.MemberEntitlement;
import com.passql.member.repository.EntitlementPurchaseRepository;
import com.passql.member.repository.MemberEntitlementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.Objects;
import java.util.Optional;

/**
 * 구매 1건 회수 공통 (Play 환불 작업·관리자 구매 회수): REVOKED 표시 > 회원 등급 재계산
 * 호출자 트랜잭션 안에서 실행 (등급 행 잠금 조회), 로그는 호출자가 결과로 남김
 */
@Component
@RequiredArgsConstructor
public class EntitlementPurchaseRevoker {

    private final EntitlementPurchaseRepository entitlementPurchaseRepository;
    private final MemberEntitlementRepository memberEntitlementRepository;

    /** 재계산 결과 3종: 등급 행 없음, 관리자 부여라 그대로, 남은 구매로 재계산 */
    public enum RecalculationKind {
        NO_ENTITLEMENT,
        ADMIN_GRANT_KEPT,
        RECALCULATED
    }

    /**
     * 회수 결과
     *
     * @param kind            재계산 종류
     * @param beforeExpiresAt 회수 전 회원 만료일 (등급 행 없으면 null)
     * @param afterExpiresAt  회수 후 회원 만료일 (FREE 가 되면 null)
     */
    public record RevocationResult(RecalculationKind kind, LocalDateTime beforeExpiresAt, LocalDateTime afterExpiresAt) {
    }

    /**
     * 구매 회수: REVOKED 표시 > 관리자 부여 > 그대로, 남은 유효 구매 최대 만료일이 미래 > 그 날짜로, 아니면 FREE
     * now: 남은 구매의 유효 판정 기준 시각 (KST)
     */
    public RevocationResult revokeAndRecalculate(EntitlementPurchase purchase, LocalDateTime now) {
        purchase.markRevoked();

        Optional<MemberEntitlement> entitlementOptional =
            memberEntitlementRepository.findForUpdateByMemberUuid(purchase.getMemberUuid());
        if (entitlementOptional.isEmpty()) {
            return new RevocationResult(RecalculationKind.NO_ENTITLEMENT, null, null);
        }
        MemberEntitlement entitlement = entitlementOptional.get();
        LocalDateTime beforeExpiresAt = entitlement.getExpiresAt();
        if (entitlement.getSource() == EntitlementSource.ADMIN_GRANT) {
            return new RevocationResult(RecalculationKind.ADMIN_GRANT_KEPT, beforeExpiresAt, beforeExpiresAt);
        }

        // 남은 유효 구매 중 가장 늦은 만료일 (방금 회수한 건은 조회 전 자동 flush 로 제외)
        Optional<LocalDateTime> remainingExpiresAt = entitlementPurchaseRepository
            .findByMemberUuidAndStatus(purchase.getMemberUuid(), PurchaseStatus.VERIFIED).stream()
            .map(EntitlementPurchase::getGrantedExpiresAt)
            .filter(Objects::nonNull)
            .max(Comparator.naturalOrder())
            .filter(expiresAt -> expiresAt.isAfter(now));

        if (remainingExpiresAt.isPresent()) {
            entitlement.extendTo(remainingExpiresAt.get(), EntitlementSource.PLAY_PURCHASE);
        } else {
            entitlement.revoke();
        }
        return new RevocationResult(RecalculationKind.RECALCULATED, beforeExpiresAt, entitlement.getExpiresAt());
    }
}
