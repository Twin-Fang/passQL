package com.passql.submission.dto.mockexam;

import com.passql.submission.constant.MockExamRoundStatus;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 관리자 회차 목록 행: 문항 수, 응시·채점 수, 평균 점수, 합격률, 공개 검사 오류 수(점검 필요)
 */
public record AdminMockExamRoundRow(
    UUID roundUuid,
    int roundNumber,
    String title,
    MockExamRoundStatus status,
    long itemCount,
    long attemptCount,
    long submittedCount,
    Double averageScore,
    Integer passRatePercent,
    LocalDateTime publishedAt,
    int publishCheckErrorCount
) {
}
