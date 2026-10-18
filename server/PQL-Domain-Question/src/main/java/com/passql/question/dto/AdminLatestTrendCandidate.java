package com.passql.question.dto;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 관리자 최신 경향 지정 후보 1건 (CURATED_ONLY + 고정 OK 세트 보유 활성 문제, #523)
 * schemaIntent 로 경향 양산 원본(문제 YAML intent)과 대조
 */
public record AdminLatestTrendCandidate(
    UUID questionUuid,
    String topicCode,
    Integer difficulty,
    String schemaIntent,
    String stemPreview,
    LocalDateTime createdAt,
    Boolean isLatestTrend
) {}
