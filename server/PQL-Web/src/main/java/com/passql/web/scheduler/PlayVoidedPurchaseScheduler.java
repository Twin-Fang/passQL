package com.passql.web.scheduler;

import com.passql.application.billing.PlayRefundCheckService;
import com.passql.common.util.ServiceTimeZone;
import com.passql.member.constant.RefundCheckTriggerType;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Play 환불·취소 구매 회수: 최근 30일 환불 목록 + 프로 유효 회원 주문 환불 상태(#984) > 구매 REVOKED > 등급 재계산 (#576)
 * 실행마다 billing_refund_check_run 1행 기록, 서비스 계정 키가 없으면 PlayRefundCheckService 가 건너뜀(실패 사유 기록)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class PlayVoidedPurchaseScheduler {

    private final PlayRefundCheckService playRefundCheckService;

    /** 매일 04시 50분 (다른 새벽 정리 작업과 겹치지 않게) */
    @Scheduled(cron = "0 50 4 * * *", zone = ServiceTimeZone.ZONE_NAME)
    public void revokeVoidedPurchases() {
        try {
            playRefundCheckService.runRefundCheck(RefundCheckTriggerType.SCHEDULED);
        } catch (RuntimeException exception) {
            log.error("[billing] voided purchase check failed : cause={}", exception.getClass().getSimpleName(), exception);
        }
    }
}
