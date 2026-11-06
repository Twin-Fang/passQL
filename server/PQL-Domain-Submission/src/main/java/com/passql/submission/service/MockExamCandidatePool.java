package com.passql.submission.service;

import com.passql.meta.entity.Topic;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/**
 * 자동 구성·문항 교체 후보 묶음: 활성 토픽(정렬순), 출제할 세트(문제별 1개), 문제, 최근 회차 사용 문제
 */
public record MockExamCandidatePool(
    List<Topic> topics,
    Map<UUID, QuestionChoiceSet> preferredSetByQuestion,
    Map<UUID, Question> questionByUuid,
    Set<UUID> recentlyUsedQuestionUuids
) {

    /** 토픽의 후보 (출제 가능 + 제외 목록 밖) */
    public List<MockExamQuestionPicker.Candidate> candidatesOf(UUID topicUuid, Set<UUID> excludedQuestionUuids) {
        return questionByUuid.values().stream()
            .filter(question -> question.getTopicUuid().equals(topicUuid))
            .filter(question -> !excludedQuestionUuids.contains(question.getQuestionUuid()))
            .map(question -> new MockExamQuestionPicker.Candidate(question.getQuestionUuid(),
                question.getDifficulty() != null ? question.getDifficulty() : 0,
                recentlyUsedQuestionUuids.contains(question.getQuestionUuid())))
            .toList();
    }
}
