package com.passql.question.dto;

import java.util.List;
import java.util.UUID;

/**
 * 관리자 최신 경향 일괄 지정 결과: 요청 수, 값이 바뀐 수, 없는 UUID (#523)
 */
public record AdminLatestTrendUpdateResult(
    Integer requestedCount,
    Integer changedCount,
    List<UUID> notFoundQuestionUuids
) {}
