package com.passql.application.billing;

import com.passql.application.entitlement.DailyQuestionCounter;
import com.passql.application.entitlement.ExamPassExpiryCalculator;
import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.application.entitlement.MemberPlanResponse;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.MemberPlan;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.entity.EntitlementPurchase;
import com.passql.member.entity.MemberEntitlement;
import com.passql.member.repository.EntitlementPurchaseRepository;
import com.passql.member.repository.MemberEntitlementRepository;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.repository.ExamScheduleRepository;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
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
 * Play 회차 패스 결제: 구매 확인 > 등급 부여 > 소모, 중복·대기·타인 토큰 거절, 환불 회수
 * Play API 는 가짜 클라이언트, 저장소는 메모리 맵 기반 목
 */
class PlayBillingServiceTest {

    private static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");
    // 고정 현재 시각 (등급 판정은 시스템 시계라 실제 현재와 맞춤)
    private static final Clock FIXED_CLOCK = Clock.fixed(Instant.now().truncatedTo(ChronoUnit.SECONDS), SEOUL);
    // Play 구매 시각: 현재 1시간 전
    private static final Instant PURCHASED_INSTANT = FIXED_CLOCK.instant().minus(1, ChronoUnit.HOURS);
    // 시험 일정 없음 > 만료일 = 구매일 + 90일
    private static final LocalDateTime EXPECTED_EXPIRES_AT =
        LocalDateTime.ofInstant(PURCHASED_INSTANT, SEOUL).plusDays(90);
    private static final String PURCHASE_TOKEN = "purchase-token-1";

    private final FakePlayDeveloperApiClient playClient = new FakePlayDeveloperApiClient();
    private final EntitlementPurchaseRepository purchaseRepository = mock(EntitlementPurchaseRepository.class);
    private final MemberEntitlementRepository entitlementRepository = mock(MemberEntitlementRepository.class);
    private final AppSettingService appSettingService = mock(AppSettingService.class);
    private final ExamPassExpiryCalculator expiryCalculator =
        new ExamPassExpiryCalculator(mock(ExamScheduleRepository.class));
    private final FeatureAccessPolicy featureAccessPolicy = new FeatureAccessPolicy(
        entitlementRepository, appSettingService, expiryCalculator,
        mock(SubmissionRepository.class), mock(DailyQuestionCounter.class));
    private final PlayBillingService playBillingService = new PlayBillingService(
        playClient, purchaseRepository, entitlementRepository, expiryCalculator, featureAccessPolicy,
        new TransactionTemplate(mock(PlatformTransactionManager.class)), FIXED_CLOCK);

    // 메모리 저장소 (구매: 토큰별, 등급: 회원별)
    private final Map<String, EntitlementPurchase> purchaseByToken = new HashMap<>();
    private final Map<UUID, MemberEntitlement> entitlementByMember = new HashMap<>();
    private final UUID memberUuid = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        when(appSettingService.getBooleanOrDefault(eq(AppSettingKeys.BILLING_ANDROID_ENABLED), anyBoolean()))
            .thenReturn(true);

        // 구매 저장소 (토큰 조회, 저장, 회원·상태 조회)
        when(purchaseRepository.findByPurchaseToken(any()))
            .thenAnswer(call -> Optional.ofNullable(purchaseByToken.get(call.<String>getArgument(0))));
        when(purchaseRepository.saveAndFlush(any())).thenAnswer(call -> {
            EntitlementPurchase purchase = call.getArgument(0);
            purchaseByToken.put(purchase.getPurchaseToken(), purchase);
            return purchase;
        });
        when(purchaseRepository.findByMemberUuidAndStatus(any(), any())).thenAnswer(call -> purchaseByToken.values()
            .stream()
            .filter(purchase -> purchase.getMemberUuid().equals(call.getArgument(0)))
            .filter(purchase -> purchase.getStatus() == call.getArgument(1))
            .toList());

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

    private static PlayVerifyRequest passRequest() {
        return new PlayVerifyRequest(PlayBillingService.PRO_EXAM_PASS_PRODUCT_ID, PURCHASE_TOKEN);
    }

    @Test
    void verify_purchased_grantsProUntilCalculatedExpiry_andConsumes() {
        playClient.snapshot = new PlayPurchaseSnapshot("GPA.0001", 0, 0, PURCHASED_INSTANT);

        MemberPlanResponse response = playBillingService.verify(memberUuid, passRequest());

        assertThat(response.plan()).isEqualTo("PRO");
        assertThat(response.proExpiresAt()).isEqualTo(EXPECTED_EXPIRES_AT);
        EntitlementPurchase purchase = purchaseByToken.get(PURCHASE_TOKEN);
        assertThat(purchase.getStatus()).isEqualTo(PurchaseStatus.VERIFIED);
        assertThat(purchase.getGrantedExpiresAt()).isEqualTo(EXPECTED_EXPIRES_AT);
        assertThat(purchase.getIsConsumed()).isTrue();
        assertThat(playClient.consumeAttemptCount).isEqualTo(1);
    }

