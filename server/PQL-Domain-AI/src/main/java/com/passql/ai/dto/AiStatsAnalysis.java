package com.passql.ai.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/**
 * 통계 화면 AI 분석 (#861, #862): 요약 > 예상 점수(근거 부족이면 forecastHint) > 집중 토픽 최대 2개 > 반복 오답 > 추세 > 강점 > 다음 목표 > 버튼 최대 2개
 * 판정·문구는 서버 규칙(AiAnalysisPlanner), LLM 은 findings[].insight 한 문장만. 데이터 부족이면 readiness 만
 */
public record AiStatsAnalysis(
        String headline,
        List<AiAnalysisFinding> findings,
        @Schema(nullable = true) String trend,
        @Schema(nullable = true) AiAnalysisStrength strength,
        List<AiAnalysisAction> actions,
        // 판정 기간 표기 (예: "최근 90일 기준", 통계 토픽 표 7일과 구분)
        String periodLabel,
        @Schema(nullable = true) AiExamForecast forecast,
        @Schema(nullable = true) String forecastHint,
        @Schema(nullable = true) AiRepeatedWrong repeatedWrong,
        @Schema(nullable = true) AiAnalysisReadiness readiness,
        @Schema(nullable = true) String nextGoal
) {
    /** 집중 토픽만 바꾼 사본 (LLM 한 문장 붙일 때) */
    public AiStatsAnalysis withFindings(List<AiAnalysisFinding> newFindings) {
        return new AiStatsAnalysis(headline, newFindings, trend, strength, actions, periodLabel, forecast,
                forecastHint, repeatedWrong, readiness, nextGoal);
    }
}
