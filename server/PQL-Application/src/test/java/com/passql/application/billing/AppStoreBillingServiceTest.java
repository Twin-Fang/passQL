package com.passql.application.billing;

import com.passql.application.entitlement.DailyQuestionCounter;
import com.passql.application.entitlement.EntitlementPurchaseRevoker;
import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.application.entitlement.MemberPlanResponse;
import com.passql.application.entitlement.PassExpiryCalculator;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.EntitlementSource;
import com.passql.member.constant.MemberPlan;
import com.passql.member.constant.PassProduct;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;
import com.passql.member.entity.EntitlementPurchase;
import com.passql.member.entity.MemberEntitlement;
import com.passql.member.repository.EntitlementPurchaseRepository;
import com.passql.member.repository.MemberEntitlementRepository;
import com.passql.member.repository.MemberRepository;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * App Store 이용권 결제: 구매 확인(1개월·3개월) > 등급 부여, 번들·상품·계정 불일치·중복·스위치 꺼짐 거절, 서버 알림 환불 회수
 * 서명 검증은 가짜 검증기, 저장소는 메모리 맵 기반 목
 */
class AppStoreBillingServiceTest {

    private static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");
    // 고정 현재 시각 (등급 판정은 시스템 시계라 실제 현재와 맞춤)
    private static final Clock FIXED_CLOCK = Clock.fixed(Instant.now().truncatedTo(ChronoUnit.SECONDS), SEOUL);
    // App Store 구매 시각: 현재 1시간 전
    private static final Instant PURCHASED_INSTANT = FIXED_CLOCK.instant().minus(1, ChronoUnit.HOURS);
    private static final LocalDateTime EXPECTED_THREE_MONTH_EXPIRES_AT =
        LocalDateTime.ofInstant(PURCHASED_INSTANT, SEOUL).plusDays(PassProduct.PRO_PASS_3M.getDurationDays());
    private static final String SIGNED_TRANSACTION = "signed-transaction-1";
    private static final String SECOND_SIGNED_TRANSACTION = "signed-transaction-2";
    private static final String TRANSACTION_ID = "2000000000000001";
    private static final String SECOND_TRANSACTION_ID = "2000000000000002";
    // 거래 결제 금액 고정값 (테스트용 1,100 KRW = 1,100,000 밀리 단위)
    private static final StorePrice THREE_MONTH_PRICE = StorePrice.fromAppStoreMilliunits(1_100_000L, "KRW");

    private final FakeAppStoreSignedDataVerifier verifier = new FakeAppStoreSignedDataVerifier();
    private final EntitlementPurchaseRepository purchaseRepository = mock(EntitlementPurchaseRepository.class);
    private final MemberEntitlementRepository entitlementRepository = mock(MemberEntitlementRepository.class);
    private final AppSettingService appSettingService = mock(AppSettingService.class);
    private final PassExpiryCalculator expiryCalculator = new PassExpiryCalculator();
    private final FeatureAccessPolicy featureAccessPolicy = new FeatureAccessPolicy(
        entitlementRepository, appSettingService, expiryCalculator,
        mock(SubmissionRepository.class), mock(DailyQuestionCounter.class), purchaseRepository);
    private final AppStoreBillingService appStoreBillingService = new AppStoreBillingService(
        verifier, purchaseRepository, new EntitlementPurchaseRevoker(purchaseRepository, entitlementRepository, expiryCalculator),
        new StorePurchaseRecorder(purchaseRepository, entitlementRepository, mock(MemberRepository.class), expiryCalculator),
        featureAccessPolicy, new TransactionTemplate(mock(PlatformTransactionManager.class)), FIXED_CLOCK);

    // 메모리 저장소 (구매: 토큰별, 등급: 회원별)
    private final Map<String, EntitlementPurchase> purchaseByToken = new HashMap<>();
    private final Map<UUID, MemberEntitlement> entitlementByMember = new HashMap<>();
    // 기록 INSERT 로 넘긴 결제 금액 (토큰별, 금액 미기록이면 null 값)
    private final Map<String, StorePrice> savedPriceByToken = new HashMap<>();
    private final UUID memberUuid = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        when(appSettingService.getBooleanOrDefault(eq(AppSettingKeys.BILLING_ANDROID_ENABLED), anyBoolean()))
            .thenReturn(true);

