package com.passql.ai.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/**
 * 통계 화면 AI 분석 (#861): 한 줄 요약 > 집중 토픽 최대 2개 > 주간 추세 > 강점 > 바로 풀기 버튼 최대 2개
 * 판정·문구는 서버 규칙(AiAnalysisPlanner), LLM 은 findings[].insight 한 문장만
 */
public record AiStatsAnalysis(
        String headline,
        List<AiAnalysisFinding> findings,
        @Schema(nullable = true) String trend,
        @Schema(nullable = true) AiAnalysisStrength strength,
        List<AiAnalysisAction> actions
) {}
