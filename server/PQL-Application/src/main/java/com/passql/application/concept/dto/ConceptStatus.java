package com.passql.application.concept.dto;

/**
 * 개념 상태 3가지: 안 함, 읽음(확인 문제 미완료), 풀이 완료(확인 문제 전부 풂, 읽음 여부 무관)
 */
public enum ConceptStatus {

    NOT_STARTED,
    READ,
    SOLVED
}
