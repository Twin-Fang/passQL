package com.passql.application.entitlement;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.EntitlementSource;
import com.passql.member.constant.MemberPlan;
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
 * 관리자 프로 수동 부여·회수: 만료일 23:59:59 확정, 지난 날짜 거절, 기존 행 연장, 회수
 */
class EntitlementAdminServiceTest {

    private static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");
    // 고정 현재 시각: 2026-10-22 12:00 KST
    private static final LocalDateTime NOW = LocalDateTime.of(2026, 10, 22, 12, 0);
    private static final Clock FIXED_CLOCK = Clock.fixed(NOW.atZone(SEOUL).toInstant(), SEOUL);

    private final MemberRepository memberRepository = mock(MemberRepository.class);
    private final MemberEntitlementRepository entitlementRepository = mock(MemberEntitlementRepository.class);
    private final EntitlementPurchaseRepository purchaseRepository = mock(EntitlementPurchaseRepository.class);
    private final ApplicationEventPublisher eventPublisher = mock(ApplicationEventPublisher.class);
    private final EntitlementAdminService service = new EntitlementAdminService(
        memberRepository, entitlementRepository, purchaseRepository, eventPublisher, FIXED_CLOCK);
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

        service.grantPro(memberUuid, LocalDate.of(2026, 10, 22));

        assertThat(existing.getExpiresAt()).isEqualTo(LocalDateTime.of(2026, 10, 22, 23, 59, 59));
        assertThat(existing.getSource()).isEqualTo(EntitlementSource.ADMIN_GRANT);
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
