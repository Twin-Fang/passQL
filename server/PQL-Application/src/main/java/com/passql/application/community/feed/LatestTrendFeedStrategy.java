package com.passql.application.community.feed;

import com.passql.question.constant.CommunityFeedSource;
import com.passql.question.repository.QuestionDiscussionStatsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/** 최신 경향: question.is_latest_trend(#523) 문제 중 의견이 있는 문제를 최근 활동순 */
@Component
@RequiredArgsConstructor
public class LatestTrendFeedStrategy implements FeedStrategy {

    private final QuestionDiscussionStatsRepository questionDiscussionStatsRepository;

    @Override
    public CommunityFeedSource source() {
        return CommunityFeedSource.TREND;
    }

    @Override
    public List<FeedCandidate> findCandidates(UUID viewerMemberUuid, LocalDateTime now) {
        return questionDiscussionStatsRepository.findLatestTrend(PageRequest.of(0, MAX_CANDIDATES)).stream()
                .map(stats -> FeedCandidate.ofQuestion(stats.getQuestionUuid(), stats.getPostCount(), stats.getLastActivityAt()))
                .toList();
    }

    @Override
    public boolean isSharedAcrossMembers() {
        return true;
    }
}
