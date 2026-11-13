package com.passql.web.scheduler;

import com.passql.application.notification.AutoNotificationService;
import com.passql.common.util.ServiceTimeZone;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * 재방문 자동 알림 (#649): 매시 정각에 발송 시각이 현재 시(KST)인 켜진 규칙을 발송
 * 중복 발송·하루 상한은 auto_notification_log 유니크 선점(회원·날짜·순번, 회원·날짜·규칙)이 담당 (블루-그린 동시 기동 포함)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AutoNotificationScheduler {

    private final AutoNotificationService autoNotificationService;

    @Scheduled(cron = "0 0 * * * *", zone = ServiceTimeZone.ZONE_NAME)
    public void dispatchDueRules() {
        int sentCount = autoNotificationService.dispatchDueRules(LocalDateTime.now(ServiceTimeZone.ZONE));
        if (sentCount > 0) {
            log.info("[auto notification] hourly run finished : sent={}", sentCount);
        }
    }
}
