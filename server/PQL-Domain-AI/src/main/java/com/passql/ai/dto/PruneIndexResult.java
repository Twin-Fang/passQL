package com.passql.ai.dto;

import java.util.List;

/**
 * 고아 벡터 정리 결과 DTO (#412).
 * Python AI 서버 POST /api/ai/prune-index 응답 매핑. 요청은 IndexStatusRequest(활성 문제 UUID 전체)를 재사용한다.
 */
public record PruneIndexResult(
        int deletedCount,           // 삭제한 Qdrant 포인트 수
        List<String> deletedUuids   // 삭제한 포인트 UUID 목록
) {}
