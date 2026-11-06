package com.passql.submission.dto.mockexam;

import com.passql.question.constant.ChoiceKind;
import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 시험지 보기 1개 (풀이 중 isCorrect·rationale 은 null, 해설에서만 채움)
 */
public record MockExamChoice(
    String key,
    ChoiceKind kind,
    String body,
    @Schema(nullable = true) Boolean isCorrect,
    @Schema(nullable = true) String rationale
) {
}
