package com.passql.application.community.feed;

import com.passql.question.constant.CommunityFeedSource;
import com.passql.question.repository.CommunityPostRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/** 내 의견: 내가 의견을 쓴 문제를 최근 작성순, 카드에 내 글 수·받은 좋아요 수 */
@Component
@RequiredArgsConstructor
public class MyPostsFeedStrategy implements FeedStrategy {

    private final CommunityPostRepository communityPostRepository;

    @Override
    public CommunityFeedSource source() {
        return CommunityFeedSource.MINE;
    }

    @Override
    public List<FeedCandidate> findCandidates(UUID viewerMemberUuid, LocalDateTime now) {
        return communityPostRepository.aggregateVisibleByQuestionOfAuthor(viewerMemberUuid).stream().limit(MAX_CANDIDATES)
                .map(aggregate -> new FeedCandidate(aggregate.getQuestionUuid(), (int) aggregate.getPostCount(),
                        aggregate.getLastPostedAt(), (int) aggregate.getPostCount(), (int) aggregate.getLikeCount()))
                .toList();
    }

    @Override
    public boolean isSharedAcrossMembers() {
        return false;
    }
}