        // 구매 저장소 (토큰·주문 번호 조회, 저장, 회원·상태 조회)
        when(purchaseRepository.findByPurchaseToken(any()))
            .thenAnswer(call -> Optional.ofNullable(purchaseByToken.get(call.<String>getArgument(0))));
        when(purchaseRepository.findByOrderId(any())).thenAnswer(call -> purchaseByToken.values().stream()
            .filter(purchase -> purchase.getOrderId().equals(call.getArgument(0)))
            .findFirst());
        // 기록 INSERT: 토큰·주문 번호 충돌이면 0건 (ON CONFLICT DO NOTHING 과 같게), 소모 값 반영
        when(purchaseRepository.insertVerifiedIfAbsent(any(), any(), any(), any(), any(), any(), any(), any(), any(),
            any(), any(), any(), any(), any(), any())).thenAnswer(call -> {
            String orderId = call.getArgument(4);
            String purchaseToken = call.getArgument(5);
            boolean isConflicted = purchaseByToken.containsKey(purchaseToken) || purchaseByToken.values().stream()
                .anyMatch(purchase -> purchase.getOrderId().equals(orderId));
            if (isConflicted) {
                return 0;
            }
            Long priceAmountMicros = call.getArgument(13);
            String currencyCode = call.getArgument(14);
            savedPriceByToken.put(purchaseToken,
                priceAmountMicros != null ? new StorePrice(priceAmountMicros, currencyCode) : null);
            EntitlementPurchase purchase = EntitlementPurchase.verified(call.getArgument(1),
                PurchaseStore.valueOf(call.getArgument(2)), call.getArgument(3), orderId, purchaseToken,
                call.getArgument(6), call.getArgument(8), call.getArgument(9));
            if (Boolean.TRUE.equals(call.getArgument(10))) {
                purchase.markConsumed();
            }
            purchaseByToken.put(purchaseToken, purchase);
            return 1;
        });
        when(purchaseRepository.findByMemberUuidAndStatus(any(), any())).thenAnswer(call -> purchaseByToken.values()
            .stream()
            .filter(purchase -> purchase.getMemberUuid().equals(call.getArgument(0)))
            .filter(purchase -> purchase.getStatus() == call.getArgument(1))
            .toList());
        when(purchaseRepository.findFirstByMemberUuidAndStatusOrderByPurchasedAtDesc(any(), any()))
            .thenAnswer(call -> purchaseByToken.values().stream()
                .filter(purchase -> purchase.getMemberUuid().equals(call.getArgument(0)))
                .filter(purchase -> purchase.getStatus() == call.getArgument(1))
                .max(Comparator.comparing(EntitlementPurchase::getPurchasedAt)));

