package com.passql.question.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/**
 * 문제 화면 테이블 미리보기 1개: 테이블 이름, 컬럼(DDL 순서), 샘플 행(INSERT 순서)
 * 원본: question.schemaDdl + schemaSampleData > SchemaPreviewParser (#520)
 */
public record QuestionSchemaTable(
    String tableName,
    List<QuestionSchemaColumn> columns,
    @Schema(description = "샘플 행 목록. 행마다 columns 순서의 셀 값(문자열), SQL NULL 이면 null")
    List<List<Object>> sampleRows
) {}
