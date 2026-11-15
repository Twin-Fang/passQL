package com.passql.submission.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/**
 * 예상 합격률 (#1086): 최근 채점된 모의고사 최대 5회 기준 + 공식 최근 연도 합격률 비교
 * 응시 0회면 expectedPassPercent·averageScore null, subjectAverages 빈 목록
 */
public record ExpectedPassResponse(
    @Schema(nullable = true, description = "최근 응시 중 합격 비율 (%, 정수), 응시 0회면 null")
    Integer expectedPassPercent,
    @Schema(nullable = true, description = "최근 응시 평균 총점 (소수 1자리), 응시 0회면 null")
    Double averageScore,
    @Schema(description = "계산에 쓴 응시 수 (최대 5)")
    int basisAttemptCount,
    @Schema(description = "그중 합격 응시 수")
    int passedAttemptCount,
    @Schema(description = "합격 총점 (점, 이상)")
    int passScore,
    List<ExpectedPassSubjectAverage> subjectAverages,
    @Schema(nullable = true, description = "공식 최근 연도 합격률 (%), 통계 없으면 null")
    Double officialPassRatePercent,
    @Schema(nullable = true, description = "공식 합격률 연도, 통계 없으면 null")
    Integer officialStatisticYear
) {}
