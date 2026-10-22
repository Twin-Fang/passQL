package com.passql.application.billing;

import com.passql.application.entitlement.ExamPassExpiryCalculator;
import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.application.entitlement.MemberPlanResponse;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.EntitlementSource;
import com.passql.member.constant.MemberPlan;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;
import com.passql.member.entity.EntitlementPurchase;
import com.passql.member.entity.MemberEntitlement;
import com.passql.member.repository.EntitlementPurchaseRepository;
import com.passql.member.repository.MemberEntitlementRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;

/**
 * Play 회차 패스 결제: 구매 확인·등급 부여, 소모, 환불 회수
 * 기록·등급 변경은 한 트랜잭션 > 커밋 후 소모 (소모 실패는 다음 확인 요청에서 재시도)
 */
@Slf4j
@Service
public class PlayBillingService {

    // Play 상품 ID: 회차 패스 (소모형 일회성 상품)
    public static final String PRO_EXAM_PASS_PRODUCT_ID = "pro_exam_pass";

    // Play purchaseState: 0 구매 완료, 1 취소, 2 대기
    private static final int PURCHASE_STATE_PURCHASED = 0;
    private static final int PURCHASE_STATE_PENDING = 2;
    // Play consumptionState: 1 소모 완료
    private static final int CONSUMPTION_STATE_CONSUMED = 1;
    // 환불 조회 기간 (Play 허용 최대 30일, 요청 지연 여유 10분)
    private static final Duration VOIDED_PURCHASE_LOOKBACK = Duration.ofDays(30).minusMinutes(10);
    // 서비스 기준 시간대 (만료일·구매 시각은 KST 로컬 저장값)
    private static final ZoneId SERVICE_ZONE = ZoneId.of("Asia/Seoul");

    private final PlayDeveloperApiClient playDeveloperApiClient;
    private final EntitlementPurchaseRepository entitlementPurchaseRepository;
    private final MemberEntitlementRepository memberEntitlementRepository;
    private final ExamPassExpiryCalculator examPassExpiryCalculator;
    private final FeatureAccessPolicy featureAccessPolicy;
    private final TransactionTemplate transactionTemplate;
    private final Clock clock;

    @Autowired
    public PlayBillingService(PlayDeveloperApiClient playDeveloperApiClient,
                              EntitlementPurchaseRepository entitlementPurchaseRepository,
                              MemberEntitlementRepository memberEntitlementRepository,
                              ExamPassExpiryCalculator examPassExpiryCalculator,
                              FeatureAccessPolicy featureAccessPolicy,
                              TransactionTemplate transactionTemplate) {
        this(playDeveloperApiClient, entitlementPurchaseRepository, memberEntitlementRepository,
            examPassExpiryCalculator, featureAccessPolicy, transactionTemplate, Clock.system(SERVICE_ZONE));
    }

    PlayBillingService(PlayDeveloperApiClient playDeveloperApiClient,
                       EntitlementPurchaseRepository entitlementPurchaseRepository,
                       MemberEntitlementRepository memberEntitlementRepository,
                       ExamPassExpiryCalculator examPassExpiryCalculator,
                       FeatureAccessPolicy featureAccessPolicy,
                       TransactionTemplate transactionTemplate, Clock clock) {
        this.playDeveloperApiClient = playDeveloperApiClient;
        this.entitlementPurchaseRepository = entitlementPurchaseRepository;
        this.memberEntitlementRepository = memberEntitlementRepository;
        this.examPassExpiryCalculator = examPassExpiryCalculator;
        this.featureAccessPolicy = featureAccessPolicy;
        this.transactionTemplate = transactionTemplate;
        this.clock = clock;
    }

    /**
     * 구매 확인: 상품 검증 > 기존 기록 처리 > Play 조회 > 기록·등급 저장 > 커밋 후 소모 > 내 등급
     * 대기 구매는 저장·소모 없이 현재 등급 반환
     */
    public MemberPlanResponse verify(UUID memberUuid, PlayVerifyRequest request) {
        if (!PRO_EXAM_PASS_PRODUCT_ID.equals(request.productId())) {
            log.info("[billing] rejected 400 : unknown product, member={}", memberUuid);
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }

        // 이미 기록된 토큰: 연장 없이 소모만 재시도
        Optional<EntitlementPurchase> recordedPurchase =
            entitlementPurchaseRepository.findByPurchaseToken(request.purchaseToken());
        if (recordedPurchase.isPresent()) {
            return handleRecordedPurchase(memberUuid, recordedPurchase.get());
        }

        // Play 구매 상태 확인 (대기 > 그대로, 취소 > 거절)
        PlayPurchaseSnapshot snapshot =
            playDeveloperApiClient.getProductPurchase(request.productId(), request.purchaseToken());
        if (snapshot.purchaseState() == PURCHASE_STATE_PENDING) {
            log.info("[billing] pending : member={}, order={}", memberUuid, snapshot.orderId());
            return featureAccessPolicy.getPlan(memberUuid);
        }
        if (snapshot.purchaseState() != PURCHASE_STATE_PURCHASED) {
            log.info("[billing] rejected 400 : purchase not completed, member={}, order={}, state={}",
                memberUuid, snapshot.orderId(), snapshot.purchaseState());
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }

        // 기록·등급 한 트랜잭션 (같은 토큰 동시 요청은 purchase_token UNIQUE 위반으로 한쪽만 성공)
        EntitlementPurchase savedPurchase;
        try {
            savedPurchase = transactionTemplate.execute(
                status -> recordPurchaseAndExtendPlan(memberUuid, request, snapshot));
        } catch (DataIntegrityViolationException exception) {
            return handleConcurrentDuplicate(memberUuid, request.purchaseToken());
        }

        // 커밋 후 소모 (Play 에서 이미 소모된 구매는 기록만 맞춤)
        if (snapshot.consumptionState() == CONSUMPTION_STATE_CONSUMED) {
            markConsumed(savedPurchase.getPurchaseToken());
        } else {
            consumeAndMark(savedPurchase);
        }
        return featureAccessPolicy.getPlan(memberUuid);
    }

