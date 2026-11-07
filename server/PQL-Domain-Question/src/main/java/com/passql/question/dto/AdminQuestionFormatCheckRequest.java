package com.passql.question.dto;

import java.util.List;
import java.util.UUID;

/**
 * 관리자 저장 전 형식 검사 요청 (#905): 편집이면 questionUuid (저장본에 이미 있던 사유는 막지 않음), 새 문항이면 null
 * executionMode: EXECUTABLE·CONCEPT_ONLY 문자열, choices: AI 생성 검수 저장의 보기 (없으면 null)
 */
public record AdminQuestionFormatCheckRequest(
        UUID questionUuid,
        String stem,
        String hint,
        String schemaDdl,
        String schemaSampleData,
        String executionMode,
        List<CuratedChoiceDto> choices
) {
}
