package com.passql.question.dto;

import com.passql.question.constant.EmbeddingIndexRunType;

/**
 * 진행 중인 임베딩 색인의 현재 진행률 (서버 메모리 상태, 화면이 주기적으로 조회)
 * totalCount 0: 대상 문제를 모으는 중
 */
public record EmbeddingIndexProgress(
        Boolean isRunning,
        EmbeddingIndexRunType runType,
        int processedCount,
        int totalCount,
        int succeededCount,
        int failedCount
) {
    /** 진행 중인 실행 없음 */
    public static EmbeddingIndexProgress idle() {
        return new EmbeddingIndexProgress(false, null, 0, 0, 0, 0);
    }
}
