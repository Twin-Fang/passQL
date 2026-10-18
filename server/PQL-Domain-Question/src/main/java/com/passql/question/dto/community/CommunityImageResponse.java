package com.passql.question.dto.community;

import java.util.UUID;

/** 글에 붙은 이미지 1장: url 은 서버 스트리밍 경로 (인증 필요, 버킷 직접 노출 없음) */
public record CommunityImageResponse(
        UUID imageUuid,
        String url,
        String thumbnailUrl,
        Integer width,
        Integer height
) {
}
