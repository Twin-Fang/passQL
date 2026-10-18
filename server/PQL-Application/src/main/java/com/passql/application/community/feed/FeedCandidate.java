package com.passql.application.community.feed;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 피드 후보 문제 1건 (순서가 곧 노출 순서)
 * myPostCount·receivedLikeCount: 내 의견 탭에서만 값, 그 외 null
 */
public record FeedCandidate(
        UUID questionUuid,
        int postCount,
        LocalDateTime lastActivityAt,
        Integer myPostCount,
        Integer receivedLikeCount
) {
    public static FeedCandidate ofQuestion(UUID questionUuid, int postCount, LocalDateTime lastActivityAt) {
        return new FeedCandidate(questionUuid, postCount, lastActivityAt, null, null);
    }
}
