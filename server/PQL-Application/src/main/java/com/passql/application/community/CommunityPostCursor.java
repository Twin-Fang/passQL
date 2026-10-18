package com.passql.application.community;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.entity.CommunityPost;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.UUID;

/**
 * 글 목록 커서: 마지막 글의 (좋아요 수, 작성 시각, UUID) > base64url 문자열
 * 첫 페이지는 정렬상 가장 앞선 값(센티넬)으로 같은 쿼리를 재사용
 */
record CommunityPostCursor(int likeCount, LocalDateTime createdAt, UUID postUuid) {

    private static final String DELIMITER = "|";
    // 첫 페이지 센티넬: 모든 글보다 앞선 값
    static final CommunityPostCursor FIRST_PAGE =
            new CommunityPostCursor(Integer.MAX_VALUE, LocalDateTime.of(3000, 1, 1, 0, 0), new UUID(-1L, -1L));

    static CommunityPostCursor decode(String cursor) {
        if (cursor == null || cursor.isBlank()) {
            return FIRST_PAGE;
        }
        try {
            String raw = new String(Base64.getUrlDecoder().decode(cursor), StandardCharsets.UTF_8);
            String[] parts = raw.split("\\" + DELIMITER);
            return new CommunityPostCursor(Integer.parseInt(parts[0]), LocalDateTime.parse(parts[1]), UUID.fromString(parts[2]));
        } catch (RuntimeException e) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "cursor");
        }
    }

    static String encodeOf(CommunityPost lastPost) {
        String raw = lastPost.getLikeCount() + DELIMITER + lastPost.getCreatedAt() + DELIMITER + lastPost.getPostUuid();
        return Base64.getUrlEncoder().withoutPadding().encodeToString(raw.getBytes(StandardCharsets.UTF_8));
    }
}
