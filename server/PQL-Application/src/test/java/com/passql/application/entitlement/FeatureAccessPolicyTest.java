package com.passql.application.entitlement;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.ChoiceGenerationMode;
import com.passql.member.constant.EntitlementSource;
import com.passql.member.constant.MemberPlan;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;
import com.passql.member.entity.EntitlementPurchase;
import com.passql.member.entity.MemberEntitlement;
import com.passql.member.repository.EntitlementPurchaseRepository;
import com.passql.member.repository.MemberEntitlementRepository;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

/**
 * 등급 판정 단일 지점: 스위치 꺼짐 전원 허용, 만료일 기준 프로 판정, 무료 요청 거절
 */
class FeatureAccessPolicyTest {

    private static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");
    // 고정 현재 시각: 2026-10-22 12:00 KST
    private static final LocalDateTime NOW = LocalDateTime.of(2026, 10, 22, 12, 0);
    private static final Clock FIXED_CLOCK = Clock.fixed(NOW.atZone(SEOUL).toInstant(), SEOUL);

    private final MemberEntitlementRepository entitlementRepository = mock(MemberEntitlementRepository.class);
    private final AppSettingService appSettingService = mock(AppSettingService.class);
    private final ExamPassExpiryCalculator examPassExpiryCalculator = mock(ExamPassExpiryCalculator.class);
    private final SubmissionRepository submissionRepository = mock(SubmissionRepository.class);
    private final DailyQuestionCounter dailyQuestionCounter = mock(DailyQuestionCounter.class);
    private final EntitlementPurchaseRepository purchaseRepository = mock(EntitlementPurchaseRepository.class);
    private final FeatureAccessPolicy policy = new FeatureAccessPolicy(
        entitlementRepository, appSettingService, examPassExpiryCalculator,
        submissionRepository, dailyQuestionCounter, purchaseRepository, FIXED_CLOCK);
    private final UUID memberUuid = UUID.randomUUID();

    private void givenBillingEnabled(boolean isEnabled) {
        when(appSettingService.getBooleanOrDefault(eq(AppSettingKeys.BILLING_ANDROID_ENABLED), anyBoolean()))
            .thenReturn(isEnabled);
    }

    private void givenEntitlement(MemberPlan plan, LocalDateTime expiresAt) {
        when(entitlementRepository.findById(memberUuid)).thenReturn(
            Optional.of(MemberEntitlement.of(memberUuid, plan, expiresAt, EntitlementSource.PLAY_PURCHASE)));
    }

    @Test
    void isPro_whenBillingDisabled_returnsTrueForMemberWithoutEntitlement() {
        givenBillingEnabled(false);
        when(entitlementRepository.findById(memberUuid)).thenReturn(Optional.empty());

        assertThat(policy.isPro(memberUuid)).isTrue();
    }

    @Test
    void isPro_whenExpiresAtInFuture_returnsTrue() {
        givenBillingEnabled(true);
        givenEntitlement(MemberPlan.PRO, NOW.plusDays(1));

        assertThat(policy.isPro(memberUuid)).isTrue();
    }

    @Test
    void isPro_whenExpired_returnsFalse() {
        givenBillingEnabled(true);
        givenEntitlement(MemberPlan.PRO, NOW.minusSeconds(1));

        assertThat(policy.isPro(memberUuid)).isFalse();
    }

    @Test
    void isPro_whenNoRow_returnsFalse() {
        givenBillingEnabled(true);
        when(entitlementRepository.findById(memberUuid)).thenReturn(Optional.empty());

        assertThat(policy.isPro(memberUuid)).isFalse();
    }

    @Test
    void requireFeature_whenFree_throwsProRequired() {
        givenBillingEnabled(true);
        when(entitlementRepository.findById(memberUuid)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> policy.requireFeature(memberUuid, ProFeature.REAL_MODE))
            .isInstanceOfSatisfying(CustomException.class,
                e -> assertThat(e.getErrorCode()).isEqualTo(ErrorCode.PRO_REQUIRED));
    }

