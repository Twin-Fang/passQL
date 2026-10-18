package com.passql.question.dto;

import java.util.List;
import java.util.UUID;

/**
 * 관리자 최신 경향 일괄 지정 요청: 문제 UUID 목록 + 지정(true)·해제(false) (#523)
 */
public record AdminLatestTrendUpdateRequest(
    List<UUID> questionUuids,
    Boolean isLatestTrend
) {}
