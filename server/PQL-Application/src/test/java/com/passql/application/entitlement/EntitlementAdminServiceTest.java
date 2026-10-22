package com.passql.application.entitlement;

import com.passql.common.audit.AdminAuditEvent;
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
import com.passql.member.repository.MemberRepository;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.context.ApplicationEventPublisher;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 관리자 프로 수동 부여·회수: 만료일 23:59:59 확정, 지난 날짜 거절, 기존 행 연장·단축, 회수, 구매 1건 회수
 */
class EntitlementAdminServiceTest {

    private static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");
    // 고정 현재 시각: 2026-10-22 12:00 KST
    private static final LocalDateTime NOW = LocalDateTime.of(2026, 10, 22, 12, 0);
    private static final Clock FIXED_CLOCK = Clock.fixed(NOW.atZone(SEOUL).toInstant(), SEOUL);
    // 회수 대상 구매 uuid
    private static final UUID PURCHASE_UUID = UUID.randomUUID();

    private final MemberRepository memberRepository = mock(MemberRepository.class);
    private final MemberEntitlementRepository entitlementRepository = mock(MemberEntitlementRepository.class);
    private final EntitlementPurchaseRepository purchaseRepository = mock(EntitlementPurchaseRepository.class);
    private final ApplicationEventPublisher eventPublisher = mock(ApplicationEventPublisher.class);
    private final EntitlementPurchaseRevoker purchaseRevoker =
        new EntitlementPurchaseRevoker(purchaseRepository, entitlementRepository);
    private final EntitlementAdminService service = new EntitlementAdminService(
        memberRepository, entitlementRepository, purchaseRepository, purchaseRevoker, eventPublisher, FIXED_CLOCK);
    private final UUID memberUuid = UUID.randomUUID();

    @Test
    void grantPro_setsExpiresAtAndSource() {
        when(memberRepository.existsByMemberUuidAndIsDeletedFalse(memberUuid)).thenReturn(true);
        when(entitlementRepository.findForUpdateByMemberUuid(memberUuid)).thenReturn(Optional.empty());

        service.grantPro(memberUuid, LocalDate.of(2026, 12, 31));

        ArgumentCaptor<MemberEntitlement> saved = ArgumentCaptor.forClass(MemberEntitlement.class);
        verify(entitlementRepository).save(saved.capture());
        assertThat(saved.getValue().getPlan()).isEqualTo(MemberPlan.PRO);
        assertThat(saved.getValue().getExpiresAt()).isEqualTo(LocalDateTime.of(2026, 12, 31, 23, 59, 59));
        assertThat(saved.getValue().getSource()).isEqualTo(EntitlementSource.ADMIN_GRANT);
    }

    @Test
    void grantPro_extendsExistingRowAndKeepsAdminGrantSource() {
        MemberEntitlement existing = MemberEntitlement.of(memberUuid, MemberPlan.PRO,
            LocalDateTime.of(2026, 11, 1, 23, 59, 59), EntitlementSource.PLAY_PURCHASE);
        when(memberRepository.existsByMemberUuidAndIsDeletedFalse(memberUuid)).thenReturn(true);
        when(entitlementRepository.findForUpdateByMemberUuid(memberUuid)).thenReturn(Optional.of(existing));

        service.grantPro(memberUuid, LocalDate.of(2026, 12, 31));

        assertThat(existing.getExpiresAt()).isEqualTo(LocalDateTime.of(2026, 12, 31, 23, 59, 59));
        assertThat(existing.getSource()).isEqualTo(EntitlementSource.ADMIN_GRANT);
    }

    @Test
    void grantPro_shortensActivePaidPass_andSetsAdminGrant() {
        // 관리자 권한 최대: 활성 유료 패스보다 이른 날짜도 지정 (화면은 confirm)
        MemberEntitlement existing = MemberEntitlement.of(memberUuid, MemberPlan.PRO,
            LocalDateTime.of(2026, 11, 1, 23, 59, 59), EntitlementSource.PLAY_PURCHASE);
        when(memberRepository.existsByMemberUuidAndIsDeletedFalse(memberUuid)).thenReturn(true);
        when(entitlementRepository.findForUpdateByMemberUuid(memberUuid)).thenReturn(Optional.of(existing));

        service.grantPro(memberUuid, LocalDate.of(2026, 10, 25));

        assertThat(existing.getExpiresAt()).isEqualTo(LocalDateTime.of(2026, 10, 25, 23, 59, 59));
        assertThat(existing.getSource()).isEqualTo(EntitlementSource.ADMIN_GRANT);
        verify(eventPublisher).publishEvent(any(AdminAuditEvent.class));
    }

