package com.passql.question.dto;

import com.passql.question.dto.explanation.ChoiceExplanation;
import com.passql.question.dto.explanation.ExplanationOutline;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;
import java.util.UUID;

// EXECUTABLE 문제: selectedResult/correctResult/selectedSql/correctSql 포함
// CONCEPT_ONLY 문제: 위 4개 필드 null
// submissionUuid: 저장된 제출 UUID — 프론트 신고 기능에서 사용
// explanation: 고른 선택지의 미리 생성된 AI 해설 마크다운 (구조화 해설이 있으면 그것을 그린 글, 없으면 옛 보기별 해설, 둘 다 없으면 null) (#496, #521)
// structuredExplanation: 고른 보기 기준 구조화 해설 (세트 해설 저장본 있을 때만, 없으면 GET /api/ai/choice-explanation 으로 조회) (#521)
// lockedSections: 무료 회원 응답에서 뺀 묶음 이름 목록 (EXECUTION_RESULT, FULL_EXPLANATION), 뺀 게 없으면 빈 목록 (#576)
// basicExplanation·lockedExplanationOutline: FULL_EXPLANATION 잠긴 응답에만 (정답 보기 저장 근거, 상세 해설 구성), 그 외 null (#999)
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
    @Schema(nullable = true) ChoiceExplanation structuredExplanation,
    @Schema(description = "무료 회원 응답에서 뺀 묶음 이름 (EXECUTION_RESULT, FULL_EXPLANATION), 없으면 빈 목록") List<String> lockedSections,
    @Schema(nullable = true, description = "무료 기본 해설: 정답 보기에 저장된 근거 (FULL_EXPLANATION 잠긴 응답만)") String basicExplanation,
    @Schema(nullable = true, description = "잠긴 상세 해설 구성: 섹션 종류·대략 글자 수만 (FULL_EXPLANATION 잠긴 응답만)") ExplanationOutline lockedExplanationOutline
) {

    public SubmitResult {
        lockedSections = lockedSections == null ? List.of() : List.copyOf(lockedSections);
    }

    /** 잠긴 묶음 없는 응답 (판정 단계에서 만들 때) */
    public SubmitResult(boolean isCorrect, String correctKey, String rationale, ExecuteResult selectedResult,
                        ExecuteResult correctResult, String correctSql, String selectedSql, UUID submissionUuid,
                        String explanation, ChoiceExplanation structuredExplanation) {
        this(isCorrect, correctKey, rationale, selectedResult, correctResult, correctSql, selectedSql,
            submissionUuid, explanation, structuredExplanation, List.of(), null, null);
    }
}
