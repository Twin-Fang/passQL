package com.passql.ai.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDateTime;

/**
 * AI 코멘트 응답: comment 는 구버전 앱 호환 평문, analysis 는 통계 화면 구조화 분석 (결과 화면은 null, #861)
 */
public record AiCommentResponse(
        String comment,
        @Schema(nullable = true) LocalDateTime generatedAt,
        @Schema(nullable = true) AiStatsAnalysis analysis
) {
    /** 결과 화면 코멘트 (구조화 분석 없음) */
    public AiCommentResponse(String comment, LocalDateTime generatedAt) {
        this(comment, generatedAt, null);
    }
}
