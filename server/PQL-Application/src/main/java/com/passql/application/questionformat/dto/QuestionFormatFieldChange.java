package com.passql.application.questionformat.dto;

/**
 * 자동 정리 미리보기 필드 1개 (#905): 필드 이름(지문·스키마 DDL·보기 B 근거 등), 바꾸기 전·후 전문
 */
public record QuestionFormatFieldChange(String fieldName, String before, String after) {
}