    @Test
    void getPlan_whenActivePro_returnsProWithExpiresAt() {
        givenBillingEnabled(true);
        givenEntitlement(MemberPlan.PRO, NOW.plusDays(30));

        MemberPlanResponse response = policy.getPlan(memberUuid);

        assertThat(response.plan()).isEqualTo("PRO");
        assertThat(response.proExpiresAt()).isEqualTo(NOW.plusDays(30));
        assertThat(response.isBillingEnabled()).isTrue();
        assertThat(response.dailyFreeLimit()).isEqualTo(FeatureAccessPolicy.DAILY_FREE_LIMIT);
    }

    @Test
    void getPlan_whenBillingEnabled_fillsPurchasableUntilFromCalculator() {
        givenBillingEnabled(true);
        givenEntitlement(MemberPlan.PRO, NOW.plusDays(30));
        LocalDateTime purchasableUntil = LocalDateTime.of(2027, 3, 7, 23, 59, 59);
        when(examPassExpiryCalculator.calculateExpiresAt(NOW, NOW.plusDays(30))).thenReturn(purchasableUntil);

        assertThat(policy.getPlan(memberUuid).purchasableUntil()).isEqualTo(purchasableUntil);
    }

    @Test
    void getPlan_whenBillingDisabled_purchasableUntilIsNull() {
        givenBillingEnabled(false);
        when(entitlementRepository.findById(memberUuid)).thenReturn(Optional.empty());

        assertThat(policy.getPlan(memberUuid).purchasableUntil()).isNull();
    }

    @Test
    void resolveEffectiveChoiceGenerationMode_whenFree_downgradesRealToPractice() {
        givenBillingEnabled(true);
        when(entitlementRepository.findById(memberUuid)).thenReturn(Optional.empty());

        assertThat(policy.resolveEffectiveChoiceGenerationMode(memberUuid, ChoiceGenerationMode.REAL))
            .isEqualTo(ChoiceGenerationMode.PRACTICE);
    }

    @Test
    void resolveEffectiveChoiceGenerationMode_whenPro_keepsStoredMode() {
        givenBillingEnabled(true);
        givenEntitlement(MemberPlan.PRO, NOW.plusDays(1));

        assertThat(policy.resolveEffectiveChoiceGenerationMode(memberUuid, ChoiceGenerationMode.REAL))
            .isEqualTo(ChoiceGenerationMode.REAL);
    }

    private void givenTodayRandomSolvedCount(int count) {
        when(dailyQuestionCounter.countTodayRandomSolved(memberUuid)).thenReturn(count);
    }

    private void givenFreeMember() {
        givenBillingEnabled(true);
        when(entitlementRepository.findById(memberUuid)).thenReturn(Optional.empty());
    }

    private void assertOpenRejectedWith(UUID questionUuid, ErrorCode expectedErrorCode) {
        assertThatThrownBy(() -> policy.assertCanOpenQuestion(memberUuid, questionUuid))
            .isInstanceOfSatisfying(CustomException.class,
                e -> assertThat(e.getErrorCode()).isEqualTo(expectedErrorCode));
    }

    @Test
    void free_11thNewQuestion_throwsFreeDailyLimitReached() {
        givenFreeMember();
        givenTodayRandomSolvedCount(FeatureAccessPolicy.DAILY_FREE_LIMIT);
        UUID questionUuid = UUID.randomUUID();

        assertOpenRejectedWith(questionUuid, ErrorCode.FREE_DAILY_LIMIT_REACHED);
    }

    @Test
    void free_10thNewQuestion_allowed() {
        givenFreeMember();
        givenTodayRandomSolvedCount(FeatureAccessPolicy.DAILY_FREE_LIMIT - 1);

        policy.assertCanOpenQuestion(memberUuid, UUID.randomUUID());
    }

    @Test
    void free_previouslySubmittedQuestion_allowedAfterLimit() {
        givenFreeMember();
        givenTodayRandomSolvedCount(FeatureAccessPolicy.DAILY_FREE_LIMIT);
        UUID questionUuid = UUID.randomUUID();
        when(submissionRepository.existsByMemberUuidAndQuestionUuid(memberUuid, questionUuid)).thenReturn(true);

        policy.assertCanOpenQuestion(memberUuid, questionUuid);
    }

