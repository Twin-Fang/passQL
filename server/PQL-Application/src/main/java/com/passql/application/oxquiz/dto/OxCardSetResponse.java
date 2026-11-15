package com.passql.application.oxquiz.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/** OX 카드 묶음 (#1083): 기한 지난 복습 카드 먼저 > 새 카드, 오늘 진행 함께 */
public record OxCardSetResponse(
    List<OxCardItem> cards,
    @Schema(description = "지금 복습할 카드 전체 수 (이번 묶음 밖 포함)")
    int dueCardCount,
    @Schema(description = "아직 안 푼 카드 전체 수 (이번 묶음 밖 포함)")
    int newCardCount,
    @Schema(description = "오늘(KST) 푼 카드 수 (같은 카드 여러 번은 1장)")
    int todayAnsweredCount,
    @Schema(description = "오늘 목표 장 수")
    int dailyGoalCount,
    @Schema(description = "잠긴 단원(무료 회원)에 카드가 더 있을 수 있음")
    Boolean hasLockedTopics
) {}