    /**
     * 환불 회수: 최근 30일 환불 토큰 조회 > 검증 상태 구매만 REVOKED > 회원 만료일 재계산
     * 이미 회수한 구매는 건너뜀 (반복 실행 안전), 서비스 계정 키 없으면 건너뜀
     */
    public void revokeVoidedPurchases() {
        if (!playDeveloperApiClient.isConfigured()) {
            log.info("[billing] voided purchase check skipped : service account not configured");
            return;
        }
        Instant since = clock.instant().minus(VOIDED_PURCHASE_LOOKBACK);
        List<String> voidedPurchaseTokens = playDeveloperApiClient.listVoidedPurchaseTokens(since);

        // 건별 트랜잭션 (한 건 실패가 나머지를 막지 않음)
        int revokedCount = 0;
        for (String purchaseToken : voidedPurchaseTokens) {
            try {
                Boolean isRevoked = transactionTemplate.execute(status -> revokePurchaseIfVerified(purchaseToken));
                if (Boolean.TRUE.equals(isRevoked)) {
                    revokedCount++;
                }
            } catch (RuntimeException exception) {
                log.warn("[billing] revoke failed : cause={}", exception.getClass().getSimpleName());
            }
        }
        log.info("[billing] voided purchases checked : voided={}, revoked={}", voidedPurchaseTokens.size(), revokedCount);
    }

    /** 기록된 구매: 다른 회원 > 거절, 회수됨 > 거절, 미소모 > 소모 재시도, 그 뒤 내 등급 */
    private MemberPlanResponse handleRecordedPurchase(UUID memberUuid, EntitlementPurchase purchase) {
        if (!purchase.getMemberUuid().equals(memberUuid)) {
            log.warn("[billing] rejected 403 : purchase owned by another member, member={}, order={}",
                memberUuid, purchase.getOrderId());
            throw new CustomException(ErrorCode.ACCESS_DENIED);
        }
        if (purchase.getStatus() == PurchaseStatus.REVOKED) {
            log.info("[billing] rejected 400 : revoked purchase, member={}, order={}", memberUuid, purchase.getOrderId());
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }
        if (!Boolean.TRUE.equals(purchase.getIsConsumed())) {
            consumeAndMark(purchase);
        }
        return featureAccessPolicy.getPlan(memberUuid);
    }

    /** 동시 요청으로 UNIQUE 위반: 먼저 저장된 기록이 있으면 그 기준, 없으면 409 */
    private MemberPlanResponse handleConcurrentDuplicate(UUID memberUuid, String purchaseToken) {
        Optional<EntitlementPurchase> recordedPurchase = entitlementPurchaseRepository.findByPurchaseToken(purchaseToken);
        if (recordedPurchase.isPresent()) {
            log.info("[billing] duplicate verify resolved : member={}, order={}", memberUuid, recordedPurchase.get().getOrderId());
            return handleRecordedPurchase(memberUuid, recordedPurchase.get());
        }
        log.warn("[billing] rejected 409 : purchase save conflict, member={}", memberUuid);
        throw new CustomException(ErrorCode.DATA_INTEGRITY_VIOLATION);
    }

