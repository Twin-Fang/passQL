package com.passql.application.statistics.dto;

/**
 * 구간 AI 사용 합계: 호출·실패 건수, 추정 비용(USD, 단가 미등록 모델은 0)
 */
public record AiUsageTotal(long callCount, long failureCount, double estimatedCostUsd) {}
