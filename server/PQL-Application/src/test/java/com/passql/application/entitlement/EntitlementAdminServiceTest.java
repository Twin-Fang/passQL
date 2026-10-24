package com.passql.application.entitlement;

import com.passql.application.entitlement.EntitlementPurchaseRevoker.RevocationResult;
import com.passql.common.audit.AdminAuditEvent;
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
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.context.ApplicationEventPublisher;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Arrays;
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
 * 관리자 프로 수동 부여·회수: 만료일 23:59:59 확정, 지난 날짜 거절, 기존 행 연장·단축, 회수, 구매 1건 회수(남은 구매 재생)
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
        new EntitlementPurchaseRevoker(purchaseRepository, entitlementRepository, new PassExpiryCalculator());
    private final EntitlementAdminService service = new EntitlementAdminService(
        memberRepository, entitlementRepository, purchaseRepository, purchaseRevoker, eventPublisher, FIXED_CLOCK);
    private final UUID memberUuid = UUID.randomUUID();

    @Test
    void grantPro_setsExpiresAtAndSource() {
        when(memberRepository.existsByMemberUuidAndIsDeletedFalse(memberUuid)).thenReturn(true);
        when(entitlementRepository.findForUpdateByMemberUuid(memberUuid)).thenReturn(Optional.empty());

        service.grantPro(memberUuid, LocalDate.of(2026, 12, 31), "테스트 사유");

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

        service.grantPro(memberUuid, LocalDate.of(2026, 12, 31), "테스트 사유");

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

        service.grantPro(memberUuid, LocalDate.of(2026, 10, 25), "테스트 사유");

        assertThat(existing.getExpiresAt()).isEqualTo(LocalDateTime.of(2026, 10, 25, 23, 59, 59));
        assertThat(existing.getSource()).isEqualTo(EntitlementSource.ADMIN_GRANT);
        verify(eventPublisher).publishEvent(any(AdminAuditEvent.class));
    }

    @Test
    void revokePurchase_marksRevoked_andRecalculatesFromRemainingLegacyPurchase() {
        // 회원 등급: 최근 구매(11/30) 기준, 남은 옛 회차 패스 구매(11/10, 일수 없음) > 부여 만료일 그대로
        EntitlementPurchase latestPurchase = purchase(memberUuid, "GPA.0002", LocalDateTime.of(2026, 11, 30, 23, 59, 59));
        EntitlementPurchase remainingPurchase = purchase(memberUuid, "GPA.0001", LocalDateTime.of(2026, 11, 10, 23, 59, 59));
        MemberEntitlement entitlement = MemberEntitlement.of(memberUuid, MemberPlan.PRO,
            latestPurchase.getGrantedExpiresAt(), EntitlementSource.PLAY_PURCHASE);
        when(purchaseRepository.findById(PURCHASE_UUID)).thenReturn(Optional.of(latestPurchase));
        when(entitlementRepository.findForUpdateByMemberUuid(memberUuid)).thenReturn(Optional.of(entitlement));
        when(purchaseRepository.findByMemberUuidAndStatus(memberUuid, PurchaseStatus.VERIFIED))
            .thenReturn(List.of(remainingPurchase));

        service.revokePurchase(memberUuid, PURCHASE_UUID, "테스트 사유");

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

        assertThatThrownBy(() -> service.revokePurchase(memberUuid, PURCHASE_UUID, "테스트 사유"))
            .isInstanceOfSatisfying(CustomException.class,
                exception -> assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.ACCESS_DENIED));
        assertThat(otherMemberPurchase.getStatus()).isEqualTo(PurchaseStatus.VERIFIED);
        verify(entitlementRepository, never()).findForUpdateByMemberUuid(any());
        verify(eventPublisher, never()).publishEvent(any());
    }

    @Test
    void revokePurchase_middlePass_removesOnlyItsDays() {
        // 3개월(10일 전) > 1개월(5일 전) > 1개월(1일 전) 이어 붙임, 가운데 환불 > 그 30일만 빠짐
        EntitlementPurchase firstPass = passPurchase("GPA.0001", NOW.minusDays(10), PassProduct.PRO_PASS_3M, null);
        EntitlementPurchase middlePass = passPurchase("GPA.0002", NOW.minusDays(5), PassProduct.PRO_PASS_1M,
            firstPass.getGrantedExpiresAt());
        EntitlementPurchase lastPass = passPurchase("GPA.0003", NOW.minusDays(1), PassProduct.PRO_PASS_1M,
            middlePass.getGrantedExpiresAt());
        MemberEntitlement entitlement = playEntitlement(lastPass.getGrantedExpiresAt());
        givenPurchases(middlePass, entitlement, firstPass, middlePass, lastPass);

        service.revokePurchase(memberUuid, PURCHASE_UUID, "테스트 사유");

        assertThat(lastPass.getGrantedExpiresAt()).isEqualTo(NOW.plusDays(140));
        assertThat(entitlement.getExpiresAt()).isEqualTo(NOW.plusDays(110));
        assertThat(entitlement.getSource()).isEqualTo(EntitlementSource.PLAY_PURCHASE);
    }

    @Test
    void revokePurchase_earlierExpiredPass_keepsCurrentExpiresAt() {
        // 100일 전 1개월권(이미 만료) 환불 > 10일 전 3개월권 만료일 그대로
        EntitlementPurchase expiredPass = passPurchase("GPA.0001", NOW.minusDays(100), PassProduct.PRO_PASS_1M, null);
        EntitlementPurchase activePass = passPurchase("GPA.0002", NOW.minusDays(10), PassProduct.PRO_PASS_3M, null);
        MemberEntitlement entitlement = playEntitlement(activePass.getGrantedExpiresAt());
        givenPurchases(expiredPass, entitlement, expiredPass, activePass);

        service.revokePurchase(memberUuid, PURCHASE_UUID, "테스트 사유");

        assertThat(expiredPass.getStatus()).isEqualTo(PurchaseStatus.REVOKED);
        assertThat(entitlement.getExpiresAt()).isEqualTo(NOW.plusDays(80));
    }

    @Test
    void revokePurchase_onlyPass_setsFree() {
        EntitlementPurchase onlyPass = passPurchase("GPA.0001", NOW.minusDays(1), PassProduct.PRO_PASS_3M, null);
        MemberEntitlement entitlement = playEntitlement(onlyPass.getGrantedExpiresAt());
        givenPurchases(onlyPass, entitlement, onlyPass);

        service.revokePurchase(memberUuid, PURCHASE_UUID, "테스트 사유");

        assertThat(entitlement.getPlan()).isEqualTo(MemberPlan.FREE);
        assertThat(entitlement.getExpiresAt()).isNull();
    }

    @Test
    void revokePurchase_adminGrant_keepsEntitlement() {
        EntitlementPurchase onlyPass = passPurchase("GPA.0001", NOW.minusDays(1), PassProduct.PRO_PASS_3M, null);
        LocalDateTime adminGrantExpiresAt = LocalDateTime.of(2027, 6, 30, 23, 59, 59);
        MemberEntitlement entitlement = MemberEntitlement.of(memberUuid, MemberPlan.PRO, adminGrantExpiresAt,
            EntitlementSource.ADMIN_GRANT);
        givenPurchases(onlyPass, entitlement, onlyPass);

        RevocationResult result = service.revokePurchase(memberUuid, PURCHASE_UUID, "테스트 사유");

        assertThat(result.kind()).isEqualTo(EntitlementPurchaseRevoker.RecalculationKind.ADMIN_GRANT_KEPT);
        assertThat(onlyPass.getStatus()).isEqualTo(PurchaseStatus.REVOKED);
        assertThat(entitlement.getExpiresAt()).isEqualTo(adminGrantExpiresAt);
        assertThat(entitlement.getSource()).isEqualTo(EntitlementSource.ADMIN_GRANT);
    }

    // 회수 대상·등급 행·회원 구매 목록 등록 (상태별 조회는 호출 시점 상태로 거름)
    private void givenPurchases(EntitlementPurchase revokeTarget, MemberEntitlement entitlement,
                                EntitlementPurchase... memberPurchases) {
        when(purchaseRepository.findById(PURCHASE_UUID)).thenReturn(Optional.of(revokeTarget));
        when(entitlementRepository.findForUpdateByMemberUuid(memberUuid)).thenReturn(Optional.of(entitlement));
        when(purchaseRepository.findByMemberUuidAndStatus(memberUuid, PurchaseStatus.VERIFIED))
            .thenAnswer(call -> Arrays.stream(memberPurchases)
                .filter(memberPurchase -> memberPurchase.getStatus() == PurchaseStatus.VERIFIED)
                .toList());
    }

    private MemberEntitlement playEntitlement(LocalDateTime expiresAt) {
        return MemberEntitlement.of(memberUuid, MemberPlan.PRO, expiresAt, EntitlementSource.PLAY_PURCHASE);
    }

    // 이용권 구매 (부여 만료일 = max(구매 시각, 직전 누적 만료일) + 일수)
    private EntitlementPurchase passPurchase(String orderId, LocalDateTime purchasedAt, PassProduct passProduct,
                                             LocalDateTime previousExpiresAt) {
        LocalDateTime grantedExpiresAt = new PassExpiryCalculator()
            .calculateExpiresAt(purchasedAt, previousExpiresAt, passProduct.getDurationDays());
        return EntitlementPurchase.verified(memberUuid, PurchaseStore.PLAY, passProduct.getProductId(), orderId,
            "token-" + orderId, purchasedAt, grantedExpiresAt, passProduct.getDurationDays());
    }

    // 옛 회차 패스 구매 (이용 일수 없음)
    private static EntitlementPurchase purchase(UUID ownerUuid, String orderId, LocalDateTime grantedExpiresAt) {
        return EntitlementPurchase.verified(ownerUuid, PurchaseStore.PLAY, "pro_exam_pass", orderId,
            "token-" + orderId, NOW.minusDays(1), grantedExpiresAt, null);
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

        assertThatThrownBy(() -> service.grantPro(memberUuid, LocalDate.of(2026, 10, 21), "테스트 사유"))
            .isInstanceOfSatisfying(CustomException.class,
                exception -> assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.INVALID_INPUT_VALUE));
        verify(entitlementRepository, never()).save(any());
    }

    @Test
    void revokePro_setsFree() {
        MemberEntitlement existing = MemberEntitlement.of(memberUuid, MemberPlan.PRO,
            LocalDateTime.of(2026, 12, 31, 23, 59, 59), EntitlementSource.ADMIN_GRANT);
        when(entitlementRepository.findForUpdateByMemberUuid(memberUuid)).thenReturn(Optional.of(existing));

        service.revokePro(memberUuid, "테스트 사유");

        assertThat(existing.getPlan()).isEqualTo(MemberPlan.FREE);
        assertThat(existing.getExpiresAt()).isNull();
    }

    @Test
    void grantPro_recordsReasonInAuditEvent() {
        when(memberRepository.existsByMemberUuidAndIsDeletedFalse(memberUuid)).thenReturn(true);
        when(entitlementRepository.findForUpdateByMemberUuid(memberUuid)).thenReturn(Optional.empty());

        service.grantPro(memberUuid, LocalDate.of(2026, 12, 31), "  결제 오류 보상  ");

        ArgumentCaptor<AdminAuditEvent> event = ArgumentCaptor.forClass(AdminAuditEvent.class);
        verify(eventPublisher).publishEvent(event.capture());
        assertThat(event.getValue().after()).containsEntry("reason", "결제 오류 보상");
    }

    @Test
    void revokePro_recordsReasonInAuditEvent() {
        MemberEntitlement existing = MemberEntitlement.of(memberUuid, MemberPlan.PRO,
            LocalDateTime.of(2026, 12, 31, 23, 59, 59), EntitlementSource.ADMIN_GRANT);
        when(entitlementRepository.findForUpdateByMemberUuid(memberUuid)).thenReturn(Optional.of(existing));

        service.revokePro(memberUuid, "환불 확인");

        ArgumentCaptor<AdminAuditEvent> event = ArgumentCaptor.forClass(AdminAuditEvent.class);
        verify(eventPublisher).publishEvent(event.capture());
        assertThat(event.getValue().after()).containsEntry("reason", "환불 확인");
    }

    @Test
    void 사유가_비었거나_너무_길면_부여와_회수를_거절한다() {
        assertThatThrownBy(() -> service.grantPro(memberUuid, LocalDate.of(2026, 12, 31), "  "))
            .isInstanceOfSatisfying(CustomException.class,
                exception -> assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.INVALID_INPUT_VALUE));
        assertThatThrownBy(() -> service.revokePro(memberUuid, null))
            .isInstanceOf(CustomException.class);
        assertThatThrownBy(() -> service.revokePurchase(memberUuid, PURCHASE_UUID,
            "가".repeat(EntitlementAdminService.MAX_REASON_LENGTH + 1)))
            .isInstanceOf(CustomException.class);
        verify(entitlementRepository, never()).save(any());
        assertThat(EntitlementAdminService.isValidReason("가".repeat(EntitlementAdminService.MAX_REASON_LENGTH))).isTrue();
    }

    @Test
    void 결제_금액은_통화와_함께_표시하고_미기록이면_null이다() {
        assertThat(EntitlementAdminService.toPriceText(4_400_000_000L, "KRW")).isEqualTo("4,400 KRW");
        assertThat(EntitlementAdminService.toPriceText(9_990_000L, "USD")).isEqualTo("9.99 USD");
        assertThat(EntitlementAdminService.toPriceText(null, "KRW")).isNull();
        assertThat(EntitlementAdminService.toPriceText(1_000_000L, null)).isNull();
    }
}
