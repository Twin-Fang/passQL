package com.passql.application.billing;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.util.ServiceTimeZone;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;
import com.passql.member.constant.RefundCheckFailureReason;
import com.passql.member.constant.RefundCheckTriggerType;
import com.passql.member.entity.BillingRefundCheckRun;
import com.passql.member.entity.EntitlementPurchase;
import com.passql.member.repository.BillingRefundCheckRunRepository;
import com.passql.member.repository.EntitlementPurchaseRepository;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.time.Clock;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * App Store 환불 점검 (#1032): 최근 검증 구매 거래 조회 > Apple 회수 표시(revocationDate) > 구매 REVOKED > 등급 재계산
 * 서버 알림(REFUND) 누락 대비 안전망, 자동(매일 스케줄)·수동(관리자) 공통, 실행마다 billing_refund_check_run 1행(store APP_STORE)
 * 인앱 결제 키가 없으면 호출 없이 APP_STORE_KEY_NOT_CONFIGURED 기록
 */
@Slf4j
@Service
public class AppStoreRefundCheckService {

    // 확인 대상 구매 기간 (구매 후 180일 안 거래만, Apple 환불 요청 기한 여유 포함)
    static final Duration PURCHASE_LOOKBACK = Duration.ofDays(180);
    // 관리자 화면 최근 실행 표 행 수 (2주)
    static final int RECENT_RUN_COUNT = 14;

    private final AppStoreServerApiClient appStoreServerApiClient;
    private final EntitlementPurchaseRepository entitlementPurchaseRepository;
    private final AppStoreBillingService appStoreBillingService;
    private final BillingRefundCheckRunRepository billingRefundCheckRunRepository;
    private final AppSettingService appSettingService;
    private final ApplicationEventPublisher eventPublisher;
    private final Clock clock;

    @Autowired
    public AppStoreRefundCheckService(AppStoreServerApiClient appStoreServerApiClient,
                                      EntitlementPurchaseRepository entitlementPurchaseRepository,
                                      AppStoreBillingService appStoreBillingService,
                                      BillingRefundCheckRunRepository billingRefundCheckRunRepository,
                                      AppSettingService appSettingService,
                                      ApplicationEventPublisher eventPublisher) {
        this(appStoreServerApiClient, entitlementPurchaseRepository, appStoreBillingService,
            billingRefundCheckRunRepository, appSettingService, eventPublisher, Clock.system(ServiceTimeZone.ZONE));
    }

    AppStoreRefundCheckService(AppStoreServerApiClient appStoreServerApiClient,
                               EntitlementPurchaseRepository entitlementPurchaseRepository,
                               AppStoreBillingService appStoreBillingService,
                               BillingRefundCheckRunRepository billingRefundCheckRunRepository,
                               AppSettingService appSettingService,
                               ApplicationEventPublisher eventPublisher, Clock clock) {
        this.appStoreServerApiClient = appStoreServerApiClient;
        this.entitlementPurchaseRepository = entitlementPurchaseRepository;
        this.appStoreBillingService = appStoreBillingService;
        this.billingRefundCheckRunRepository = billingRefundCheckRunRepository;
        this.appSettingService = appSettingService;
        this.eventPublisher = eventPublisher;
        this.clock = clock;
    }

    /** 환불 점검 1회: 키 확인 > 거래별 조회·회수 > 실행 기록 저장 (기록은 성공·실패 공통) */
    public synchronized RefundCheckRunResponse runRefundCheck(RefundCheckTriggerType triggerType) {
        BillingRefundCheckRun run = BillingRefundCheckRun.start(PurchaseStore.APP_STORE, triggerType, LocalDateTime.now(clock));
        try {
            if (!appStoreServerApiClient.isConfigured()) {
                log.info("[billing app store refund check] skipped : server api key not configured");
                run.recordFailure(RefundCheckFailureReason.APP_STORE_KEY_NOT_CONFIGURED);
            } else {
                revokeRefundedTransactions(run);
            }
        } catch (RuntimeException exception) {
            log.error("[billing app store refund check] failed : cause={}", exception.getClass().getSimpleName(), exception);
            run.recordFailure(RefundCheckFailureReason.UNEXPECTED_ERROR);
        } finally {
            // 성공·실패 공통
            run.finish(LocalDateTime.now(clock));
            billingRefundCheckRunRepository.save(run);
        }
        if (triggerType == RefundCheckTriggerType.ADMIN) {
            publishAuditEvent(run);
        }
        return RefundCheckRunResponse.from(run);
    }

    /** 화면 값: 키 설정 여부, 설정 2개, 최근 실행 14건 (최신순) */
    public AppStoreRefundCheckOverview getOverview() {
        List<RefundCheckRunResponse> recentRuns = billingRefundCheckRunRepository
            .findAllByStoreOrderByStartedAtDesc(PurchaseStore.APP_STORE, PageRequest.of(0, RECENT_RUN_COUNT)).stream()
            .map(RefundCheckRunResponse::from)
            .toList();
        return new AppStoreRefundCheckOverview(appStoreServerApiClient.isConfigured(), isSandboxFallbackEnabled(),
            appSettingService.getBooleanOrDefault(AppSettingKeys.BILLING_APP_STORE_CONSUMPTION_RESPONSE_ENABLED, false),
            recentRuns);
    }

    /**
     * 최근 180일 App Store 검증 구매 > 거래 조회 > revocationDate 있으면 회수
     * 거래별 실패는 건너뛰고 다음 거래 진행, 하나라도 실패하면 TRANSACTION_LOOKUP_FAILED
     */
    private void revokeRefundedTransactions(BillingRefundCheckRun run) {
        List<String> transactionIds = entitlementPurchaseRepository
            .findByStoreAndStatusAndPurchasedAtAfter(PurchaseStore.APP_STORE, PurchaseStatus.VERIFIED,
                LocalDateTime.now(clock).minus(PURCHASE_LOOKBACK)).stream()
            .map(EntitlementPurchase::getOrderId)
            .toList();
        run.recordCheckedOrderCount(transactionIds.size());
        boolean isSandboxFallbackEnabled = isSandboxFallbackEnabled();
        int refundedCount = 0;
        int revokedCount = 0;
        boolean hasLookupFailure = false;
        for (String transactionId : transactionIds) {
            try {
                Optional<AppStoreTransaction> transaction =
                    appStoreServerApiClient.findTransaction(transactionId, isSandboxFallbackEnabled);
                if (transaction.isEmpty() || transaction.get().revokedAt() == null) {
                    continue;
                }
                refundedCount++;
                if (appStoreBillingService.revokeVerifiedPurchase(transactionId)) {
                    revokedCount++;
                }
            } catch (RuntimeException exception) {
                hasLookupFailure = true;
                log.warn("[billing app store refund check] lookup failed : transaction={}, cause={}",
                    transactionId, exception.getClass().getSimpleName());
            }
        }
        run.recordRefundedOrderStep(refundedCount, revokedCount);
        if (hasLookupFailure) {
            run.recordFailure(RefundCheckFailureReason.TRANSACTION_LOOKUP_FAILED);
        }
        log.info("[billing app store refund check] done : checked={}, refunded={}, revoked={}",
            transactionIds.size(), refundedCount, revokedCount);
    }

    private boolean isSandboxFallbackEnabled() {
        return appSettingService.getBooleanOrDefault(AppSettingKeys.BILLING_APP_STORE_SANDBOX_FALLBACK_ENABLED, true);
    }

    /** 감사 로그: 관리자 수동 실행만 (Play 환불 확인과 같은 대상 종류) */
    private void publishAuditEvent(BillingRefundCheckRun run) {
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.BILLING_REFUND_CHECK,
            run.getBillingRefundCheckRunUuid(), AdminAuditAction.RUN, null,
            AdminAuditEvent.summary("store", PurchaseStore.APP_STORE.name(), "revokedCount", run.getRevokedCount(),
                "failureReason", run.getFailureReason() == null ? null : run.getFailureReason().name())));
    }
}
