package com.passql.application.statistics.dto;

import java.time.LocalDateTime;

/**
 * 대시보드 지금·오늘 KPI (30초 갱신): 온라인, 방문, 가입, 제출, AI 호출, 토론
 * 방문 비교 기준: 어제 00:00 ~ 어제 같은 시각, 7일 평균 가입: 어제까지 7일 / 7
 */
public record DashboardRealtimeResponse(
        long onlineMemberCount,
        long todayVisitorCount,
        long yesterdaySameTimeVisitorCount,
        long todaySignupCount,
        long yesterdaySignupCount,
        double sevenDayAverageSignupCount,
        long todaySubmissionCount,
        double todayCorrectRatePercent,
        long todayAiCallCount,
        long todayAiFailureCount,
        long todayAiAverageLatencyMilliseconds,
        long todayCommunityPostCount,
        long pendingCommunityReportCount,
        LocalDateTime generatedAt
) {}
