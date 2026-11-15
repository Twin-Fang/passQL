package com.passql.question.repository;

/**
 * 태그별 문제 수 집계 행 (전체 문제·활성 문제)
 */
public interface QuestionInternalTagCountProjection {

    String getTag();

    Long getQuestionCount();

    Long getActiveQuestionCount();
}
