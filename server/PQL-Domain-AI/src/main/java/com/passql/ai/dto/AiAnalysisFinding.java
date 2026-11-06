package com.passql.ai.dto;

import com.passql.ai.constant.AiFindingKind;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.UUID;

/**
 * 통계 AI 분석 토픽 1건 (#861, #862): 서버 판정(kind·근거 수치) + LLM 한 문장(insight, 실패·근거 부족이면 null) + 개념 단원(열 수 있을 때만, 같은 토픽)
 * topicName 은 표시용 짧은 이름 ("조인 (JOIN)" > "조인")
 */
public record AiAnalysisFinding(
        UUID topicUuid,
        String topicName,
        AiFindingKind kind,
        int solvedCount,
        int correctRatePercent,
        String evidence,
        @Schema(nullable = true) String insight,
        @Schema(nullable = true) UUID conceptTopicUuid
) {
    /** LLM 한 문장 붙이기 (판정 수치는 그대로) */
    public AiAnalysisFinding withInsight(String newInsight) {
        return new AiAnalysisFinding(topicUuid, topicName, kind, solvedCount, correctRatePercent, evidence, newInsight,
                conceptTopicUuid);
    }
}
