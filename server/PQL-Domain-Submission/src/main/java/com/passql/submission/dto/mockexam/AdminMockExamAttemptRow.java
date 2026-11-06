package com.passql.submission.dto.mockexam;

import com.passql.submission.constant.MockExamAttemptStatus;
import com.passql.submission.constant.MockExamFailReason;
import com.passql.submission.constant.MockExamSubmitReason;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 관리자 응시 기록 행
 */
public record AdminMockExamAttemptRow(
    UUID attemptUuid,
    UUID memberUuid,
    String memberNickname,
    UUID roundUuid,
    int roundNumber,
    MockExamAttemptStatus status,
    LocalDateTime startedAt,
    LocalDateTime submittedAt,
    MockExamSubmitReason submitReason,
    Integer totalScore,
    Integer subjectOneScore,
    Integer subjectTwoScore,
    Boolean isPassed,
    MockExamFailReason failReason
) {
}
