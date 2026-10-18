package com.passql.submission.dto;

import java.util.UUID;

/** 내가 푼 문제 한 건: 오답 제출이 한 번이라도 있으면 hasWrongSubmission = 1 */
public interface SolvedQuestionProjection {

    UUID getQuestionUuid();

    Integer getHasWrongSubmission();
}
