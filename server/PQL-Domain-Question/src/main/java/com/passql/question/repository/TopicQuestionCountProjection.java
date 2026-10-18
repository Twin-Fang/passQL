package com.passql.question.repository;

import java.util.UUID;

/**
 * 토픽별 문제 수 집계 행 (topicUuid, questionCount)
 */
public interface TopicQuestionCountProjection {
    UUID getTopicUuid();

    Long getQuestionCount();
}
