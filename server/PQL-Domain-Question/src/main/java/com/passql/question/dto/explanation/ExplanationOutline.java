package com.passql.question.dto.explanation;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/**
 * 무료 응답의 잠긴 상세 해설 구성 (#999): 앱이 실제와 같은 모양으로 흐리게 그리는 재료
 * 진짜 글은 넣지 않음 (섹션 종류·항목 수·대략 글자 수만)
 */
public record ExplanationOutline(
    @Schema(description = "보기 개수") int choiceCount,
    @Schema(description = "섹션 목록 (화면 배치 순서)") List<ExplanationOutlineSection> sections
) {

    public ExplanationOutline {
        sections = sections == null ? List.of() : List.copyOf(sections);
    }
}
