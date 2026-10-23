package com.passql.application.billing;

import com.passql.application.billing.StorePurchaseRecorder.PlanExtension;
import com.passql.application.billing.StorePurchaseRecorder.VerifiedStorePurchase;
import com.passql.application.entitlement.EntitlementPurchaseRevoker;
import com.passql.application.entitlement.EntitlementPurchaseRevoker.RevocationResult;
import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.application.entitlement.MemberPlanResponse;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.PassProduct;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;
import com.passql.member.entity.EntitlementPurchase;
import com.passql.member.repository.EntitlementPurchaseRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

/**
 * App Store 이용권 결제(PassProduct 1개월·3개월 비갱신 구독): 구매 확인·등급 부여, 서버 알림 환불 회수 (#578)
 * 서명 검증(SignedDataVerifier) > 거래 대조 > 기록·등급 한 트랜잭션 (소모 개념 없음, 기록은 소모 완료로 저장)
 */
@Slf4j
@Service
public class AppStoreBillingService {

    // App Store 상품 유형: 비갱신 구독 (이용권 상품은 이 유형만 허용)
    static final String NON_RENEWING_SUBSCRIPTION_TYPE = "Non-Renewing Subscription";
    // purchase_token 저장값: 접두사 + transactionId (Play 토큰과 구분, 거래 JWS 원문은 저장하지 않음)
    static final String PURCHASE_TOKEN_PREFIX = "appstore:";
    // 등급 회수 대상 알림 유형 2개: REFUND 환불, REVOKE 가족 공유 해제 등 회수
    private static final Set<String> REVOKING_NOTIFICATION_TYPES = Set.of("REFUND", "REVOKE");
    // 서비스 기준 시간대 (만료일·구매 시각은 KST 로컬 저장값)
    private static final ZoneId SERVICE_ZONE = ZoneId.of("Asia/Seoul");

    private final AppStoreSignedDataVerifier appStoreSignedDataVerifier;
    private final EntitlementPurchaseRepository entitlementPurchaseRepository;
    private final EntitlementPurchaseRevoker entitlementPurchaseRevoker;
    private final StorePurchaseRecorder storePurchaseRecorder;
    private final FeatureAccessPolicy featureAccessPolicy;
    private final TransactionTemplate transactionTemplate;
    private final Clock clock;

    @Autowired
    public AppStoreBillingService(AppStoreSignedDataVerifier appStoreSignedDataVerifier,
                                  EntitlementPurchaseRepository entitlementPurchaseRepository,
                                  EntitlementPurchaseRevoker entitlementPurchaseRevoker,
                                  StorePurchaseRecorder storePurchaseRecorder,
                                  FeatureAccessPolicy featureAccessPolicy,
                                  TransactionTemplate transactionTemplate) {
        this(appStoreSignedDataVerifier, entitlementPurchaseRepository, entitlementPurchaseRevoker,
            storePurchaseRecorder, featureAccessPolicy, transactionTemplate, Clock.system(SERVICE_ZONE));
    }

    AppStoreBillingService(AppStoreSignedDataVerifier appStoreSignedDataVerifier,
                           EntitlementPurchaseRepository entitlementPurchaseRepository,
                           EntitlementPurchaseRevoker entitlementPurchaseRevoker,
                           StorePurchaseRecorder storePurchaseRecorder,
                           FeatureAccessPolicy featureAccessPolicy,
                           TransactionTemplate transactionTemplate, Clock clock) {
        this.appStoreSignedDataVerifier = appStoreSignedDataVerifier;
        this.entitlementPurchaseRepository = entitlementPurchaseRepository;
        this.entitlementPurchaseRevoker = entitlementPurchaseRevoker;
        this.storePurchaseRecorder = storePurchaseRecorder;
        this.featureAccessPolicy = featureAccessPolicy;
        this.transactionTemplate = transactionTemplate;
        this.clock = clock;
    }

