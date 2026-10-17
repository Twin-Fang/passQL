package com.passql.question.dto;

/**
 * 테이블 미리보기 컬럼: 이름, 타입(DDL 표기 그대로, 없으면 빈 문자열), 키 여부 2개(PK, FK)
 */
public record QuestionSchemaColumn(
    String name,
    String type,
    Boolean isPrimaryKey,
    Boolean isForeignKey
) {}
