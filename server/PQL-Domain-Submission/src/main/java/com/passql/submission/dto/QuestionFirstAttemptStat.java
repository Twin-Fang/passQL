package com.passql.submission.dto;

import java.util.UUID;

/**
 * 문제 1개의 첫 제출 집계 (#1080): 회원별 첫 제출만 셈
 * attemptCount: 첫 제출 회원 수, wrongCount: 그중 첫 제출이 오답인 회원 수
 */
public record QuestionFirstAttemptStat(
    UUID questionUuid,
    String topicName,
    String topicCode,
    int attemptCount,
    int wrongCount
) {}
