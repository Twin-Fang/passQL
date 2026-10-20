package com.passql.application.statistics.dto;

/** 모델 1개 사용량·추정 비용 (modelName 미기록 호출은 "미기록", 단가 미등록이면 비용 0 + isPriceRegistered false) */
public record AiModelUsageSummary(
        String modelName,
        long callCount,
        long failureCount,
        long promptTokenCount,
        long completionTokenCount,
        double estimatedCostUsd,
        Boolean isPriceRegistered
) {}
