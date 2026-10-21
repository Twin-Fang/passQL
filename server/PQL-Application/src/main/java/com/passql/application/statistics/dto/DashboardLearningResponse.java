package com.passql.application.statistics.dto;

import java.util.List;

/** 학습 활동 30일: 일별 제출 수·정답률(%, 제출 없는 날 0) */
public record DashboardLearningResponse(
        List<String> labels,
        List<Long> submissionCounts,
        List<Double> correctRatePercents
) {}
