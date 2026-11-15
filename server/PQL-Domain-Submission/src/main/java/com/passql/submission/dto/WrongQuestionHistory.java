package com.passql.submission.dto;

import com.passql.submission.constant.MockExamSubject;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 회원 1명의 문제별 오답 이력 (오답 노트 조회 원재료, #1081)
 * isLatestSubmissionCorrect: 그 문제 최신 제출의 정답 여부
 */
public record WrongQuestionHistory(
    UUID questionUuid,
    String stem,
    String topicName,
    String topicCode,
    int wrongCount,
    LocalDateTime lastWrongAt,
    boolean isLatestSubmissionCorrect
) {

    /** 정리됨: 최신 제출이 정답 (다시 맞힌 문제) */
    public boolean isResolved() {
        return isLatestSubmissionCorrect;
    }

    /** 토픽 코드 > 과목 */
    public MockExamSubject subject() {
        return MockExamSubject.fromTopicCode(topicCode);
    }
}
