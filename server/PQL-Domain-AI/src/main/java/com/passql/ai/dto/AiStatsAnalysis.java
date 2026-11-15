package com.passql.ai.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/**
 * 통계 화면 AI 분석 (#861, #862): 요약 > 예상 점수(근거 부족이면 forecastHint) > 점수 올리기 좋은 영역(#1111) > 집중 토픽 최대 2개 > 반복 오답 > 추세 > 강점 > 다음 목표 > 버튼 최대 2개
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
        @Schema(nullable = true) String nextGoal,
        // 점수 올리기 좋은 영역 최대 3개, 기대 상승 점수 큰 순 (#1111, 근거 부족·오를 점수 없으면 빈 목록)
        List<AiScoreGainTopic> scoreGainTopics
) {
    /** 이 필드가 없던 캐시(Redis 통계 분석) 읽기 > 빈 목록 */
    public AiStatsAnalysis {
        scoreGainTopics = scoreGainTopics == null ? List.of() : scoreGainTopics;
    }

    /** 집중 토픽만 바꾼 사본 (LLM 한 문장 붙일 때) */
    public AiStatsAnalysis withFindings(List<AiAnalysisFinding> newFindings) {
        return new AiStatsAnalysis(headline, newFindings, trend, strength, actions, periodLabel, forecast,
                forecastHint, repeatedWrong, readiness, nextGoal, scoreGainTopics);
    }
}
