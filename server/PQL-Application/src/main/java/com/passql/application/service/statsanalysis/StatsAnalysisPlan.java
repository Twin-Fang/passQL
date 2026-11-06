package com.passql.application.service.statsanalysis;

import com.passql.ai.dto.AiStatsAnalysis;

import java.util.List;

/** 판정 결과: 화면용 분석(insight 비어 있음) + LLM 에 넘길 집중 토픽 (비면 LLM 호출 없음) */
public record StatsAnalysisPlan(AiStatsAnalysis analysis, List<TopicLearningStat> focusTopics) {

    public boolean hasFocusTopics() {
        return !focusTopics.isEmpty();
    }
}
