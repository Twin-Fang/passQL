package com.passql.question.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record DailySetTodayResponse(
    List<QuestionSummary> questions,
    Boolean alreadyCompleted,
    @Schema(nullable = true) Integer correctCount,
    // 이미 완료한 세트를 다시 열 때 문제별 정답 여부(questions 순서와 같음). 미완료면 null (#372)
    @Schema(nullable = true) List<Boolean> results,
    // 풀다 만 세트의 문제별 오늘 첫 제출 정답 여부(questions 순서, 미제출 null). 완료했거나 비로그인이면 null — 이어 풀기용 (#566)
    @Schema(nullable = true) List<Boolean> answeredResults
) {}
