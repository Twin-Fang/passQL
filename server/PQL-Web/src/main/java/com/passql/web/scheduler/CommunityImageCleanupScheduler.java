package com.passql.web.scheduler;

import com.passql.application.community.CommunityImageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/** 커뮤니티 미첨부 이미지 정리: 매시 15분, 24시간 지난 tmp/ 이미지 삭제 (#525) */
@Slf4j
@Component
@RequiredArgsConstructor
public class CommunityImageCleanupScheduler {

    private final CommunityImageService communityImageService;

    @Scheduled(cron = "0 15 * * * *", zone = "Asia/Seoul")
    public void cleanUpOrphanTemporaryImages() {
        try {
            communityImageService.cleanUpOrphanTemporaryImages(LocalDateTime.now());
        } catch (RuntimeException e) {
            log.error("[community image] orphan cleanup failed", e);
        }
    }
}