    /**
     * 구매 확인: 결제 스위치 > 상품 검증 > 서명 검증 > 거래 대조(번들·상품·유형·계정) > 기존 기록 처리 > 기록·등급 저장 > 내 등급
     * 같은 거래 재전송은 연장 없이 현재 등급 반환
     */
    public MemberPlanResponse verify(UUID memberUuid, AppStoreVerifyRequest request) {
        // 결제 스위치 꺼짐 > 결제 UI 가 없어야 하는 상태라 거절
        if (!featureAccessPolicy.isBillingEnabled()) {
            log.info("[billing] app store rejected 400 : billing disabled, member={}", memberUuid);
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }
        // 판매 중인 이용권만 허용
        PassProduct passProduct = PassProduct.fromProductId(request.productId()).orElseThrow(() -> {
            log.info("[billing] app store rejected 400 : unknown product, member={}", memberUuid);
            return new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        });

        // 서명 검증 > 거래 대조
        AppStoreTransaction transaction = appStoreSignedDataVerifier.verifyTransaction(request.signedTransaction());
        assertTransactionMatchesRequest(memberUuid, passProduct, transaction);
        assertPurchasedBySameAccount(memberUuid, transaction);

        // 이미 기록된 거래: 연장 없이 현재 등급
        String purchaseToken = toPurchaseToken(transaction.transactionId());
        Optional<EntitlementPurchase> recordedPurchase = entitlementPurchaseRepository.findByPurchaseToken(purchaseToken);
        if (recordedPurchase.isPresent()) {
            return handleRecordedPurchase(memberUuid, recordedPurchase.get());
        }
        if (transaction.revokedAt() != null) {
            log.info("[billing] app store rejected 400 : revoked transaction, member={}, transaction={}",
                memberUuid, transaction.transactionId());
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }

        // 기록·등급 한 트랜잭션 (같은 거래는 ON CONFLICT 로 0건 > 기존 기록 경로)
        VerifiedStorePurchase verifiedPurchase = new VerifiedStorePurchase(PurchaseStore.APP_STORE, passProduct,
            transaction.transactionId(), purchaseToken, transaction.purchasedAt(), true);
        Optional<PlanExtension> planExtension = transactionTemplate.execute(status -> storePurchaseRecorder
            .recordPurchaseAndExtendPlan(memberUuid, verifiedPurchase, clock.instant()));
        if (planExtension == null || planExtension.isEmpty()) {
            return handleConflictedPurchase(memberUuid, purchaseToken);
        }
        log.info("[billing] app store verified : member={}, transaction={}, environment={}, expires {} -> {}",
            memberUuid, transaction.transactionId(), transaction.environment(),
            planExtension.get().beforeExpiresAt(), planExtension.get().afterExpiresAt());
        return featureAccessPolicy.getPlan(memberUuid);
    }

    /**
     * 서버 알림 V2: 서명 검증(실패 400) > REFUND·REVOKE 만 해당 거래 회수 > 그 외 유형은 기록만
     * 기록 없는 거래·이미 회수한 거래는 건너뜀 (Apple 재전송 안전)
     */
    public void handleNotification(AppStoreNotificationRequest request) {
        AppStoreNotification notification = appStoreSignedDataVerifier.verifyNotification(request.signedPayload());
        if (!REVOKING_NOTIFICATION_TYPES.contains(notification.notificationType())) {
            log.info("[billing] app store notification ignored : type={}, subtype={}, notification={}",
                notification.notificationType(), notification.subtype(), notification.notificationUuid());
            return;
        }
        if (notification.transaction() == null) {
            log.warn("[billing] app store notification ignored : type={}, no transaction, notification={}",
                notification.notificationType(), notification.notificationUuid());
            return;
        }
        String transactionId = notification.transaction().transactionId();
        Boolean isRevoked = transactionTemplate.execute(status -> revokePurchaseIfVerified(transactionId));
        if (!Boolean.TRUE.equals(isRevoked)) {
            log.info("[billing] app store notification ignored : type={}, transaction={}, no verified purchase",
                notification.notificationType(), transactionId);
        }
    }

    /** App Store 거래 > purchase_token 저장값 ("appstore:" + transactionId) */
    static String toPurchaseToken(String transactionId) {
        return PURCHASE_TOKEN_PREFIX + transactionId;
    }

    /** 거래 대조 3개: 번들 ID, 상품 ID(요청 <-> 거래), 비갱신 구독 유형 — 다르면 400 (기록 전) */
    private static void assertTransactionMatchesRequest(UUID memberUuid, PassProduct passProduct,
                                                        AppStoreTransaction transaction) {
        String mismatchReason = findTransactionMismatchReason(passProduct, transaction);
        if (mismatchReason != null) {
            log.info("[billing] app store rejected 400 : {}, member={}, transaction={}",
                mismatchReason, memberUuid, transaction.transactionId());
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }
    }

