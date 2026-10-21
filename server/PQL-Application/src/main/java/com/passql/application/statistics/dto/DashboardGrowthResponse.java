package com.passql.application.statistics.dto;

import java.util.List;

/**
 * 가입·방문자 추이 (일 30 / 월 12): 배열 길이 = labels 길이, 빈 묶음 0
 * cumulativeMemberCounts: 묶음 끝까지 가입해 지금 남아 있는 회원 수 (대시보드 전체 회원 수와 같은 기준)
 */
public record DashboardGrowthResponse(
        List<String> labels,
        List<Long> signupCounts,
        List<Long> visitorCounts,
        List<Long> cumulativeMemberCounts
) {}
