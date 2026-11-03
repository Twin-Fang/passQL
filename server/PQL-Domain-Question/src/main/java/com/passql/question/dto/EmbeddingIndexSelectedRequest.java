package com.passql.question.dto;

import java.util.List;

/**
 * 관리자 선택 재색인 요청: 문제 UUID 문자열 목록 (비었으면 EMBEDDING_INDEX_TARGET_EMPTY)
 */
public record EmbeddingIndexSelectedRequest(
    List<String> uuids
) {
    public boolean hasTargets() {
        return uuids != null && !uuids.isEmpty();
    }
}
