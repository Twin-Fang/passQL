package com.passql.application.billing;

import com.passql.application.entitlement.ExamPassExpiryCalculator;
import com.passql.member.constant.EntitlementSource;
import com.passql.member.constant.MemberPlan;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;
import com.passql.member.entity.MemberEntitlement;
import com.passql.member.repository.EntitlementPurchaseRepository;
import com.passql.member.repository.MemberEntitlementRepository;
import com.passql.member.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.HexFormat;
import java.util.Optional;
import java.util.UUID;

/**
 * Play 구매 기록 + 등급 반영 (호출자 트랜잭션 안): 회원 행 잠금 > 만료일 계산 > 기록 INSERT > 1건일 때만 등급 반영
 * 같은 토큰·주문 번호 기록이 이미 있으면 ON CONFLICT 로 0건 > 등급을 건드리지 않음
 */
@Slf4j
@Component
@RequiredArgsConstructor
class PlayPurchaseRecorder {

    // 주문 번호 없는 구매의 대체값: 접두사 + SHA-256(토큰) 16진수 앞 32자
    private static final String FALLBACK_ORDER_ID_PREFIX = "PLAY-NO-ORDER-";
    private static final int FALLBACK_ORDER_ID_HEX_LENGTH = 32;
    // 기록 created_by·updated_by (JpaConfig auditor 의 회원 API 요청 값과 동일)
    private static final String AUDITOR_SYSTEM = "system";
    // 서비스 기준 시간대 (구매 시각·만료일은 KST 로컬 저장값)
    private static final ZoneId SERVICE_ZONE = ZoneId.of("Asia/Seoul");

    private final EntitlementPurchaseRepository entitlementPurchaseRepository;
    private final MemberEntitlementRepository memberEntitlementRepository;
    private final MemberRepository memberRepository;
    private final ExamPassExpiryCalculator examPassExpiryCalculator;

    /** 구매 기록·등급 반영, 기록이 이미 있으면 empty (now: 구매 시각 없을 때 기준·기록 시각) */
    Optional<PlanExtension> recordPurchaseAndExtendPlan(UUID memberUuid, PlayVerifyRequest request,
                                                        PlayPurchaseSnapshot snapshot, Instant now) {
        // 같은 회원 동시 구매 직렬화 (첫 구매는 등급 행이 없어 회원 행을 잠금)
        memberRepository.lockByMemberUuid(memberUuid);

        // 만료일 계산 (Play 구매 시각 없으면 지금, 현재 프로 만료일 이후로 연장)
        String orderId = resolveOrderId(memberUuid, snapshot.orderId(), request.purchaseToken());
        Instant purchasedInstant = snapshot.purchasedAt() != null ? snapshot.purchasedAt() : now;
        LocalDateTime purchasedAt = LocalDateTime.ofInstant(purchasedInstant, SERVICE_ZONE);
        Optional<MemberEntitlement> entitlement = memberEntitlementRepository.findForUpdateByMemberUuid(memberUuid);
        LocalDateTime currentProExpiresAt = entitlement
            .filter(existing -> existing.getPlan() == MemberPlan.PRO)
            .map(MemberEntitlement::getExpiresAt)
            .orElse(null);
        LocalDateTime newExpiresAt = examPassExpiryCalculator.calculateExpiresAt(purchasedAt, currentProExpiresAt);

        // 구매 기록 먼저 (토큰·주문 번호 충돌이면 0건, 예외·오류 로그 없음)
        int insertedCount = entitlementPurchaseRepository.insertVerifiedIfAbsent(
            UUID.randomUUID(), memberUuid, PurchaseStore.PLAY.name(), request.productId(), orderId,
            request.purchaseToken(), purchasedAt, PurchaseStatus.VERIFIED.name(), newExpiresAt,
            LocalDateTime.ofInstant(now, SERVICE_ZONE), AUDITOR_SYSTEM);
        if (insertedCount == 0) {
            return Optional.empty();
        }

        // 등급 행 없으면 생성, 있으면 연장
        if (entitlement.isPresent()) {
            entitlement.get().extendTo(newExpiresAt, EntitlementSource.PLAY_PURCHASE);
        } else {
            memberEntitlementRepository.save(
                MemberEntitlement.of(memberUuid, MemberPlan.PRO, newExpiresAt, EntitlementSource.PLAY_PURCHASE));
        }
        return Optional.of(new PlanExtension(orderId, currentProExpiresAt, newExpiresAt));
    }

    /** Play 주문 번호, 없으면 대체값 (같은 토큰은 항상 같은 값) */
    private static String resolveOrderId(UUID memberUuid, String playOrderId, String purchaseToken) {
        if (StringUtils.hasText(playOrderId)) {
            return playOrderId;
        }
        log.warn("[billing] missing order id, using fallback : member={}", memberUuid);
        try {
            byte[] tokenDigest = MessageDigest.getInstance("SHA-256").digest(purchaseToken.getBytes(StandardCharsets.UTF_8));
            return FALLBACK_ORDER_ID_PREFIX + HexFormat.of().formatHex(tokenDigest).substring(0, FALLBACK_ORDER_ID_HEX_LENGTH);
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 unavailable", exception);
        }
    }

    /** 반영 결과: 저장한 주문 번호, 등급 만료일 변경 전후 (이전 값은 없으면 null) */
    record PlanExtension(String orderId, LocalDateTime beforeExpiresAt, LocalDateTime afterExpiresAt) {
    }
}
