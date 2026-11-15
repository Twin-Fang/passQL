package com.passql.submission.dto;

import com.passql.submission.constant.MockExamSubject;
import io.swagger.v3.oas.annotations.media.Schema;

/** 예상 합격률 과목별 평균 (#1086): 최근 응시 평균 점수와 과락 위험 */
public record ExpectedPassSubjectAverage(
    MockExamSubject subject,
    String subjectName,
    @Schema(description = "최근 응시 과목 평균 점수 (소수 1자리)")
    double averageScore,
    @Schema(description = "과목 만점 (점)")
    int maxScore,
    @Schema(description = "과락 기준 점수 (점, 미만이면 과락)")
    int failBelowScore,
    @Schema(description = "과락 위험: 평균이 과락 기준 + 4점 이하")
    Boolean isFailRisk
) {}
