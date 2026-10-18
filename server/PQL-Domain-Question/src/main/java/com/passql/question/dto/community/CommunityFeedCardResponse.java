package com.passql.question.dto.community;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 피드의 문제 카드: 지문 앞 80자(마크다운 제거), 토픽, 의견 수, 최근 활동 시각, 내가 풀었는지
 * myPostCount·receivedLikeCount: 내 의견 탭(mine)에서만 값, 그 외 null
 */
public record CommunityFeedCardResponse(
        UUID questionUuid,
        String stemPreview,
        @Schema(nullable = true) String topicCode,
        @Schema(nullable = true) String topicName,
        Integer postCount,
        LocalDateTime lastActivityAt,
        Boolean isSolvedByMe,
        @Schema(nullable = true) Integer myPostCount,
        @Schema(nullable = true) Integer receivedLikeCount
) {
}
