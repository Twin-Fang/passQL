package com.passql.ai.dto;

import com.passql.ai.constant.AiFindingKind;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.UUID;

/**
 * 통계 AI 분석 토픽 1건 (#861): 서버 판정(kind·근거 수치) + LLM 한 문장(insight)
 * topicName 은 표시용 짧은 이름 ("조인 (JOIN)" > "조인"), insight 는 LLM 실패·근거 부족이면 null
 */
public record AiAnalysisFinding(
        UUID topicUuid,
        String topicName,
        AiFindingKind kind,
        int solvedCount,
        int correctRatePercent,
        String evidence,
        @Schema(nullable = true) String insight
) {
    /** LLM 한 문장 붙이기 (판정 수치는 그대로) */
    public AiAnalysisFinding withInsight(String newInsight) {
        return new AiAnalysisFinding(topicUuid, topicName, kind, solvedCount, correctRatePercent, evidence, newInsight);
    }
}
