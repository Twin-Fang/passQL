package com.passql.application.billing;

import com.passql.member.constant.PurchaseStore;
import com.passql.member.constant.RefundCheckFailureReason;
import com.passql.member.constant.RefundCheckTriggerType;
import com.passql.member.entity.BillingRefundCheckRun;
import com.passql.member.entity.EntitlementPurchase;
import com.passql.member.repository.BillingRefundCheckRunRepository;
import com.passql.member.repository.EntitlementPurchaseRepository;
import com.passql.meta.service.AppSettingService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.context.ApplicationEventPublisher;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * App Store 환불 점검 (#1032): 키 미설정이면 호출 없이 건너뜀, Apple 회수 표시 거래만 회수, 실행 기록 store APP_STORE
 */
class AppStoreRefundCheckServiceTest {

    private static final Clock FIXED_CLOCK = Clock.fixed(Instant.parse("2026-11-12T19:55:00Z"), ZoneId.of("Asia/Seoul"));
    private static final String REFUNDED_TRANSACTION_ID = "2000000000000001";
    private static final String ACTIVE_TRANSACTION_ID = "2000000000000002";

    private final AppStoreServerApiClient appStoreServerApiClient = mock(AppStoreServerApiClient.class);
    private final EntitlementPurchaseRepository entitlementPurchaseRepository = mock(EntitlementPurchaseRepository.class);
    private final AppStoreBillingService appStoreBillingService = mock(AppStoreBillingService.class);
    private final BillingRefundCheckRunRepository billingRefundCheckRunRepository = mock(BillingRefundCheckRunRepository.class);
    private final AppSettingService appSettingService = mock(AppSettingService.class);
    private AppStoreRefundCheckService appStoreRefundCheckService;

    @BeforeEach
    void setUp() {
        appStoreRefundCheckService = new AppStoreRefundCheckService(appStoreServerApiClient, entitlementPurchaseRepository,
            appStoreBillingService, billingRefundCheckRunRepository, appSettingService,
            mock(ApplicationEventPublisher.class), FIXED_CLOCK);
        when(appSettingService.getBooleanOrDefault(anyString(), anyBoolean())).thenReturn(true);
    }

    @Test
    void 인앱_결제_키가_없으면_Apple_호출_없이_건너뛰고_사유를_기록한다() {
        when(appStoreServerApiClient.isConfigured()).thenReturn(false);

        RefundCheckRunResponse runResponse = appStoreRefundCheckService.runRefundCheck(RefundCheckTriggerType.SCHEDULED);

        verify(appStoreServerApiClient, never()).findTransaction(anyString(), anyBoolean());
        BillingRefundCheckRun savedRun = captureSavedRun();
        assertThat(savedRun.getStore()).isEqualTo(PurchaseStore.APP_STORE);
        assertThat(savedRun.getFailureReason()).isEqualTo(RefundCheckFailureReason.APP_STORE_KEY_NOT_CONFIGURED);
        assertThat(runResponse.isSucceeded()).isFalse();
    }

    @Test
    void Apple이_회수_표시한_거래만_회수한다() {
        when(appStoreServerApiClient.isConfigured()).thenReturn(true);
        when(entitlementPurchaseRepository.findByStoreAndStatusAndPurchasedAtAfter(eq(PurchaseStore.APP_STORE), any(), any()))
            .thenReturn(List.of(verifiedAppStorePurchase(REFUNDED_TRANSACTION_ID), verifiedAppStorePurchase(ACTIVE_TRANSACTION_ID)));
        when(appStoreServerApiClient.findTransaction(REFUNDED_TRANSACTION_ID, true))
            .thenReturn(Optional.of(transaction(REFUNDED_TRANSACTION_ID, Instant.parse("2026-11-12T01:00:00Z"))));
        when(appStoreServerApiClient.findTransaction(ACTIVE_TRANSACTION_ID, true))
            .thenReturn(Optional.of(transaction(ACTIVE_TRANSACTION_ID, null)));
        when(appStoreBillingService.revokeVerifiedPurchase(REFUNDED_TRANSACTION_ID)).thenReturn(true);

        RefundCheckRunResponse runResponse = appStoreRefundCheckService.runRefundCheck(RefundCheckTriggerType.ADMIN);

        verify(appStoreBillingService).revokeVerifiedPurchase(REFUNDED_TRANSACTION_ID);
        verify(appStoreBillingService, never()).revokeVerifiedPurchase(ACTIVE_TRANSACTION_ID);
        BillingRefundCheckRun savedRun = captureSavedRun();
        assertThat(savedRun.getCheckedOrderCount()).isEqualTo(2);
        assertThat(savedRun.getRefundedOrderCount()).isEqualTo(1);
        assertThat(savedRun.getRevokedCount()).isEqualTo(1);
        assertThat(runResponse.isSucceeded()).isTrue();
    }

    private BillingRefundCheckRun captureSavedRun() {
        ArgumentCaptor<BillingRefundCheckRun> runCaptor = ArgumentCaptor.forClass(BillingRefundCheckRun.class);
        verify(billingRefundCheckRunRepository).save(runCaptor.capture());
        return runCaptor.getValue();
    }

    private static EntitlementPurchase verifiedAppStorePurchase(String transactionId) {
        return EntitlementPurchase.verified(UUID.randomUUID(), PurchaseStore.APP_STORE, "pro_pass_1m", transactionId,
            "appstore:" + transactionId, LocalDateTime.now(FIXED_CLOCK).minusDays(1),
            LocalDateTime.now(FIXED_CLOCK).plusDays(29), 30);
    }

    private static AppStoreTransaction transaction(String transactionId, Instant revokedAt) {
        return new AppStoreTransaction(transactionId, transactionId, AppleAppStoreSignedDataVerifier.BUNDLE_ID,
            "pro_pass_1m", "Non-Renewing Subscription", Instant.parse("2026-11-11T14:51:00Z"), null, revokedAt,
            "Production", null);
    }
}