    /** 거래 불일치 사유 (일치하면 null) */
    private static String findTransactionMismatchReason(PassProduct passProduct, AppStoreTransaction transaction) {
        if (!AppleAppStoreSignedDataVerifier.BUNDLE_ID.equals(transaction.bundleId())) {
            return "bundle mismatch";
        }
        if (!passProduct.getProductId().equals(transaction.productId())) {
            return "product mismatch";
        }
        if (!NON_RENEWING_SUBSCRIPTION_TYPE.equals(transaction.type())) {
            return "unsupported product type";
        }
        return null;
    }

    /**
     * 구매 계정 대조: 거래 appAccountToken <-> 요청 회원 uuid, 다르면 ACCESS_DENIED (기록 전)
     * 값 없는 거래(예전 앱·테스트 구매)는 통과 (Play 계정 값 없는 구매와 같은 기준)
     */
    private static void assertPurchasedBySameAccount(UUID memberUuid, AppStoreTransaction transaction) {
        UUID appAccountToken = transaction.appAccountToken();
        if (appAccountToken == null) {
            return;
        }
        if (!appAccountToken.equals(memberUuid)) {
            log.warn("[billing] app store rejected 403 : account mismatch, member={}, transaction={}",
                memberUuid, transaction.transactionId());
            throw new CustomException(ErrorCode.ACCESS_DENIED);
        }
    }

    /** 기록된 구매: 다른 회원 > 거절, 회수됨 > 거절, 그 외 내 등급 */
    private MemberPlanResponse handleRecordedPurchase(UUID memberUuid, EntitlementPurchase purchase) {
        if (!purchase.getMemberUuid().equals(memberUuid)) {
            log.warn("[billing] app store rejected 403 : purchase owned by another member, member={}, transaction={}",
                memberUuid, purchase.getOrderId());
            throw new CustomException(ErrorCode.ACCESS_DENIED);
        }
        if (purchase.getStatus() == PurchaseStatus.REVOKED) {
            log.info("[billing] app store rejected 400 : revoked purchase, member={}, transaction={}",
                memberUuid, purchase.getOrderId());
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }
        return featureAccessPolicy.getPlan(memberUuid);
    }

    /** 저장 충돌(0건): 같은 거래 기록이 있으면 기존 기록 경로, 없으면(같은 주문 번호 다른 토큰) 409 */
    private MemberPlanResponse handleConflictedPurchase(UUID memberUuid, String purchaseToken) {
        Optional<EntitlementPurchase> recordedPurchase = entitlementPurchaseRepository.findByPurchaseToken(purchaseToken);
        if (recordedPurchase.isPresent()) {
            log.info("[billing] app store duplicate verify resolved : member={}, transaction={}",
                memberUuid, recordedPurchase.get().getOrderId());
            return handleRecordedPurchase(memberUuid, recordedPurchase.get());
        }
        log.warn("[billing] app store rejected 409 : transaction id already recorded with another token, member={}", memberUuid);
        throw new CustomException(ErrorCode.DATA_INTEGRITY_VIOLATION);
    }

    /** 환불 거래 1건: App Store 검증 상태 구매만 회수 > 회원 등급 재계산(공통 회수기), 회수했으면 true */
    private boolean revokePurchaseIfVerified(String transactionId) {
        Optional<EntitlementPurchase> verifiedPurchase = entitlementPurchaseRepository.findByOrderId(transactionId)
            .filter(purchase -> purchase.getStore() == PurchaseStore.APP_STORE)
            .filter(purchase -> purchase.getStatus() == PurchaseStatus.VERIFIED);
        if (verifiedPurchase.isEmpty()) {
            return false;
        }
        EntitlementPurchase purchase = verifiedPurchase.get();
        RevocationResult revocationResult = entitlementPurchaseRevoker.revokeAndRecalculate(purchase, LocalDateTime.now(clock));
        // 재계산 종류별 로그 (등급 행 없음, 관리자 부여 유지, 만료일 변경)
        switch (revocationResult.kind()) {
            case NO_ENTITLEMENT -> log.info("[billing] app store revoked : member={}, transaction={}, no entitlement",
                purchase.getMemberUuid(), purchase.getOrderId());
            case ADMIN_GRANT_KEPT -> log.info("[billing] app store revoked : member={}, transaction={}, admin grant kept",
                purchase.getMemberUuid(), purchase.getOrderId());
            case RECALCULATED -> log.info("[billing] app store revoked : member={}, transaction={}, expires {} -> {}",
                purchase.getMemberUuid(), purchase.getOrderId(), revocationResult.beforeExpiresAt(),
                revocationResult.afterExpiresAt());
        }
        return true;
    }
}
