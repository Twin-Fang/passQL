package com.passql.question.constant;

/**
 * 임베딩 색인 실행 상태 (embedding_index_run.status)
 */
public enum EmbeddingIndexRunStatus {
    RUNNING,    // 진행 중
    COMPLETED,  // 끝까지 실행 (개별 문제 실패는 failedCount 로 구분)
    FAILED      // 실행 자체가 중단 (예외, 서버 재시작)
}
