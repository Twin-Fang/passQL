package com.passql.question.repository;

import java.util.UUID;

/**
 * 서브토픽별 문제 수 집계 행 (subtopicUuid, questionCount)
 */
public interface SubtopicQuestionCountProjection {
    UUID getSubtopicUuid();

    Long getQuestionCount();
}
