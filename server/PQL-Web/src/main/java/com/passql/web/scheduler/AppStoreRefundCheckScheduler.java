package com.passql.web.scheduler;

import com.passql.application.billing.AppStoreRefundCheckService;
import com.passql.common.util.ServiceTimeZone;
import com.passql.member.constant.RefundCheckTriggerType;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * App Store 환불 점검 (#1032): 최근 180일 App Store 검증 구매 거래 조회 > Apple 회수 표시면 구매 REVOKED > 등급 재계산
 * 서버 알림 누락 대비 안전망, 인앱 결제 키가 없으면 AppStoreRefundCheckService 가 건너뜀(사유 기록)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AppStoreRefundCheckScheduler {

    private final AppStoreRefundCheckService appStoreRefundCheckService;

    /** 매일 04시 55분 (Play 환불 확인 04:50 직후) */
    @Scheduled(cron = "0 55 4 * * *", zone = ServiceTimeZone.ZONE_NAME)
    public void checkAppStoreRefunds() {
        try {
            appStoreRefundCheckService.runRefundCheck(RefundCheckTriggerType.SCHEDULED);
        } catch (RuntimeException exception) {
            log.error("[billing app store refund check] scheduled run failed : cause={}", exception.getClass().getSimpleName(), exception);
        }
    }
}
