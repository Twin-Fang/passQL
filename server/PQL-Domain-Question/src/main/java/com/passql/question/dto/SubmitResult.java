package com.passql.question.dto;

import com.passql.question.dto.explanation.ChoiceExplanation;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.UUID;

// EXECUTABLE 문제: selectedResult/correctResult/selectedSql/correctSql 포함
// CONCEPT_ONLY 문제: 위 4개 필드 null
// submissionUuid: 저장된 제출 UUID — 프론트 신고 기능에서 사용
// explanation: 고른 선택지의 미리 생성된 AI 해설 마크다운 (구조화 해설이 있으면 그것을 그린 글, 없으면 옛 보기별 해설, 둘 다 없으면 null) (#496, #521)
// structuredExplanation: 고른 보기 기준 구조화 해설 (세트 해설 저장본 있을 때만, 없으면 GET /api/ai/choice-explanation 으로 조회) (#521)
public record SubmitResult(
    boolean isCorrect,
    @Schema(nullable = true) String correctKey,
    @Schema(nullable = true) String rationale,
    @Schema(nullable = true) ExecuteResult selectedResult,
    @Schema(nullable = true) ExecuteResult correctResult,
    @Schema(nullable = true) String correctSql,
    @Schema(nullable = true) String selectedSql,
    @Schema(nullable = true) UUID submissionUuid,
    @Schema(nullable = true) String explanation,
    @Schema(nullable = true) ChoiceExplanation structuredExplanation
) {}
