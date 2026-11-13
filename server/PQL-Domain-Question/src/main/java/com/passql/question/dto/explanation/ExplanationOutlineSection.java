package com.passql.question.dto.explanation;

import com.passql.question.constant.ExplanationOutlineSectionKind;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/** 잠긴 상세 해설 섹션 1개의 모양: 종류 + 항목별 대략 글자 수 (본문 없음, #999) */
public record ExplanationOutlineSection(
    @Schema(description = "섹션 종류") ExplanationOutlineSectionKind kind,
    @Schema(description = "항목별 대략 글자 수 (10자 단위 올림, 항목 수 = 목록 길이)") List<Integer> itemCharacterCounts
) {

    public ExplanationOutlineSection {
        itemCharacterCounts = itemCharacterCounts == null ? List.of() : List.copyOf(itemCharacterCounts);
    }
}
