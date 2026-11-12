package com.passql.application.billing;

import com.passql.application.entitlement.EntitlementPurchaseRevoker;
import com.passql.application.entitlement.EntitlementPurchaseRevoker.RevocationResult;
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
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.function.Function;

/**
 * Play 환불 회수 확인 (#576, #984): 취소 구매 목록 + 프로 유효 회원 주문 상태 > 구매 REVOKED > 등급 재계산, 실행마다 기록 1행
 * 자동(매일 스케줄)·수동(관리자) 공통, 같은 서버 안 동시 실행은 순서대로 (반복 실행 안전)
 */
@Slf4j
@Service
public class PlayRefundCheckService {

    // 환불 조회 기간 (Play 허용 최대 30일, 요청 지연 여유 10분)
    private static final Duration VOIDED_PURCHASE_LOOKBACK = Duration.ofDays(30).minusMinutes(10);
    // 관리자 화면 최근 실행 표 행 수 (2주)
    static final int RECENT_RUN_COUNT = 14;
    // 이 시간 안에 성공 실행이 없으면 관제소 확인할 일 (매일 1회 + 여유 2시간)
    static final Duration SUCCESSFUL_RUN_MAXIMUM_INTERVAL = Duration.ofHours(26);

    private final PlayDeveloperApiClient playDeveloperApiClient;
    private final EntitlementPurchaseRepository entitlementPurchaseRepository;
    private final EntitlementPurchaseRevoker entitlementPurchaseRevoker;
    private final BillingRefundCheckRunRepository billingRefundCheckRunRepository;
    private final TransactionTemplate transactionTemplate;
    private final ApplicationEventPublisher eventPublisher;
    private final Clock clock;

    @Autowired
    public PlayRefundCheckService(PlayDeveloperApiClient playDeveloperApiClient,
                                  EntitlementPurchaseRepository entitlementPurchaseRepository,
                                  EntitlementPurchaseRevoker entitlementPurchaseRevoker,
                                  BillingRefundCheckRunRepository billingRefundCheckRunRepository,
                                  TransactionTemplate transactionTemplate,
                                  ApplicationEventPublisher eventPublisher) {
        this(playDeveloperApiClient, entitlementPurchaseRepository, entitlementPurchaseRevoker,
            billingRefundCheckRunRepository, transactionTemplate, eventPublisher, Clock.system(ServiceTimeZone.ZONE));
    }

    PlayRefundCheckService(PlayDeveloperApiClient playDeveloperApiClient,
                           EntitlementPurchaseRepository entitlementPurchaseRepository,
                           EntitlementPurchaseRevoker entitlementPurchaseRevoker,
                           BillingRefundCheckRunRepository billingRefundCheckRunRepository,
                           TransactionTemplate transactionTemplate,
                           ApplicationEventPublisher eventPublisher, Clock clock) {
        this.playDeveloperApiClient = playDeveloperApiClient;
        this.entitlementPurchaseRepository = entitlementPurchaseRepository;
        this.entitlementPurchaseRevoker = entitlementPurchaseRevoker;
        this.billingRefundCheckRunRepository = billingRefundCheckRunRepository;
        this.transactionTemplate = transactionTemplate;
        this.eventPublisher = eventPublisher;
        this.clock = clock;
    }

