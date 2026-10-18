package com.passql.web.scheduler;

import com.passql.application.community.CommunityStatsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/** 커뮤니티 집계 작업: 문제별 토론 집계 5분마다, 글 카운터 보정 매일 04시 30분 (#525) */
@Slf4j
@Component
@RequiredArgsConstructor
public class CommunityStatsScheduler {

    private final CommunityStatsService communityStatsService;

    /** 5분마다 토론 집계 갱신 (기동 후 첫 실행은 1분 뒤) */
    @Scheduled(initialDelay = 60_000, fixedDelay = 300_000)
    public void refreshDiscussionStats() {
        try {
            int refreshed = communityStatsService.refreshDiscussionStats(LocalDateTime.now());
            log.debug("[community] discussion stats refreshed : questions={}", refreshed);
        } catch (RuntimeException e) {
            log.error("[community] discussion stats refresh failed", e);
        }
    }

    /** 매일 04시 30분 (다른 정리 작업 04시, 04시 10·20분과 겹치지 않게) */
    @Scheduled(cron = "0 30 4 * * *", zone = "Asia/Seoul")
    public void reconcilePostCounters() {
        communityStatsService.reconcilePostCounters();
    }
}