    @Test
    void revokePurchase_marksRevoked_andRecalculatesFromRemainingPurchase() {
        // 회원 등급: 최근 구매(11/30) 기준, 남은 구매(11/10)가 있음
        EntitlementPurchase latestPurchase = purchase(memberUuid, "GPA.0002", LocalDateTime.of(2026, 11, 30, 23, 59, 59));
        EntitlementPurchase remainingPurchase = purchase(memberUuid, "GPA.0001", LocalDateTime.of(2026, 11, 10, 23, 59, 59));
        MemberEntitlement entitlement = MemberEntitlement.of(memberUuid, MemberPlan.PRO,
            latestPurchase.getGrantedExpiresAt(), EntitlementSource.PLAY_PURCHASE);
        when(purchaseRepository.findById(PURCHASE_UUID)).thenReturn(Optional.of(latestPurchase));
        when(entitlementRepository.findForUpdateByMemberUuid(memberUuid)).thenReturn(Optional.of(entitlement));
        when(purchaseRepository.findByMemberUuidAndStatus(memberUuid, PurchaseStatus.VERIFIED))
            .thenReturn(List.of(remainingPurchase));

        service.revokePurchase(memberUuid, PURCHASE_UUID);

        assertThat(latestPurchase.getStatus()).isEqualTo(PurchaseStatus.REVOKED);
        assertThat(entitlement.getExpiresAt()).isEqualTo(LocalDateTime.of(2026, 11, 10, 23, 59, 59));
        assertThat(entitlement.getSource()).isEqualTo(EntitlementSource.PLAY_PURCHASE);
        verify(eventPublisher).publishEvent(any(AdminAuditEvent.class));
    }

    @Test
    void revokePurchase_ownedByAnotherMember_rejected() {
        EntitlementPurchase otherMemberPurchase =
            purchase(UUID.randomUUID(), "GPA.0003", LocalDateTime.of(2026, 11, 30, 23, 59, 59));
        when(purchaseRepository.findById(PURCHASE_UUID)).thenReturn(Optional.of(otherMemberPurchase));

        assertThatThrownBy(() -> service.revokePurchase(memberUuid, PURCHASE_UUID))
            .isInstanceOfSatisfying(CustomException.class,
                exception -> assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.ACCESS_DENIED));
        assertThat(otherMemberPurchase.getStatus()).isEqualTo(PurchaseStatus.VERIFIED);
        verify(entitlementRepository, never()).findForUpdateByMemberUuid(any());
        verify(eventPublisher, never()).publishEvent(any());
    }

    private static EntitlementPurchase purchase(UUID ownerUuid, String orderId, LocalDateTime grantedExpiresAt) {
        return EntitlementPurchase.verified(ownerUuid, PurchaseStore.PLAY, "pro_exam_pass", orderId,
            "token-" + orderId, NOW.minusDays(1), grantedExpiresAt);
    }

    @Test
    void getEntitlementView_todayIsServiceZoneDate() {
        // 2026-10-22 00:30 KST = 2026-10-21 15:30 UTC > KST 날짜여야 함
        Clock justAfterMidnightClock = Clock.fixed(
            LocalDateTime.of(2026, 10, 22, 0, 30).atZone(SEOUL).toInstant(), ZoneId.of("UTC"));
        EntitlementAdminService midnightService = new EntitlementAdminService(
            memberRepository, entitlementRepository, purchaseRepository, purchaseRevoker, eventPublisher,
            justAfterMidnightClock);
        when(entitlementRepository.findById(memberUuid)).thenReturn(Optional.empty());

        assertThat(midnightService.getEntitlementView(memberUuid).todayInServiceZone())
            .isEqualTo(LocalDate.of(2026, 10, 22));
    }

    @Test
    void grantPro_rejectsPastDate() {
        when(memberRepository.existsByMemberUuidAndIsDeletedFalse(memberUuid)).thenReturn(true);

        assertThatThrownBy(() -> service.grantPro(memberUuid, LocalDate.of(2026, 10, 21)))
            .isInstanceOfSatisfying(CustomException.class,
                exception -> assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.INVALID_INPUT_VALUE));
        verify(entitlementRepository, never()).save(any());
    }

    @Test
    void revokePro_setsFree() {
        MemberEntitlement existing = MemberEntitlement.of(memberUuid, MemberPlan.PRO,
            LocalDateTime.of(2026, 12, 31, 23, 59, 59), EntitlementSource.ADMIN_GRANT);
        when(entitlementRepository.findForUpdateByMemberUuid(memberUuid)).thenReturn(Optional.of(existing));

        service.revokePro(memberUuid);

        assertThat(existing.getPlan()).isEqualTo(MemberPlan.FREE);
        assertThat(existing.getExpiresAt()).isNull();
    }
}