    @Test
    void verify_sameTokenTwice_doesNotExtendTwice() {
        playClient.snapshot = new PlayPurchaseSnapshot("GPA.0001", 0, 0, PURCHASED_INSTANT);

        playBillingService.verify(memberUuid, passRequest());
        MemberPlanResponse second = playBillingService.verify(memberUuid, passRequest());

        assertThat(second.proExpiresAt()).isEqualTo(EXPECTED_EXPIRES_AT);
        assertThat(entitlementByMember.get(memberUuid).getExpiresAt()).isEqualTo(EXPECTED_EXPIRES_AT);
        assertThat(playClient.getProductPurchaseCallCount).isEqualTo(1);
        assertThat(purchaseByToken).hasSize(1);
    }

    @Test
    void verify_pending_returnsFreeWithoutConsume() {
        playClient.snapshot = new PlayPurchaseSnapshot("GPA.0001", 2, 0, PURCHASED_INSTANT);

        MemberPlanResponse response = playBillingService.verify(memberUuid, passRequest());

        assertThat(response.plan()).isEqualTo("FREE");
        assertThat(purchaseByToken).isEmpty();
        assertThat(entitlementByMember).isEmpty();
        assertThat(playClient.consumeAttemptCount).isZero();
    }

    @Test
    void verify_wrongProductId_rejected() {
        PlayVerifyRequest request = new PlayVerifyRequest("other_product", PURCHASE_TOKEN);

        assertThatThrownBy(() -> playBillingService.verify(memberUuid, request))
            .isInstanceOfSatisfying(CustomException.class,
                exception -> assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.INVALID_INPUT_VALUE));
        assertThat(playClient.getProductPurchaseCallCount).isZero();
    }

    @Test
    void verify_tokenOwnedByAnotherMember_rejected() {
        playClient.snapshot = new PlayPurchaseSnapshot("GPA.0001", 0, 0, PURCHASED_INSTANT);
        playBillingService.verify(memberUuid, passRequest());
        UUID otherMemberUuid = UUID.randomUUID();

        assertThatThrownBy(() -> playBillingService.verify(otherMemberUuid, passRequest()))
            .isInstanceOfSatisfying(CustomException.class,
                exception -> assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.ACCESS_DENIED));
        assertThat(entitlementByMember).doesNotContainKey(otherMemberUuid);
    }

    @Test
    void verify_consumeFails_leavesUnconsumed_andNextVerifyRetriesConsume() {
        playClient.snapshot = new PlayPurchaseSnapshot("GPA.0001", 0, 0, PURCHASED_INSTANT);
        playClient.isConsumeFailing = true;

        MemberPlanResponse first = playBillingService.verify(memberUuid, passRequest());

        assertThat(first.plan()).isEqualTo("PRO");
        assertThat(purchaseByToken.get(PURCHASE_TOKEN).getIsConsumed()).isFalse();

        // 다음 verify: 연장 없이 소모만 재시도
        playClient.isConsumeFailing = false;
        MemberPlanResponse second = playBillingService.verify(memberUuid, passRequest());

        assertThat(second.proExpiresAt()).isEqualTo(EXPECTED_EXPIRES_AT);
        assertThat(purchaseByToken.get(PURCHASE_TOKEN).getIsConsumed()).isTrue();
        assertThat(playClient.consumeAttemptCount).isEqualTo(2);
    }

    @Test
    void revokeVoided_marksRevoked_andRecalculatesPlan() {
        playClient.snapshot = new PlayPurchaseSnapshot("GPA.0001", 0, 0, PURCHASED_INSTANT);
        playBillingService.verify(memberUuid, passRequest());
        playClient.voidedPurchaseTokens.add(PURCHASE_TOKEN);

        playBillingService.revokeVoidedPurchases();

        assertThat(purchaseByToken.get(PURCHASE_TOKEN).getStatus()).isEqualTo(PurchaseStatus.REVOKED);
        assertThat(entitlementByMember.get(memberUuid).getPlan()).isEqualTo(MemberPlan.FREE);
        assertThat(featureAccessPolicy.getPlan(memberUuid).plan()).isEqualTo("FREE");
    }

    /** 가짜 Play API: 응답 고정, 호출 수 기록, 소모 실패 전환 */
    private static class FakePlayDeveloperApiClient implements PlayDeveloperApiClient {

        private PlayPurchaseSnapshot snapshot;
        private boolean isConsumeFailing;
        private int getProductPurchaseCallCount;
        private int consumeAttemptCount;
        private final List<String> voidedPurchaseTokens = new ArrayList<>();

        @Override
        public boolean isConfigured() {
            return true;
        }

        @Override
        public PlayPurchaseSnapshot getProductPurchase(String productId, String purchaseToken) {
            getProductPurchaseCallCount++;
            return snapshot;
        }

        @Override
        public void consume(String productId, String purchaseToken) {
            consumeAttemptCount++;
            if (isConsumeFailing) {
                throw new CustomException(ErrorCode.EXTERNAL_API_ERROR);
            }
        }

        @Override
        public List<String> listVoidedPurchaseTokens(Instant since) {
            return voidedPurchaseTokens;
        }
    }
}
