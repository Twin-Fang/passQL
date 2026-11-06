package com.passql.ai.dto;

import java.util.UUID;

/** 통계 AI 분석 강점 토픽 (#861): 10문제 이상·정답률 85% 이상 중 가장 높은 토픽, topicName 은 짧은 이름 */
public record AiAnalysisStrength(UUID topicUuid, String topicName, int correctRatePercent) {}