    @Test
    void free_todaysDailyChallengeQuestion_allowedAfterLimit() {
        givenFreeMember();
        givenTodayRandomSolvedCount(FeatureAccessPolicy.DAILY_FREE_LIMIT);
        UUID questionUuid = UUID.randomUUID();
        when(dailyQuestionCounter.isTodaysDailyChallengeQuestion(questionUuid)).thenReturn(true);

        policy.assertCanOpenQuestion(memberUuid, questionUuid);
    }

    @Test
    void pro_200th_throwsFairUseDailyLimitReached() {
        givenBillingEnabled(true);
        givenEntitlement(MemberPlan.PRO, NOW.plusDays(30));
        givenTodayRandomSolvedCount(FeatureAccessPolicy.DAILY_PRO_FAIR_USE_LIMIT);

        assertOpenRejectedWith(UUID.randomUUID(), ErrorCode.FAIR_USE_DAILY_LIMIT_REACHED);
    }

    @Test
    void pro_beyondFreeLimitButUnderFairUse_allowed() {
        givenBillingEnabled(true);
        givenEntitlement(MemberPlan.PRO, NOW.plusDays(30));
        givenTodayRandomSolvedCount(FeatureAccessPolicy.DAILY_PRO_FAIR_USE_LIMIT - 1);

        policy.assertCanOpenQuestion(memberUuid, UUID.randomUUID());
    }

    @Test
    void billingDisabled_noLimit() {
        givenBillingEnabled(false);
        givenTodayRandomSolvedCount(Integer.MAX_VALUE);

        policy.assertCanOpenQuestion(memberUuid, UUID.randomUUID());
        // 스위치 꺼짐이면 제출 기록·오늘의 문제 조회조차 하지 않음
        verifyNoInteractions(submissionRepository, dailyQuestionCounter);
    }

    @Test
    void getPlan_whenBillingEnabled_fillsTodayRandomSolvedCount() {
        givenFreeMember();
        givenTodayRandomSolvedCount(7);

        assertThat(policy.getPlan(memberUuid).todayRandomSolvedCount()).isEqualTo(7);
    }

    @Test
    void getPlan_whenBillingDisabled_todayRandomSolvedCountIsZero() {
        givenBillingEnabled(false);
        when(entitlementRepository.findById(memberUuid)).thenReturn(Optional.empty());

        MemberPlanResponse response = policy.getPlan(memberUuid);

        assertThat(response.todayRandomSolvedCount()).isZero();
        assertThat(response.lastPurchasedAt()).isNull();
        verifyNoInteractions(dailyQuestionCounter);
        // 결제 꺼짐: 최근 구매 조회 생략
        verifyNoInteractions(purchaseRepository);
    }

    @Test
    void getPlan_fillsLastPurchaseFromLatestVerifiedPurchase() {
        givenBillingEnabled(true);
        givenEntitlement(MemberPlan.PRO, NOW.plusDays(30));
        LocalDateTime purchasedAt = NOW.minusDays(2);
        when(purchaseRepository.findFirstByMemberUuidAndStatusOrderByPurchasedAtDesc(memberUuid, PurchaseStatus.VERIFIED))
            .thenReturn(Optional.of(EntitlementPurchase.verified(memberUuid, PurchaseStore.PLAY, "pro_exam_pass",
                "GPA.0002", "purchase-token", purchasedAt, NOW.plusDays(30))));

        MemberPlanResponse response = policy.getPlan(memberUuid);

        assertThat(response.lastPurchasedAt()).isEqualTo(purchasedAt);
        assertThat(response.lastOrderId()).isEqualTo("GPA.0002");
    }

    @Test
    void getPlan_whenAdminGrantOnly_lastPurchaseIsNull() {
        givenBillingEnabled(true);
        when(entitlementRepository.findById(memberUuid)).thenReturn(Optional.of(
            MemberEntitlement.of(memberUuid, MemberPlan.PRO, NOW.plusDays(30), EntitlementSource.ADMIN_GRANT)));

        MemberPlanResponse response = policy.getPlan(memberUuid);

        assertThat(response.lastPurchasedAt()).isNull();
        assertThat(response.lastOrderId()).isNull();
    }
}
