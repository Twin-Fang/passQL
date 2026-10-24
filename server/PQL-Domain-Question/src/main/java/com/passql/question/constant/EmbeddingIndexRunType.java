package com.passql.question.constant;

/**
 * 임베딩 색인 실행 종류 (embedding_index_run.run_type)
 */
public enum EmbeddingIndexRunType {
    ALL,           // 활성 문제 전체 재색인 + 남은 벡터 정리
    SELECTED,      // 선택한 문제만
    RETRY_FAILED   // 직전 실행의 실패 문제만
}
