package com.passql.application.oxquiz.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDate;

/** OX 답 기록 결과 (#1083): 갱신된 칸·다음 출제일·오늘 푼 수 */
public record OxAnswerResponse(
    String cardKey,
    @Schema(description = "갱신된 Leitner 칸 (1~5)")
    int box,
    @Schema(description = "다음 출제일 (KST)")
    LocalDate nextReviewDate,
    @Schema(description = "이 카드 연속 정답 수")
    int correctStreak,
    @Schema(description = "오늘(KST) 푼 카드 수")
    int todayAnsweredCount
) {}
