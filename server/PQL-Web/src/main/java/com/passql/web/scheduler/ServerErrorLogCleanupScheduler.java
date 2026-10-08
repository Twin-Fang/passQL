package com.passql.web.scheduler;

import com.passql.meta.service.ServerErrorLogService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class ServerErrorLogCleanupScheduler {

    private final ServerErrorLogService serverErrorLogService;

    /** 매일 04시 보관 기간(30일)이 지난 서버 오류 기록 삭제 — 컨테이너 로그 보관 기간(#436)과 맞춘다 */
    @Scheduled(cron = "0 0 4 * * *", zone = "Asia/Seoul")
    public void purgeExpired() {
        int deleted = serverErrorLogService.purgeExpired();
        if (deleted > 0) {
            log.info("[server-error-log] 보관 기간 지난 기록 {}건 삭제", deleted);
        }
    }
}