    /**
     * 환불 회수 확인 1회: 서비스 계정 확인 > 취소 구매 목록 회수 > 주문 상태 회수 > 실행 기록 저장
     * 단계 실패는 사유만 남기고 다음 단계 진행, 기록은 성공·실패 공통
     */
    public synchronized RefundCheckRunResponse runRefundCheck(RefundCheckTriggerType triggerType) {
        BillingRefundCheckRun run = BillingRefundCheckRun.start(triggerType, LocalDateTime.now(clock));
        try {
            if (!playDeveloperApiClient.isConfigured()) {
                log.info("[billing refund check] skipped : service account not configured");
                run.recordFailure(RefundCheckFailureReason.SERVICE_ACCOUNT_NOT_CONFIGURED);
            } else {
                revokeVoidedPurchaseTokens(run);
                revokeRefundedOrders(run);
            }
        } catch (RuntimeException exception) {
            log.error("[billing refund check] failed : cause={}", exception.getClass().getSimpleName(), exception);
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

    /** 최근 실행 기록 (관리자 화면, 최신순 14건) */
    public List<RefundCheckRunResponse> getRecentRuns() {
        return billingRefundCheckRunRepository.findAllByOrderByStartedAtDesc(PageRequest.of(0, RECENT_RUN_COUNT)).stream()
            .map(RefundCheckRunResponse::from)
            .toList();
    }

    /** 확인 필요 여부: 가장 최근 실행 실패, 또는 26시간 안에 성공 실행 없음 (기록이 하나도 없어도 true) */
    public boolean needsRefundCheckAttention() {
        Optional<BillingRefundCheckRun> latestRun = billingRefundCheckRunRepository.findFirstByOrderByStartedAtDesc();
        if (latestRun.isPresent() && !latestRun.get().isSucceeded()) {
            return true;
        }
        LocalDateTime successfulSince = LocalDateTime.now(clock).minus(SUCCESSFUL_RUN_MAXIMUM_INTERVAL);
        return !billingRefundCheckRunRepository.existsByFailureReasonIsNullAndStartedAtAfter(successfulSince);
    }

    /** 최근 30일 취소 구매 토큰 > 토큰별 회수 (조회 실패 > 사유 기록) */
    private void revokeVoidedPurchaseTokens(BillingRefundCheckRun run) {
        Instant since = clock.instant().minus(VOIDED_PURCHASE_LOOKBACK);
        List<String> voidedPurchaseTokens;
        try {
            voidedPurchaseTokens = playDeveloperApiClient.listVoidedPurchaseTokens(since);
        } catch (RuntimeException exception) {
            log.warn("[billing refund check] voided purchase list failed : cause={}", exception.getClass().getSimpleName());
            run.recordFailure(RefundCheckFailureReason.VOIDED_PURCHASE_LIST_FAILED);
            return;
        }
        int revokedCount = revokeEachIfVerified(voidedPurchaseTokens, entitlementPurchaseRepository::findByPurchaseToken);
        run.recordVoidedPurchaseStep(voidedPurchaseTokens.size(), revokedCount);
        log.info("[billing refund check] voided purchases : voided={}, revoked={}", voidedPurchaseTokens.size(), revokedCount);
    }

    /**
     * 권한 회수 없는 환불: 프로 유효 회원 검증 구매 주문 번호 > orders.batchget REFUNDED > 주문별 회수
     * 취소 구매 목록 API 는 권한 회수 없는 환불을 돌려주지 않음, 대체 주문 번호(PLAY-NO-ORDER-)는 Play 에 없어 제외
     */
    private void revokeRefundedOrders(BillingRefundCheckRun run) {
        List<String> orderIds = entitlementPurchaseRepository
            .findVerifiedPurchasesOfActiveProMembers(PurchaseStore.PLAY, LocalDateTime.now(clock)).stream()
            .map(EntitlementPurchase::getOrderId)
            .filter(orderId -> !orderId.startsWith(PlayBillingService.FALLBACK_ORDER_ID_PREFIX))
            .toList();
        run.recordCheckedOrderCount(orderIds.size());
        if (orderIds.isEmpty()) {
            log.info("[billing refund check] refunded orders : checked=0, refunded=0, revoked=0");
            return;
        }
        List<String> refundedOrderIds;
        try {
            refundedOrderIds = playDeveloperApiClient.findRefundedOrderIds(orderIds);
        } catch (RuntimeException exception) {
            log.warn("[billing refund check] order lookup failed : cause={}", exception.getClass().getSimpleName());
            run.recordFailure(RefundCheckFailureReason.ORDER_LOOKUP_FAILED);
            return;
        }
        int revokedCount = revokeEachIfVerified(refundedOrderIds, entitlementPurchaseRepository::findByOrderId);
        run.recordRefundedOrderStep(refundedOrderIds.size(), revokedCount);
        log.info("[billing refund check] refunded orders : checked={}, refunded={}, revoked={}",
            orderIds.size(), refundedOrderIds.size(), revokedCount);
    }

    /** 키(토큰·주문 번호)별 건별 트랜잭션 회수 (한 건 실패가 나머지를 막지 않음), 회수 건수 반환 */
    private int revokeEachIfVerified(List<String> purchaseKeys,
                                     Function<String, Optional<EntitlementPurchase>> purchaseFinder) {
        int revokedCount = 0;
        for (String purchaseKey : purchaseKeys) {
            try {
                Boolean isRevoked = transactionTemplate.execute(status -> revokePurchaseIfVerified(purchaseFinder.apply(purchaseKey)));
                if (Boolean.TRUE.equals(isRevoked)) {
                    revokedCount++;
                }
            } catch (RuntimeException exception) {
                log.warn("[billing refund check] revoke failed : cause={}", exception.getClass().getSimpleName());
            }
        }
        return revokedCount;
    }

    /** 환불 구매 1건: 검증 상태 구매만 회수 > 회원 등급 재계산(공통 회수기), 회수했으면 true */
    private boolean revokePurchaseIfVerified(Optional<EntitlementPurchase> foundPurchase) {
        Optional<EntitlementPurchase> verifiedPurchase = foundPurchase
            .filter(purchase -> purchase.getStatus() == PurchaseStatus.VERIFIED);
        if (verifiedPurchase.isEmpty()) {
            return false;
        }
        EntitlementPurchase purchase = verifiedPurchase.get();
        RevocationResult revocationResult = entitlementPurchaseRevoker.revokeAndRecalculate(purchase, LocalDateTime.now(clock));
        // 재계산 종류별 로그 (등급 행 없음, 관리자 부여 유지, 만료일 변경)
        switch (revocationResult.kind()) {
            case NO_ENTITLEMENT -> log.info("[billing] revoked : member={}, order={}, no entitlement",
                purchase.getMemberUuid(), purchase.getOrderId());
            case ADMIN_GRANT_KEPT -> log.info("[billing] revoked : member={}, order={}, admin grant kept",
                purchase.getMemberUuid(), purchase.getOrderId());
            case RECALCULATED -> log.info("[billing] revoked : member={}, order={}, expires {} -> {}",
                purchase.getMemberUuid(), purchase.getOrderId(), revocationResult.beforeExpiresAt(), revocationResult.afterExpiresAt());
        }
        return true;
    }

    /** 감사 로그: 관리자 수동 실행만, 요청 스레드에서 발행 (관리자·IP 를 요청에서 읽음) */
    private void publishAuditEvent(BillingRefundCheckRun run) {
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.BILLING_REFUND_CHECK,
            run.getBillingRefundCheckRunUuid(), AdminAuditAction.RUN, null,
            AdminAuditEvent.summary("revokedCount", run.getRevokedCount(),
                "failureReason", run.getFailureReason() == null ? null : run.getFailureReason().name())));
    }
}
