package com.passql.submission.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record WrongQuestionsResponse(
    List<WrongQuestionItem> items,
    @Schema(description = "필터(과목·정리됨 포함 여부)를 적용한 전체 오답 문제 수 (size 제한 전)")
    long totalCount
) {}
