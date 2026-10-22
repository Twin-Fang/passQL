package com.passql.web.scheduler;

import com.passql.application.billing.PlayBillingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Play 환불·취소 구매 회수: 최근 30일 환불 목록 > 구매 REVOKED > 등급 재계산 (#576)
 * 서비스 계정 키가 없으면 PlayBillingService 가 건너뜀
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class PlayVoidedPurchaseScheduler {

    private final PlayBillingService playBillingService;

    /** 매일 04시 50분 (다른 새벽 정리 작업과 겹치지 않게) */
    @Scheduled(cron = "0 50 4 * * *", zone = "Asia/Seoul")
    public void revokeVoidedPurchases() {
        try {
            playBillingService.revokeVoidedPurchases();
        } catch (RuntimeException exception) {
            log.error("[billing] voided purchase check failed : cause={}", exception.getClass().getSimpleName(), exception);
        }
    }
}
