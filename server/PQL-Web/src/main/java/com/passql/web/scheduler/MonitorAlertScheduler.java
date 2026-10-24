package com.passql.web.scheduler;

import com.passql.application.monitor.MonitorAlertService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class MonitorAlertScheduler {

    private final MonitorAlertService monitorAlertService;

    /** 5분마다 장애 조건 확인 (monitor.alert.enabled 가 꺼져 있으면 아무것도 하지 않음, 알림 실패가 스케줄러를 멈추지 않게 예외 삼킴) */
    @Scheduled(fixedDelay = 300_000L, initialDelay = 120_000L)
    public void checkMonitorAlerts() {
        try {
            monitorAlertService.checkAndNotify();
        } catch (RuntimeException exception) {
            log.warn("[monitor alert] check failed : {}", exception.getClass().getSimpleName());
        }
    }
}
