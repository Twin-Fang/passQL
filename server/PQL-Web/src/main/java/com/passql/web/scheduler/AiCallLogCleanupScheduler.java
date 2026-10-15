package com.passql.web.scheduler;

import com.passql.ai.service.AiCallLogService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * AI 호출 기록 보관 기간(30일) 정리 (#474)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AiCallLogCleanupScheduler {

    private final AiCallLogService aiCallLogService;

    /** 매일 04시 10분 (서버 오류 기록 정리 04시와 겹치지 않게) */
    @Scheduled(cron = "0 10 4 * * *", zone = "Asia/Seoul")
    public void purgeExpired() {
        int deleted = aiCallLogService.purgeExpired();
        if (deleted > 0) {
            log.info("[ai call log] purged expired rows : count={}", deleted);
        }
    }
}
