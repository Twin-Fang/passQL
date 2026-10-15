package com.passql.question.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.question.entity.Question;

import java.util.Map;

/**
 * 문제 > 감사 로그 요약 (등록·수정·비활성화·복구 공통, 긴 본문은 앞부분만)
 */
public final class QuestionAuditSummary {

    private QuestionAuditSummary() {
    }

    public static Map<String, Object> of(Question question) {
        return AdminAuditEvent.summary(
                "stem", question.getStem(),
                "difficulty", question.getDifficulty(),
                "executionMode", question.getExecutionMode(),
                "topicUuid", question.getTopicUuid(),
                "subtopicUuid", question.getSubtopicUuid(),
                "hint", question.getHint(),
                "answerSql", question.getAnswerSql(),
                "isActive", question.getIsActive());
    }
}
