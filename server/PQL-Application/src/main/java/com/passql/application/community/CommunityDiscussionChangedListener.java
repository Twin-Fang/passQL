package com.passql.application.community;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.time.LocalDateTime;

/**
 * 의견 변경 커밋 직후: 해당 문제 집계 즉시 갱신 > 공용 피드 캐시 삭제 (#739)
 * 실패해도 요청은 성공 처리, 5분 정기 집계가 보정
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class CommunityDiscussionChangedListener {

    private final CommunityStatsService communityStatsService;
    private final CommunityFeedService communityFeedService;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
    public void refreshDiscussionFeed(CommunityDiscussionChangedEvent event) {
        try {
            communityStatsService.refreshQuestionStats(event.questionUuid(), LocalDateTime.now());
            communityFeedService.evictSharedFeedCache();
        } catch (RuntimeException e) {
            log.warn("[community] discussion stats instant refresh failed : question={}, cause={}",
                    event.questionUuid(), e.getClass().getSimpleName());
        }
    }
}
