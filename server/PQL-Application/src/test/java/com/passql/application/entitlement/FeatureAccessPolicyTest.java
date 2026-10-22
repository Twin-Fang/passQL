package com.passql.application.entitlement;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.EntitlementSource;
import com.passql.member.constant.MemberPlan;
import com.passql.member.entity.MemberEntitlement;
import com.passql.member.repository.MemberEntitlementRepository;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
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
    private final FeatureAccessPolicy policy =
        new FeatureAccessPolicy(entitlementRepository, appSettingService, examPassExpiryCalculator, FIXED_CLOCK);
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
}
