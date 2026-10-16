package com.passql.question.dto;

/**
 * 관리자 고정 보기 1개 (가져오기·내보내기·고정 세트 저장 공통, #511)
 * kind: SQL(SQL 문 보기) 또는 TEXT(설명·결과값 보기), 비우면 TEXT
 */
public record CuratedChoiceDto(
        String choiceKey,
        String kind,
        String body,
        Boolean isCorrect,
        String rationale
) {}
