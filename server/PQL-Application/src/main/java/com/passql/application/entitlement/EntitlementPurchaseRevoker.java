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
import java.util.List;
import java.util.Optional;

/**
 * 구매 1건 회수 공통 (Play 환불 작업·App Store 환불 알림·관리자 구매 회수): REVOKED 표시 > 회원 등급 재계산
 * 호출자 트랜잭션 안에서 실행 (등급 행 잠금 조회), 로그는 호출자가 결과로 남김
 */
@Component
@RequiredArgsConstructor
public class EntitlementPurchaseRevoker {

    private final EntitlementPurchaseRepository entitlementPurchaseRepository;
    private final MemberEntitlementRepository memberEntitlementRepository;
    private final PassExpiryCalculator passExpiryCalculator;

    /** 재계산 결과 3종: 등급 행 없음, 관리자 부여라 그대로, 남은 구매 재생으로 재계산 */
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
     * 구매 회수: REVOKED 표시 > 관리자 부여 > 그대로, 남은 VERIFIED 구매 재생 만료일이 미래 > 그 날짜로, 아니면 FREE
     * now: 재생 결과의 유효 판정 기준 시각 (KST)
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

        // 남은 구매 재생 (방금 회수한 건은 조회 전 자동 flush 로 제외)
        List<EntitlementPurchase> remainingPurchases = entitlementPurchaseRepository
            .findByMemberUuidAndStatus(purchase.getMemberUuid(), PurchaseStatus.VERIFIED);
        Optional<LocalDateTime> replayedExpiresAt = replayExpiresAt(remainingPurchases)
            .filter(expiresAt -> expiresAt.isAfter(now));

        if (replayedExpiresAt.isPresent()) {
            entitlement.extendTo(replayedExpiresAt.get(), resolveLatestPurchaseSource(remainingPurchases));
        } else {
            entitlement.revoke();
        }
        return new RevocationResult(RecalculationKind.RECALCULATED, beforeExpiresAt, entitlement.getExpiresAt());
    }

    /**
     * 구매 시각 순 재생: 일수 있으면 max(구매 시각, 누적 만료일) + 일수, 없으면(옛 회차 패스) max(누적, 부여 만료일)
     * 관리자 부여 위에 이어 붙인 구매가 환불되면 관리자 부여분은 재생에 없어 사라짐 (관리자가 다시 부여)
     */
    private Optional<LocalDateTime> replayExpiresAt(List<EntitlementPurchase> remainingPurchases) {
        LocalDateTime runningExpiresAt = null;
        List<EntitlementPurchase> purchasesInOrder = remainingPurchases.stream()
            .sorted(Comparator.comparing(EntitlementPurchase::getPurchasedAt))
            .toList();
        for (EntitlementPurchase remainingPurchase : purchasesInOrder) {
            if (remainingPurchase.getGrantedDays() != null) {
                runningExpiresAt = passExpiryCalculator.calculateExpiresAt(
                    remainingPurchase.getPurchasedAt(), runningExpiresAt, remainingPurchase.getGrantedDays());
            } else {
                runningExpiresAt = laterOf(runningExpiresAt, remainingPurchase.getGrantedExpiresAt());
            }
        }
        return Optional.ofNullable(runningExpiresAt);
    }

    /** 남은 구매 중 가장 최근 구매의 스토어 > 등급 경로 (Play·App Store 구매가 섞인 회원 대비) */
    private static EntitlementSource resolveLatestPurchaseSource(List<EntitlementPurchase> remainingPurchases) {
        return remainingPurchases.stream()
            .max(Comparator.comparing(EntitlementPurchase::getPurchasedAt))
            .map(purchase -> purchase.getStore().getEntitlementSource())
            .orElse(EntitlementSource.PLAY_PURCHASE);
    }

    /** 둘 중 늦은 시각 (null 은 없는 값으로 취급) */
    private static LocalDateTime laterOf(LocalDateTime first, LocalDateTime second) {
        if (first == null) {
            return second;
        }
        if (second == null) {
            return first;
        }
        return first.isAfter(second) ? first : second;
    }
}
