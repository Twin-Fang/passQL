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
    List<CuratedChoiceDto> choices,
    // 내부 관리 태그 (관리자 전용, #1117): 칸 없는 옛 파일 > null (신규는 태그 없음, 갱신은 기존 태그 유지), [] > 전부 제거
    List<String> internalTags
) {}
