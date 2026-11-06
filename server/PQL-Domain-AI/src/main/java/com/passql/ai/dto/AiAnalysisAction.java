package com.passql.ai.dto;

import com.passql.ai.constant.AiAnalysisActionType;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.UUID;

/**
 * 통계 AI 분석 바로 풀기 버튼 (#861): 문구(label)는 서버가 만듦
 * topicUuid·topicName 은 PRACTICE_TOPIC 만, count 는 표시용 문제 수 (화면이 개수를 못 받으면 문구에만 씀)
 */
public record AiAnalysisAction(
        AiAnalysisActionType type,
        @Schema(nullable = true) UUID topicUuid,
        @Schema(nullable = true) String topicName,
        int count,
        String label
) {}
