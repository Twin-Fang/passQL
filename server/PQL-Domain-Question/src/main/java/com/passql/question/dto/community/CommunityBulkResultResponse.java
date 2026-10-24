package com.passql.question.dto.community;

/** 글 일괄 처리 결과: 처리 건수, 건너뛴 건수(없거나 이미 삭제·처리 불가 상태) */
public record CommunityBulkResultResponse(int succeededCount, int skippedCount) {
}
