package com.passql.submission.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.List;

/** 오답률 TOP 목록 (#1080): 1시간마다 다시 집계 */
public record HardestQuestionsResponse(
    List<HardestQuestionItem> items,
    @Schema(description = "집계 기준 시각 (서버 KST)")
    LocalDateTime aggregatedAt,
    @Schema(description = "목록에 넣는 최소 첫 제출 회원 수")
    int minimumAttemptCount
) {}
