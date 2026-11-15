package com.passql.question.dto;

/**
 * 관리자 목록 내부 태그 필터 1개: 정확 일치(source:63-17) 또는 앞부분 일치(source:63-*, source:*)
 * matchValue: 정확 일치면 태그 전체, 앞부분 일치면 끝 * 를 뗀 앞부분
 */
public record QuestionInternalTagFilter(
        String matchValue,
        boolean isPrefixMatch
) {}
