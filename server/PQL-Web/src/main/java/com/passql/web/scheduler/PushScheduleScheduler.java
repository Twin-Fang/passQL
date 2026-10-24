package com.passql.web.scheduler;

import com.passql.application.notification.MemberNotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * 관리자 푸시 예약 발송 (#629): 매분 발송 시각이 된 예약을 찾아 발송
 * 중복 발송 방지는 MemberNotificationService 의 건별 선점(SCHEDULED > DISPATCHED 조건부 UPDATE)이 담당
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class PushScheduleScheduler {

    private final MemberNotificationService memberNotificationService;

    /** 매분 0초 (예약 시각은 분 단위 입력) */
    @Scheduled(cron = "0 * * * * *", zone = "Asia/Seoul")
    public void dispatchDueSchedules() {
        int dispatchedCount = memberNotificationService.dispatchDueScheduledSends();
        if (dispatchedCount > 0) {
            log.info("[push schedule] dispatched due sends : count={}", dispatchedCount);
        }
    }
}
