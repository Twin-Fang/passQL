package com.passql.application.statistics.dto;

import java.util.List;

/** 시간대별 접속: 0~23시 각 시간대 최근 7일 방문 회원 수 평균 (길이 24) */
public record DashboardHourlyVisitorResponse(
        List<Double> averageVisitorCounts
) {}
