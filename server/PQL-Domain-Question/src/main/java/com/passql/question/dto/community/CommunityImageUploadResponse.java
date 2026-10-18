package com.passql.question.dto.community;

import java.util.UUID;

/** 업로드 결과: imageUuid 를 글 작성 요청의 imageUuids 에 담는다, objectKey 는 서버 저장 키 (community/tmp/ 는 24시간 안에 글에 붙이지 않으면 삭제) */
public record CommunityImageUploadResponse(
        UUID imageUuid,
        String objectKey,
        String url,
        String thumbnailUrl,
        Integer width,
        Integer height
) {
}
