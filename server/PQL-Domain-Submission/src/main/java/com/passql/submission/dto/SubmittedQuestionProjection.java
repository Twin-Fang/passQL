package com.passql.submission.dto;

import java.time.LocalDateTime;
import java.util.UUID;

/** 제출 한 건의 문제·제출 시각 (날짜별 서로 다른 문제 수 계산용) */
public record SubmittedQuestionProjection(
    UUID questionUuid,
    LocalDateTime submittedAt
) {}
