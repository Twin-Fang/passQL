package com.passql.application.billing;

import com.passql.application.billing.StorePurchaseRecorder.PlanExtension;
import com.passql.application.billing.StorePurchaseRecorder.VerifiedStorePurchase;
import com.passql.application.entitlement.EntitlementPurchaseRevoker;
import com.passql.application.entitlement.EntitlementPurchaseRevoker.RevocationResult;
import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.application.entitlement.MemberPlanResponse;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.Sha256Hex;
import com.passql.member.constant.PassProduct;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;
import com.passql.member.entity.EntitlementPurchase;
import com.passql.member.repository.EntitlementPurchaseRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.util.StringUtils;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Play 이용권 결제(PassProduct 1개월·3개월): 구매 확인·등급 부여, 소모, 환불 회수
 * 기록·등급 변경은 한 트랜잭션(ON CONFLICT 저장) > 커밋 후 소모 (소모 실패는 다음 확인 요청에서 재시도)
 */
@Slf4j
@Service
public class PlayBillingService {

    // Play purchaseState: 0 구매 완료, 1 취소, 2 대기
    private static final int PURCHASE_STATE_PURCHASED = 0;
    private static final int PURCHASE_STATE_PENDING = 2;
    // Play consumptionState: 1 소모 완료
    private static final int CONSUMPTION_STATE_CONSUMED = 1;
    // 환불 조회 기간 (Play 허용 최대 30일, 요청 지연 여유 10분)
    private static final Duration VOIDED_PURCHASE_LOOKBACK = Duration.ofDays(30).minusMinutes(10);
    // 서비스 기준 시간대 (만료일·구매 시각은 KST 로컬 저장값)
    private static final ZoneId SERVICE_ZONE = ZoneId.of("Asia/Seoul");
    // 주문 번호 없는 구매의 대체값: 접두사 + SHA-256(토큰) 16진수 앞 32자
    private static final String FALLBACK_ORDER_ID_PREFIX = "PLAY-NO-ORDER-";
    private static final int FALLBACK_ORDER_ID_HEX_LENGTH = 32;

    private final PlayDeveloperApiClient playDeveloperApiClient;
    private final EntitlementPurchaseRepository entitlementPurchaseRepository;
    private final EntitlementPurchaseRevoker entitlementPurchaseRevoker;
    private final StorePurchaseRecorder storePurchaseRecorder;
    private final FeatureAccessPolicy featureAccessPolicy;
    private final TransactionTemplate transactionTemplate;
    private final Clock clock;

    @Autowired
    public PlayBillingService(PlayDeveloperApiClient playDeveloperApiClient,
                              EntitlementPurchaseRepository entitlementPurchaseRepository,
                              EntitlementPurchaseRevoker entitlementPurchaseRevoker,
                              StorePurchaseRecorder storePurchaseRecorder,
                              FeatureAccessPolicy featureAccessPolicy,
                              TransactionTemplate transactionTemplate) {
        this(playDeveloperApiClient, entitlementPurchaseRepository, entitlementPurchaseRevoker,
            storePurchaseRecorder, featureAccessPolicy, transactionTemplate, Clock.system(SERVICE_ZONE));
    }

    PlayBillingService(PlayDeveloperApiClient playDeveloperApiClient,
                       EntitlementPurchaseRepository entitlementPurchaseRepository,
                       EntitlementPurchaseRevoker entitlementPurchaseRevoker,
                       StorePurchaseRecorder storePurchaseRecorder,
                       FeatureAccessPolicy featureAccessPolicy,
                       TransactionTemplate transactionTemplate, Clock clock) {
        this.playDeveloperApiClient = playDeveloperApiClient;
        this.entitlementPurchaseRepository = entitlementPurchaseRepository;
        this.entitlementPurchaseRevoker = entitlementPurchaseRevoker;
        this.storePurchaseRecorder = storePurchaseRecorder;
        this.featureAccessPolicy = featureAccessPolicy;
        this.transactionTemplate = transactionTemplate;
        this.clock = clock;
    }

