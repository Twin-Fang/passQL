package com.passql.application.community;

import com.passql.question.entity.QuestionDiscussionStats;
import com.passql.question.repository.CommunityPostRepository;
import com.passql.question.repository.QuestionDiscussionStatsRepository;
import com.passql.question.repository.QuestionPostAggregate;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 커뮤니티 집계 작업: 문제별 토론 집계 갱신(5분마다), 글 카운터 보정(하루 1회)
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CommunityStatsService {

    private static final double SECONDS_PER_HOUR = 3600.0;

    private final CommunityPostRepository communityPostRepository;
    private final QuestionDiscussionStatsRepository questionDiscussionStatsRepository;

    /** 노출 중 글 집계 > 점수 계산 > 집계 행 생성·갱신, 글이 없어진 문제의 집계 행 삭제 */
    @Transactional
    public int refreshDiscussionStats(LocalDateTime now) {
        List<QuestionPostAggregate> aggregates = communityPostRepository.aggregateVisibleByQuestion();
        Map<UUID, QuestionDiscussionStats> existingByQuestionUuid = questionDiscussionStatsRepository.findAll().stream()
                .collect(Collectors.toMap(QuestionDiscussionStats::getQuestionUuid, Function.identity()));

        List<QuestionDiscussionStats> changed = new ArrayList<>();
        Set<UUID> aliveQuestionUuids = new HashSet<>();
        for (QuestionPostAggregate aggregate : aggregates) {
            aliveQuestionUuids.add(aggregate.getQuestionUuid());
            double hoursSinceLastActivity = Duration.between(aggregate.getLastPostedAt(), now).toSeconds() / SECONDS_PER_HOUR;
            double hotScore = CommunityHotScore.calculate(aggregate.getPostCount(), aggregate.getLikeCount(), hoursSinceLastActivity);
            QuestionDiscussionStats stats = existingByQuestionUuid.get(aggregate.getQuestionUuid());
            if (stats == null) {
                stats = QuestionDiscussionStats.of(aggregate.getQuestionUuid(), (int) aggregate.getPostCount(),
                        (int) aggregate.getLikeCount(), hotScore, aggregate.getLastPostedAt());
            } else {
                stats.update((int) aggregate.getPostCount(), (int) aggregate.getLikeCount(), hotScore, aggregate.getLastPostedAt());
            }
            changed.add(stats);
        }
        questionDiscussionStatsRepository.saveAll(changed);
        List<UUID> staleQuestionUuids = existingByQuestionUuid.keySet().stream()
                .filter(questionUuid -> !aliveQuestionUuids.contains(questionUuid)).toList();
        questionDiscussionStatsRepository.deleteAllById(staleQuestionUuids);
        return changed.size();
    }

    /** 좋아요·신고 수를 실제 행 수로 보정 (원자 갱신이 어긋났을 때 대비) */
    @Transactional
    public void reconcilePostCounters() {
        int likeFixed = communityPostRepository.reconcileLikeCounts();
        int reportFixed = communityPostRepository.reconcileReportCounts();
        if (likeFixed > 0 || reportFixed > 0) {
            log.warn("[community] counters reconciled : likeFixed={}, reportFixed={}", likeFixed, reportFixed);
        }
    }
}
