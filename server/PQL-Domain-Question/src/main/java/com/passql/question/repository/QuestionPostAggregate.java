package com.passql.question.repository;

import java.time.LocalDateTime;
import java.util.UUID;

/** 문제별 노출 글 집계 한 행: 글 수, 좋아요 합, 가장 최근 글 시각 */
public interface QuestionPostAggregate {

    UUID getQuestionUuid();

    long getPostCount();

    long getLikeCount();

    LocalDateTime getLastPostedAt();
}
