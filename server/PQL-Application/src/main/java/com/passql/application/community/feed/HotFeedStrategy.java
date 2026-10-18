package com.passql.application.community.feed;

import com.passql.application.community.CommunityHotScore;
import com.passql.question.constant.CommunityFeedSource;
import com.passql.question.repository.QuestionDiscussionStatsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/** 뜨는 토론: 최근 72시간 활동 문제를 hot_score 순 */
@Component
@RequiredArgsConstructor
public class HotFeedStrategy implements FeedStrategy {

    private final QuestionDiscussionStatsRepository questionDiscussionStatsRepository;

    @Override
    public CommunityFeedSource source() {
        return CommunityFeedSource.HOT;
    }

    @Override
    public List<FeedCandidate> findCandidates(UUID viewerMemberUuid, LocalDateTime now) {
        LocalDateTime activeSince = now.minusHours(CommunityHotScore.ACTIVE_WINDOW_HOURS);
        return questionDiscussionStatsRepository.findHot(activeSince, PageRequest.of(0, MAX_CANDIDATES)).stream()
                .map(stats -> FeedCandidate.ofQuestion(stats.getQuestionUuid(), stats.getPostCount(), stats.getLastActivityAt()))
                .toList();
    }

    @Override
    public boolean isSharedAcrossMembers() {
        return true;
    }
}