    /**
     * 구매 확인: 상품 검증 > 기존 기록 처리 > Play 조회 > 구매 계정 대조 > 기록·등급 저장 > 커밋 후 소모 > 내 등급
     * 대기 구매는 저장·소모 없이 현재 등급 반환
     */
    public MemberPlanResponse verify(UUID memberUuid, PlayVerifyRequest request) {
        // 판매 중인 이용권만 허용 (옛 pro_exam_pass 포함 그 외 ID 거절)
        PassProduct passProduct = PassProduct.fromProductId(request.productId()).orElseThrow(() -> {
            log.info("[billing] rejected 400 : unknown product, member={}", memberUuid);
            return new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        });

        // 이미 기록된 토큰: 연장 없이 소모만 재시도
        Optional<EntitlementPurchase> recordedPurchase =
            entitlementPurchaseRepository.findByPurchaseToken(request.purchaseToken());
        if (recordedPurchase.isPresent()) {
            return handleRecordedPurchase(memberUuid, recordedPurchase.get());
        }

        // Play 구매 상태 확인 (대기 > 그대로, 취소 > 거절)
        PlayPurchaseSnapshot snapshot =
            playDeveloperApiClient.getProductPurchase(request.productId(), request.purchaseToken());
        assertPurchasedBySameAccount(memberUuid, snapshot);
        if (snapshot.purchaseState() == PURCHASE_STATE_PENDING) {
            log.info("[billing] pending : member={}, order={}", memberUuid, snapshot.orderId());
            return featureAccessPolicy.getPlan(memberUuid);
        }
        if (snapshot.purchaseState() != PURCHASE_STATE_PURCHASED) {
            log.info("[billing] rejected 400 : purchase not completed, member={}, order={}, state={}",
                memberUuid, snapshot.orderId(), snapshot.purchaseState());
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }

        // 기록·등급 한 트랜잭션 (같은 토큰·주문은 ON CONFLICT 로 0건 > 기존 기록 경로)
        VerifiedStorePurchase verifiedPurchase = new VerifiedStorePurchase(PurchaseStore.PLAY, passProduct,
            resolveOrderId(memberUuid, snapshot.orderId(), request.purchaseToken()), request.purchaseToken(),
            snapshot.purchasedAt(), false);
        Optional<PlanExtension> planExtension = transactionTemplate.execute(status -> storePurchaseRecorder
            .recordPurchaseAndExtendPlan(memberUuid, verifiedPurchase, clock.instant()));
        if (planExtension == null || planExtension.isEmpty()) {
            return handleConflictedPurchase(memberUuid, request.purchaseToken());
        }
        log.info("[billing] verified : member={}, order={}, expires {} -> {}", memberUuid,
            planExtension.get().orderId(), planExtension.get().beforeExpiresAt(), planExtension.get().afterExpiresAt());

        // 커밋 후 소모 (Play 에서 이미 소모된 구매는 기록만 맞춤)
        EntitlementPurchase savedPurchase = entitlementPurchaseRepository.findByPurchaseToken(request.purchaseToken())
            .orElseThrow(() -> new CustomException(ErrorCode.INTERNAL_SERVER_ERROR));
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

    /**
     * 회원 uuid > Play 계정 값 (소문자 하이픈 문자열 UTF-8 > SHA-256 소문자 hex 64자)
     * 앱 PurchaseParam.applicationUserName 과 같은 계산 (앱 play_account_identifier.dart)
     */
    static String toObfuscatedAccountId(UUID memberUuid) {
        return Sha256Hex.of(memberUuid.toString());
    }

    /**
     * 구매 계정 대조: Play 계정 값 <-> SHA-256(요청 회원 uuid), 다르면 ACCESS_DENIED (기록·소모 전)
     * 값 없는 구매(예전 앱·테스트 구매)는 통과
     */
    private static void assertPurchasedBySameAccount(UUID memberUuid, PlayPurchaseSnapshot snapshot) {
        String purchasedAccountId = snapshot.obfuscatedExternalAccountId();
        if (!StringUtils.hasText(purchasedAccountId)) {
            return;
        }
        if (!purchasedAccountId.equals(toObfuscatedAccountId(memberUuid))) {
            log.warn("[billing] rejected 403 : account mismatch, member={}, order={}", memberUuid, snapshot.orderId());
            throw new CustomException(ErrorCode.ACCESS_DENIED);
        }
    }

    /** Play 주문 번호, 없으면 대체값 (같은 토큰은 항상 같은 값) */
    private static String resolveOrderId(UUID memberUuid, String playOrderId, String purchaseToken) {
        if (StringUtils.hasText(playOrderId)) {
            return playOrderId;
        }
        log.warn("[billing] missing order id, using fallback : member={}", memberUuid);
        return FALLBACK_ORDER_ID_PREFIX + Sha256Hex.of(purchaseToken).substring(0, FALLBACK_ORDER_ID_HEX_LENGTH);
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

    /** 저장 충돌(0건): 같은 토큰 기록이 있으면 기존 기록 경로, 없으면(다른 토큰의 같은 주문 번호) 409 */
    private MemberPlanResponse handleConflictedPurchase(UUID memberUuid, String purchaseToken) {
        Optional<EntitlementPurchase> recordedPurchase = entitlementPurchaseRepository.findByPurchaseToken(purchaseToken);
        if (recordedPurchase.isPresent()) {
            log.info("[billing] duplicate verify resolved : member={}, order={}", memberUuid, recordedPurchase.get().getOrderId());
            return handleRecordedPurchase(memberUuid, recordedPurchase.get());
        }
        log.warn("[billing] rejected 409 : order id already recorded with another token, member={}", memberUuid);
        throw new CustomException(ErrorCode.DATA_INTEGRITY_VIOLATION);
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

    /** 환불 토큰 1건: 검증 상태 구매만 회수 > 회원 등급 재계산(공통 회수기), 회수했으면 true */
    private boolean revokePurchaseIfVerified(String purchaseToken) {
        Optional<EntitlementPurchase> verifiedPurchase = entitlementPurchaseRepository.findByPurchaseToken(purchaseToken)
            .filter(purchase -> purchase.getStatus() == PurchaseStatus.VERIFIED);
        if (verifiedPurchase.isEmpty()) {
            return false;
        }
        EntitlementPurchase purchase = verifiedPurchase.get();
        RevocationResult revocationResult = entitlementPurchaseRevoker.revokeAndRecalculate(purchase, LocalDateTime.now(clock));
        // 재계산 종류별 로그 (등급 행 없음, 관리자 부여 유지, 만료일 변경)
        switch (revocationResult.kind()) {
            case NO_ENTITLEMENT -> log.info("[billing] revoked : member={}, order={}, no entitlement",
                purchase.getMemberUuid(), purchase.getOrderId());
            case ADMIN_GRANT_KEPT -> log.info("[billing] revoked : member={}, order={}, admin grant kept",
                purchase.getMemberUuid(), purchase.getOrderId());
            case RECALCULATED -> log.info("[billing] revoked : member={}, order={}, expires {} -> {}",
                purchase.getMemberUuid(), purchase.getOrderId(), revocationResult.beforeExpiresAt(), revocationResult.afterExpiresAt());
        }
        return true;
    }
}
