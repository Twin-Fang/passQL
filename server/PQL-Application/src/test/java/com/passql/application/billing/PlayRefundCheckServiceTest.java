package com.passql.application.billing;

import com.passql.application.entitlement.EntitlementPurchaseRevoker;
import com.passql.application.entitlement.EntitlementPurchaseRevoker.RecalculationKind;
import com.passql.application.entitlement.EntitlementPurchaseRevoker.RevocationResult;
import com.passql.member.constant.PurchaseStore;
import com.passql.member.constant.RefundCheckFailureReason;
import com.passql.member.constant.RefundCheckTriggerType;
import com.passql.member.entity.BillingRefundCheckRun;
import com.passql.member.entity.EntitlementPurchase;
import com.passql.member.repository.BillingRefundCheckRunRepository;
import com.passql.member.repository.EntitlementPurchaseRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.transaction.support.TransactionCallback;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Play 환불 회수 확인 판정 (#984): 권한 회수 없는 환불(주문 REFUNDED)도 회수, 실행마다 건수·실패 사유 기록, 관제소 확인 필요 판정
 */
class PlayRefundCheckServiceTest {

    private static final ZoneId SERVICE_ZONE = ZoneId.of("Asia/Seoul");
    private static final Clock FIXED_CLOCK = Clock.fixed(Instant.parse("2026-11-12T19:50:00Z"), SERVICE_ZONE);
    private static final String REFUNDED_ORDER_ID = "GPA.0000-0000-0000-00001";
    private static final String FALLBACK_ORDER_ID = "PLAY-NO-ORDER-0000";

    private final PlayDeveloperApiClient playDeveloperApiClient = mock(PlayDeveloperApiClient.class);
    private final EntitlementPurchaseRepository entitlementPurchaseRepository = mock(EntitlementPurchaseRepository.class);
    private final EntitlementPurchaseRevoker entitlementPurchaseRevoker = mock(EntitlementPurchaseRevoker.class);
    private final BillingRefundCheckRunRepository billingRefundCheckRunRepository = mock(BillingRefundCheckRunRepository.class);
    private final TransactionTemplate transactionTemplate = mock(TransactionTemplate.class);
    private PlayRefundCheckService playRefundCheckService;

    @BeforeEach
    @SuppressWarnings("unchecked")
    void setUp() {
        playRefundCheckService = new PlayRefundCheckService(playDeveloperApiClient, entitlementPurchaseRepository,
            entitlementPurchaseRevoker, billingRefundCheckRunRepository, transactionTemplate,
            mock(ApplicationEventPublisher.class), FIXED_CLOCK);
        // 트랜잭션 콜백 즉시 실행
        when(transactionTemplate.execute(any())).thenAnswer(invocation ->
            ((TransactionCallback<Object>) invocation.getArgument(0)).doInTransaction(null));
        when(playDeveloperApiClient.isConfigured()).thenReturn(true);
        when(playDeveloperApiClient.listVoidedPurchaseTokens(any())).thenReturn(List.of());

        // 프로 유효 회원 구매 2건: 환불 주문 1건 + 대체 주문 번호 1건(조회 제외)
        EntitlementPurchase refundedPurchase = verifiedPlayPurchase(REFUNDED_ORDER_ID);
        when(entitlementPurchaseRepository.findVerifiedPurchasesOfActiveProMembers(any(), any()))
            .thenReturn(List.of(refundedPurchase, verifiedPlayPurchase(FALLBACK_ORDER_ID)));
        when(entitlementPurchaseRepository.findByOrderId(REFUNDED_ORDER_ID)).thenReturn(Optional.of(refundedPurchase));
        when(entitlementPurchaseRevoker.revokeAndRecalculate(any(), any()))
            .thenReturn(new RevocationResult(RecalculationKind.NO_ENTITLEMENT, null, null));
    }

    @Test
    void 취소_목록에_없어도_주문이_전액_환불이면_회수하고_건수를_기록한다() {
        when(playDeveloperApiClient.findRefundedOrderIds(anyList())).thenReturn(List.of(REFUNDED_ORDER_ID));

        RefundCheckRunResponse runResponse = playRefundCheckService.runRefundCheck(RefundCheckTriggerType.SCHEDULED);

        verify(entitlementPurchaseRevoker).revokeAndRecalculate(any(), any());
        verify(playDeveloperApiClient).findRefundedOrderIds(List.of(REFUNDED_ORDER_ID));
        BillingRefundCheckRun savedRun = captureSavedRun();
        assertThat(savedRun.getTriggerType()).isEqualTo(RefundCheckTriggerType.SCHEDULED);
        assertThat(savedRun.getVoidedPurchaseCount()).isZero();
        assertThat(savedRun.getCheckedOrderCount()).isEqualTo(1);
        assertThat(savedRun.getRefundedOrderCount()).isEqualTo(1);
        assertThat(savedRun.getRevokedCount()).isEqualTo(1);
        assertThat(savedRun.getFailureReason()).isNull();
        assertThat(savedRun.getFinishedAt()).isNotNull();
        assertThat(runResponse.isSucceeded()).isTrue();
    }

    @Test
    void 주문이_환불이_아니면_회수하지_않는다() {
        when(playDeveloperApiClient.findRefundedOrderIds(anyList())).thenReturn(List.of());

        playRefundCheckService.runRefundCheck(RefundCheckTriggerType.SCHEDULED);

        verify(entitlementPurchaseRevoker, never()).revokeAndRecalculate(any(), any());
    }

    @Test
    void 주문_조회가_실패하면_회수_없이_실패_사유를_기록한다() {
        when(playDeveloperApiClient.findRefundedOrderIds(anyList())).thenThrow(new IllegalStateException("play down"));

        RefundCheckRunResponse runResponse = playRefundCheckService.runRefundCheck(RefundCheckTriggerType.ADMIN);

        verify(entitlementPurchaseRevoker, never()).revokeAndRecalculate(any(), any());
        BillingRefundCheckRun savedRun = captureSavedRun();
        assertThat(savedRun.getFailureReason()).isEqualTo(RefundCheckFailureReason.ORDER_LOOKUP_FAILED);
        assertThat(savedRun.getCheckedOrderCount()).isEqualTo(1);
        assertThat(runResponse.isSucceeded()).isFalse();
    }

    @Test
    void 최근_실행이_실패했거나_26시간_안에_성공이_없으면_확인이_필요하다() {
        BillingRefundCheckRun failedRun = BillingRefundCheckRun.start(RefundCheckTriggerType.SCHEDULED, LocalDateTime.now(FIXED_CLOCK));
        failedRun.recordFailure(RefundCheckFailureReason.ORDER_LOOKUP_FAILED);
        when(billingRefundCheckRunRepository.findFirstByOrderByStartedAtDesc()).thenReturn(Optional.of(failedRun));
        when(billingRefundCheckRunRepository.existsByFailureReasonIsNullAndStartedAtAfter(any())).thenReturn(true);
        assertThat(playRefundCheckService.needsRefundCheckAttention()).isTrue();

        BillingRefundCheckRun succeededRun = BillingRefundCheckRun.start(RefundCheckTriggerType.SCHEDULED, LocalDateTime.now(FIXED_CLOCK));
        when(billingRefundCheckRunRepository.findFirstByOrderByStartedAtDesc()).thenReturn(Optional.of(succeededRun));
        assertThat(playRefundCheckService.needsRefundCheckAttention()).isFalse();

        when(billingRefundCheckRunRepository.existsByFailureReasonIsNullAndStartedAtAfter(any())).thenReturn(false);
        assertThat(playRefundCheckService.needsRefundCheckAttention()).isTrue();
    }

    private BillingRefundCheckRun captureSavedRun() {
        ArgumentCaptor<BillingRefundCheckRun> runCaptor = ArgumentCaptor.forClass(BillingRefundCheckRun.class);
        verify(billingRefundCheckRunRepository).save(runCaptor.capture());
        return runCaptor.getValue();
    }

    private static EntitlementPurchase verifiedPlayPurchase(String orderId) {
        return EntitlementPurchase.verified(UUID.randomUUID(), PurchaseStore.PLAY, "pass_1month", orderId,
            "purchase-token-" + orderId, LocalDateTime.now(FIXED_CLOCK).minusDays(1),
            LocalDateTime.now(FIXED_CLOCK).plusDays(29), 30);
    }
}
