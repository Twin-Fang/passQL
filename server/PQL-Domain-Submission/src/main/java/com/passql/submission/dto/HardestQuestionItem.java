package com.passql.submission.dto;

import com.passql.submission.constant.MockExamSubject;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.UUID;

/** 오답률 TOP 항목 (#1080) */
public record HardestQuestionItem(
    @Schema(description = "순위 (1부터)")
    int rank,
    UUID questionUuid,
    String stemPreview,
    @Schema(nullable = true) String topicName,
    MockExamSubject subject,
    @Schema(description = "첫 제출 오답률 (%, 소수 1자리)")
    double wrongRatePercent,
    @Schema(description = "첫 제출 회원 수")
    int attemptCount
) {}