    /** 구매 기록 저장 + 등급 생성·연장 (트랜잭션 안, 회원 등급 행 잠금) */
    private EntitlementPurchase recordPurchaseAndExtendPlan(UUID memberUuid, PlayVerifyRequest request,
                                                            PlayPurchaseSnapshot snapshot) {
        LocalDateTime purchasedAt = LocalDateTime.ofInstant(snapshot.purchasedAt(), SERVICE_ZONE);
        Optional<MemberEntitlement> entitlement = memberEntitlementRepository.findForUpdateByMemberUuid(memberUuid);
        LocalDateTime currentProExpiresAt = entitlement
            .filter(existing -> existing.getPlan() == MemberPlan.PRO)
            .map(MemberEntitlement::getExpiresAt)
            .orElse(null);
        LocalDateTime newExpiresAt = examPassExpiryCalculator.calculateExpiresAt(purchasedAt, currentProExpiresAt);

        // 구매 기록 먼저 (중복 토큰이면 여기서 즉시 실패)
        EntitlementPurchase purchase = entitlementPurchaseRepository.saveAndFlush(EntitlementPurchase.verified(
            memberUuid, PurchaseStore.PLAY, request.productId(), snapshot.orderId(), request.purchaseToken(),
            purchasedAt, newExpiresAt));

        // 등급 행 없으면 생성, 있으면 연장
        if (entitlement.isPresent()) {
            entitlement.get().extendTo(newExpiresAt, EntitlementSource.PLAY_PURCHASE);
        } else {
            memberEntitlementRepository.save(
                MemberEntitlement.of(memberUuid, MemberPlan.PRO, newExpiresAt, EntitlementSource.PLAY_PURCHASE));
        }
        log.info("[billing] verified : member={}, order={}, expires {} -> {}",
            memberUuid, snapshot.orderId(), currentProExpiresAt, newExpiresAt);
        return purchase;
    }

    /** Play 소모 > 성공 시 소모 표시, 실패는 경고만 (미소모로 남아 다음 확인 요청에서 재시도) */
    private void consumeAndMark(EntitlementPurchase purchase) {
        try {
            playDeveloperApiClient.consume(purchase.getProductId(), purchase.getPurchaseToken());
        } catch (RuntimeException exception) {
            log.warn("[billing] consume failed : member={}, order={}, cause={}",
                purchase.getMemberUuid(), purchase.getOrderId(), exception.getClass().getSimpleName());
            return;
        }
        markConsumed(purchase.getPurchaseToken());
        log.info("[billing] consumed : member={}, order={}", purchase.getMemberUuid(), purchase.getOrderId());
    }

    /** 소모 완료 표시 (짧은 트랜잭션, 최신 행 기준) */
    private void markConsumed(String purchaseToken) {
        transactionTemplate.executeWithoutResult(status -> entitlementPurchaseRepository
            .findByPurchaseToken(purchaseToken)
            .ifPresent(EntitlementPurchase::markConsumed));
    }

    /** 환불 토큰 1건: 검증 상태 구매만 회수 > 회원 등급 재계산, 회수했으면 true */
    private boolean revokePurchaseIfVerified(String purchaseToken) {
        Optional<EntitlementPurchase> verifiedPurchase = entitlementPurchaseRepository.findByPurchaseToken(purchaseToken)
            .filter(purchase -> purchase.getStatus() == PurchaseStatus.VERIFIED);
        if (verifiedPurchase.isEmpty()) {
            return false;
        }
        EntitlementPurchase purchase = verifiedPurchase.get();
        purchase.markRevoked();
        recalculateEntitlementAfterRevoke(purchase);
        return true;
    }

    /**
     * 회수 후 등급 재계산: 관리자 부여 > 그대로, 남은 유효 구매 최대 만료일이 미래 > 그 날짜로, 아니면 FREE
     */
    private void recalculateEntitlementAfterRevoke(EntitlementPurchase revokedPurchase) {
        UUID memberUuid = revokedPurchase.getMemberUuid();
        Optional<MemberEntitlement> entitlementOptional = memberEntitlementRepository.findForUpdateByMemberUuid(memberUuid);
        if (entitlementOptional.isEmpty()) {
            log.info("[billing] revoked : member={}, order={}, no entitlement", memberUuid, revokedPurchase.getOrderId());
            return;
        }
        MemberEntitlement entitlement = entitlementOptional.get();
        if (entitlement.getSource() == EntitlementSource.ADMIN_GRANT) {
            log.info("[billing] revoked : member={}, order={}, admin grant kept", memberUuid, revokedPurchase.getOrderId());
            return;
        }

        // 남은 유효 구매 중 가장 늦은 만료일 (같은 트랜잭션에서 방금 회수한 건은 상태로 제외)
        LocalDateTime now = LocalDateTime.now(clock);
        Optional<LocalDateTime> remainingExpiresAt = entitlementPurchaseRepository
            .findByMemberUuidAndStatus(memberUuid, PurchaseStatus.VERIFIED).stream()
            .filter(purchase -> purchase.getStatus() == PurchaseStatus.VERIFIED)
            .map(EntitlementPurchase::getGrantedExpiresAt)
            .filter(Objects::nonNull)
            .max(Comparator.naturalOrder())
            .filter(expiresAt -> expiresAt.isAfter(now));

        LocalDateTime beforeExpiresAt = entitlement.getExpiresAt();
        if (remainingExpiresAt.isPresent()) {
            entitlement.extendTo(remainingExpiresAt.get(), EntitlementSource.PLAY_PURCHASE);
        } else {
            entitlement.revoke();
        }
        log.info("[billing] revoked : member={}, order={}, expires {} -> {}",
            memberUuid, revokedPurchase.getOrderId(), beforeExpiresAt, entitlement.getExpiresAt());
    }
}
