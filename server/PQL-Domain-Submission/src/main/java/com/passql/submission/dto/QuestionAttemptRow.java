package com.passql.submission.dto;

import java.time.LocalDateTime;
import java.util.UUID;

/** 정답률 상세 계산용 제출 한 건: 문제, 정답 여부, 시각, 문제 난이도·활성 여부 */
public record QuestionAttemptRow(
    UUID questionUuid,
    Boolean isCorrect,
    LocalDateTime submittedAt,
    int difficulty,
    Boolean isQuestionActive
) {}