        // 등급 저장소 (조회, 잠금 조회, 저장)
        when(entitlementRepository.findById(any()))
            .thenAnswer(call -> Optional.ofNullable(entitlementByMember.get(call.<UUID>getArgument(0))));
        when(entitlementRepository.findForUpdateByMemberUuid(any()))
            .thenAnswer(call -> Optional.ofNullable(entitlementByMember.get(call.<UUID>getArgument(0))));
        when(entitlementRepository.save(any())).thenAnswer(call -> {
            MemberEntitlement entitlement = call.getArgument(0);
            entitlementByMember.put(entitlement.getMemberUuid(), entitlement);
            return entitlement;
        });
    }

    /** 정상 비갱신 구독 거래 (appAccountToken 지정 가능) */
    private static AppStoreTransaction transaction(String transactionId, PassProduct passProduct, Instant purchasedAt,
                                                   UUID appAccountToken) {
        return new AppStoreTransaction(transactionId, transactionId, AppleAppStoreSignedDataVerifier.BUNDLE_ID,
            passProduct.getProductId(), AppStoreBillingService.NON_RENEWING_SUBSCRIPTION_TYPE, purchasedAt,
            appAccountToken, null, "Sandbox", THREE_MONTH_PRICE);
    }

    private void registerThreeMonthTransaction() {
        verifier.transactionBySignedTransaction.put(SIGNED_TRANSACTION,
            transaction(TRANSACTION_ID, PassProduct.PRO_PASS_3M, PURCHASED_INSTANT, memberUuid));
    }

    private static AppStoreVerifyRequest threeMonthRequest() {
        return new AppStoreVerifyRequest(PassProduct.PRO_PASS_3M.getProductId(), SIGNED_TRANSACTION);
    }

    private static void assertRejected(Runnable call, ErrorCode expectedErrorCode) {
        assertThatThrownBy(call::run).isInstanceOfSatisfying(CustomException.class,
            exception -> assertThat(exception.getErrorCode()).isEqualTo(expectedErrorCode));
    }

    @Test
    void verify_threeMonthPass_grantsNinetyDays_andRecordsConsumedAppStorePurchase() {
        registerThreeMonthTransaction();

        MemberPlanResponse response = appStoreBillingService.verify(memberUuid, threeMonthRequest());

        assertThat(response.plan()).isEqualTo("PRO");
        assertThat(response.proExpiresAt()).isEqualTo(EXPECTED_THREE_MONTH_EXPIRES_AT);
        EntitlementPurchase purchase = purchaseByToken.get("appstore:" + TRANSACTION_ID);
        assertThat(purchase.getStore()).isEqualTo(PurchaseStore.APP_STORE);
        assertThat(purchase.getOrderId()).isEqualTo(TRANSACTION_ID);
        assertThat(purchase.getGrantedDays()).isEqualTo(PassProduct.PRO_PASS_3M.getDurationDays());
        assertThat(purchase.getIsConsumed()).isTrue();
        assertThat(entitlementByMember.get(memberUuid).getSource()).isEqualTo(EntitlementSource.APP_STORE_PURCHASE);
        assertThat(response.lastOrderId()).isEqualTo(TRANSACTION_ID);
        // 거래 price·currency 그대로 저장 (1,100 KRW > 1,100,000,000 마이크로 단위)
        assertThat(savedPriceByToken.get("appstore:" + TRANSACTION_ID))
            .isEqualTo(new StorePrice(1_100_000_000L, "KRW"));
    }

    @Test
    void verify_transactionWithoutPrice_recordsNullPrice() {
        verifier.transactionBySignedTransaction.put(SIGNED_TRANSACTION, new AppStoreTransaction(TRANSACTION_ID,
            TRANSACTION_ID, AppleAppStoreSignedDataVerifier.BUNDLE_ID, PassProduct.PRO_PASS_3M.getProductId(),
            AppStoreBillingService.NON_RENEWING_SUBSCRIPTION_TYPE, PURCHASED_INSTANT, null, null, "Sandbox", null));

        appStoreBillingService.verify(memberUuid, threeMonthRequest());

        assertThat(savedPriceByToken).containsEntry("appstore:" + TRANSACTION_ID, null);
    }

    @Test
    void verify_oneMonthPass_grantsThirtyDays() {
        verifier.transactionBySignedTransaction.put(SIGNED_TRANSACTION,
            transaction(TRANSACTION_ID, PassProduct.PRO_PASS_1M, PURCHASED_INSTANT, null));

        MemberPlanResponse response = appStoreBillingService.verify(memberUuid,
            new AppStoreVerifyRequest(PassProduct.PRO_PASS_1M.getProductId(), SIGNED_TRANSACTION));

        assertThat(response.proExpiresAt()).isEqualTo(
            LocalDateTime.ofInstant(PURCHASED_INSTANT, SEOUL).plusDays(PassProduct.PRO_PASS_1M.getDurationDays()));
    }

    @Test
    void verify_wrongBundle_rejectedWithoutRecord() {
        verifier.transactionBySignedTransaction.put(SIGNED_TRANSACTION, new AppStoreTransaction(TRANSACTION_ID,
            TRANSACTION_ID, "com.other.app", PassProduct.PRO_PASS_3M.getProductId(),
            AppStoreBillingService.NON_RENEWING_SUBSCRIPTION_TYPE, PURCHASED_INSTANT, null, null, "Production", null));

        assertRejected(() -> appStoreBillingService.verify(memberUuid, threeMonthRequest()), ErrorCode.INVALID_INPUT_VALUE);
        assertThat(purchaseByToken).isEmpty();
    }

    @Test
    void verify_requestProductDiffersFromTransaction_rejected() {
        // 1개월 거래를 3개월로 요청
        verifier.transactionBySignedTransaction.put(SIGNED_TRANSACTION,
            transaction(TRANSACTION_ID, PassProduct.PRO_PASS_1M, PURCHASED_INSTANT, null));

        assertRejected(() -> appStoreBillingService.verify(memberUuid, threeMonthRequest()), ErrorCode.INVALID_INPUT_VALUE);
        assertThat(purchaseByToken).isEmpty();
    }

    @Test
    void verify_unknownProduct_rejectedBeforeSignatureCheck() {
        registerThreeMonthTransaction();

        assertRejected(() -> appStoreBillingService.verify(memberUuid,
            new AppStoreVerifyRequest("pro_exam_pass", SIGNED_TRANSACTION)), ErrorCode.INVALID_INPUT_VALUE);
        assertThat(purchaseByToken).isEmpty();
    }

    @Test
    void verify_nonConsumableType_rejected() {
        verifier.transactionBySignedTransaction.put(SIGNED_TRANSACTION, new AppStoreTransaction(TRANSACTION_ID,
            TRANSACTION_ID, AppleAppStoreSignedDataVerifier.BUNDLE_ID, PassProduct.PRO_PASS_3M.getProductId(),
            "Non-Consumable", PURCHASED_INSTANT, null, null, "Sandbox", null));

        assertRejected(() -> appStoreBillingService.verify(memberUuid, threeMonthRequest()), ErrorCode.INVALID_INPUT_VALUE);
    }

    @Test
    void verify_appAccountTokenOfAnotherMember_rejectedWithoutRecord() {
        verifier.transactionBySignedTransaction.put(SIGNED_TRANSACTION,
            transaction(TRANSACTION_ID, PassProduct.PRO_PASS_3M, PURCHASED_INSTANT, UUID.randomUUID()));

        assertRejected(() -> appStoreBillingService.verify(memberUuid, threeMonthRequest()), ErrorCode.ACCESS_DENIED);
        assertThat(purchaseByToken).isEmpty();
        assertThat(entitlementByMember).isEmpty();
    }

    @Test
    void verify_invalidSignature_rejected() {
        assertRejected(() -> appStoreBillingService.verify(memberUuid, threeMonthRequest()), ErrorCode.INVALID_INPUT_VALUE);
    }

    @Test
    void verify_sameTransactionTwice_doesNotExtendTwice() {
        registerThreeMonthTransaction();

        appStoreBillingService.verify(memberUuid, threeMonthRequest());
        MemberPlanResponse second = appStoreBillingService.verify(memberUuid, threeMonthRequest());

        assertThat(second.proExpiresAt()).isEqualTo(EXPECTED_THREE_MONTH_EXPIRES_AT);
        assertThat(purchaseByToken).hasSize(1);
    }

    @Test
    void verify_transactionRecordedByAnotherMember_rejected() {
        verifier.transactionBySignedTransaction.put(SIGNED_TRANSACTION,
            transaction(TRANSACTION_ID, PassProduct.PRO_PASS_3M, PURCHASED_INSTANT, null));
        appStoreBillingService.verify(memberUuid, threeMonthRequest());
        UUID otherMemberUuid = UUID.randomUUID();

        assertRejected(() -> appStoreBillingService.verify(otherMemberUuid, threeMonthRequest()), ErrorCode.ACCESS_DENIED);
        assertThat(entitlementByMember).doesNotContainKey(otherMemberUuid);
    }

    @Test
    void verify_billingDisabled_rejectedWithoutRecord() {
        registerThreeMonthTransaction();
        when(appSettingService.getBooleanOrDefault(eq(AppSettingKeys.BILLING_ANDROID_ENABLED), anyBoolean()))
            .thenReturn(false);

        assertRejected(() -> appStoreBillingService.verify(memberUuid, threeMonthRequest()), ErrorCode.INVALID_REQUEST);
        assertThat(purchaseByToken).isEmpty();
    }

    @Test
    void verify_billingDisabledButPreviewMember_accepted() {
        // 스위치 꺼짐 + 미리보기 목록 회원 > 심사 계정 구매 확인 통과
        registerThreeMonthTransaction();
        when(appSettingService.getBooleanOrDefault(eq(AppSettingKeys.BILLING_ANDROID_ENABLED), anyBoolean()))
            .thenReturn(false);
        when(appSettingService.getString(AppSettingKeys.BILLING_PREVIEW_MEMBER_UUIDS)).thenReturn(memberUuid.toString());

        MemberPlanResponse response = appStoreBillingService.verify(memberUuid, threeMonthRequest());

        assertThat(response.isBillingEnabled()).isTrue();
        assertThat(response.plan()).isEqualTo("PRO");
        assertThat(purchaseByToken).hasSize(1);
    }

    @Test
    void verify_billingDisabledAndOtherPreviewMember_rejectedWithoutRecord() {
        registerThreeMonthTransaction();
        when(appSettingService.getBooleanOrDefault(eq(AppSettingKeys.BILLING_ANDROID_ENABLED), anyBoolean()))
            .thenReturn(false);
        when(appSettingService.getString(AppSettingKeys.BILLING_PREVIEW_MEMBER_UUIDS))
            .thenReturn(UUID.randomUUID().toString());

        assertRejected(() -> appStoreBillingService.verify(memberUuid, threeMonthRequest()), ErrorCode.INVALID_REQUEST);
        assertThat(purchaseByToken).isEmpty();
    }

    @Test
    void verify_alreadyRevokedTransaction_rejected() {
        verifier.transactionBySignedTransaction.put(SIGNED_TRANSACTION, new AppStoreTransaction(TRANSACTION_ID,
            TRANSACTION_ID, AppleAppStoreSignedDataVerifier.BUNDLE_ID, PassProduct.PRO_PASS_3M.getProductId(),
            AppStoreBillingService.NON_RENEWING_SUBSCRIPTION_TYPE, PURCHASED_INSTANT, null,
            FIXED_CLOCK.instant(), "Sandbox", null));

        assertRejected(() -> appStoreBillingService.verify(memberUuid, threeMonthRequest()), ErrorCode.INVALID_REQUEST);
        assertThat(purchaseByToken).isEmpty();
    }

    @Test
    void notificationRefund_revokesPurchase_andReplaysRemainingPurchases() {
        // 3개월 보유 중 1개월 추가 > 1개월 환불 > 3개월 만료일로 복귀
        registerThreeMonthTransaction();
        appStoreBillingService.verify(memberUuid, threeMonthRequest());
        AppStoreTransaction secondTransaction =
            transaction(SECOND_TRANSACTION_ID, PassProduct.PRO_PASS_1M, FIXED_CLOCK.instant(), memberUuid);
        verifier.transactionBySignedTransaction.put(SECOND_SIGNED_TRANSACTION, secondTransaction);
        appStoreBillingService.verify(memberUuid,
            new AppStoreVerifyRequest(PassProduct.PRO_PASS_1M.getProductId(), SECOND_SIGNED_TRANSACTION));
        verifier.notificationBySignedPayload.put("refund-payload",
            new AppStoreNotification("notification-1", "REFUND", null, secondTransaction));

        appStoreBillingService.handleNotification(new AppStoreNotificationRequest("refund-payload"));

        assertThat(purchaseByToken.get("appstore:" + SECOND_TRANSACTION_ID).getStatus()).isEqualTo(PurchaseStatus.REVOKED);
        MemberEntitlement entitlement = entitlementByMember.get(memberUuid);
        assertThat(entitlement.getExpiresAt()).isEqualTo(EXPECTED_THREE_MONTH_EXPIRES_AT);
        assertThat(entitlement.getSource()).isEqualTo(EntitlementSource.APP_STORE_PURCHASE);
    }

    @Test
    void notificationRevoke_onlyPurchase_becomesFree_andRepeatIsSafe() {
        registerThreeMonthTransaction();
        appStoreBillingService.verify(memberUuid, threeMonthRequest());
        verifier.notificationBySignedPayload.put("revoke-payload", new AppStoreNotification("notification-2", "REVOKE",
            null, transaction(TRANSACTION_ID, PassProduct.PRO_PASS_3M, PURCHASED_INSTANT, memberUuid)));

        appStoreBillingService.handleNotification(new AppStoreNotificationRequest("revoke-payload"));
        appStoreBillingService.handleNotification(new AppStoreNotificationRequest("revoke-payload"));

        assertThat(purchaseByToken.get("appstore:" + TRANSACTION_ID).getStatus()).isEqualTo(PurchaseStatus.REVOKED);
        assertThat(entitlementByMember.get(memberUuid).getPlan()).isEqualTo(MemberPlan.FREE);
        // 회수된 거래 재확인은 거절
        assertRejected(() -> appStoreBillingService.verify(memberUuid, threeMonthRequest()), ErrorCode.INVALID_REQUEST);
    }

    @Test
    void notificationRefund_unknownTransaction_ignored() {
        verifier.notificationBySignedPayload.put("refund-payload", new AppStoreNotification("notification-3", "REFUND",
            null, transaction("9999", PassProduct.PRO_PASS_3M, PURCHASED_INSTANT, null)));

        appStoreBillingService.handleNotification(new AppStoreNotificationRequest("refund-payload"));

        assertThat(purchaseByToken).isEmpty();
        assertThat(entitlementByMember).isEmpty();
    }

    @Test
    void notificationOtherType_doesNotRevoke() {
        registerThreeMonthTransaction();
        appStoreBillingService.verify(memberUuid, threeMonthRequest());
        verifier.notificationBySignedPayload.put("refund-declined-payload", new AppStoreNotification("notification-4",
            "REFUND_DECLINED", null, transaction(TRANSACTION_ID, PassProduct.PRO_PASS_3M, PURCHASED_INSTANT, memberUuid)));

        appStoreBillingService.handleNotification(new AppStoreNotificationRequest("refund-declined-payload"));

        assertThat(purchaseByToken.get("appstore:" + TRANSACTION_ID).getStatus()).isEqualTo(PurchaseStatus.VERIFIED);
    }

    @Test
    void notificationRefund_playPurchaseWithSameOrderId_notRevoked() {
        // 스토어가 다른 구매는 App Store 알림으로 회수하지 않음
        purchaseByToken.put("play-token", EntitlementPurchase.verified(memberUuid, PurchaseStore.PLAY,
            PassProduct.PRO_PASS_3M.getProductId(), TRANSACTION_ID, "play-token",
            LocalDateTime.ofInstant(PURCHASED_INSTANT, SEOUL), EXPECTED_THREE_MONTH_EXPIRES_AT,
            PassProduct.PRO_PASS_3M.getDurationDays()));
        verifier.notificationBySignedPayload.put("refund-payload", new AppStoreNotification("notification-5", "REFUND",
            null, transaction(TRANSACTION_ID, PassProduct.PRO_PASS_3M, PURCHASED_INSTANT, null)));

        appStoreBillingService.handleNotification(new AppStoreNotificationRequest("refund-payload"));

        assertThat(purchaseByToken.get("play-token").getStatus()).isEqualTo(PurchaseStatus.VERIFIED);
    }

    @Test
    void notification_invalidSignature_rejected() {
        assertRejected(() -> appStoreBillingService.handleNotification(new AppStoreNotificationRequest("forged")),
            ErrorCode.INVALID_INPUT_VALUE);
    }
}
