package com.passql.question.dto;

import java.util.List;
import java.util.UUID;

public record QuestionExportDto(
    UUID questionUuid,
    String topicCode,
    Integer difficulty,
    String executionMode,
    String choiceSetPolicy,
    String stem,
    String hint,
    String schemaDdl,
    String schemaSampleData,
    String schemaIntent,
    String answerSql,
    // 고정 보기 (CURATED_ONLY 필수, 옛 파일은 null, #511)
    List<CuratedChoiceDto> choices
) {}
