package com.passql.web.scheduler;

import com.passql.application.notification.MemberNotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * 알림함 보관 기간(app_setting notification.retention_days, 기본 90일) 지난 일반 알림 정리 (#491)
 * 5,000건씩 묶음 삭제는 MemberNotificationService 가 처리
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class NotificationRetentionScheduler {

    private final MemberNotificationService memberNotificationService;

    /** 매일 04시 20분 (다른 정리 작업 04시, 04시 10분과 겹치지 않게) */
    @Scheduled(cron = "0 20 4 * * *", zone = "Asia/Seoul")
    public void purgeExpired() {
        int deleted = memberNotificationService.purgeExpiredNotifications();
        if (deleted > 0) {
            log.info("[notification retention] purged expired rows : count={}", deleted);
        }
    }
}
