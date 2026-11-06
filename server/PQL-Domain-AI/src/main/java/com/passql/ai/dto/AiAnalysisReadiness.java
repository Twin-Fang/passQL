package com.passql.ai.dto;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 데이터 부족 안내 (#862): 판단 가능한 토픽(5문제 이상)이 하나도 없을 때만
 * 진행 대상은 가장 많이 푼 토픽 (없으면 첫 토픽), solvedCount / targetCount 로 "지금 N/5" 표시
 */
public record AiAnalysisReadiness(
        String message,
        @Schema(nullable = true) String topicName,
        int solvedCount,
        int targetCount
) {}
