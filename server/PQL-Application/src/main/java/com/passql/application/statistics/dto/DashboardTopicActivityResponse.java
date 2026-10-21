package com.passql.application.statistics.dto;

/** 토픽 1개: 활성 문제 수 + 최근 30일 풀이(제출) 수 */
public record DashboardTopicActivityResponse(
        String topicName,
        long questionCount,
        long submissionCount30Days
) {}
