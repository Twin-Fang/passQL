package com.passql.submission.dto;

import java.util.UUID;

/** 즐겨찾기 추가·해제 결과 (#1082): 요청 뒤 상태 */
public record QuestionBookmarkStatusResponse(
    UUID questionUuid,
    Boolean isBookmarked
) {}
