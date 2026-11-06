package com.passql.submission.service;

import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.repository.QuestionChoiceSetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 모의고사 출제 가능 세트 조회: 기준은 QuestionChoiceSetRepository.MOCK_EXAM_ELIGIBLE_SET_QUERY 한 곳
 * 문제별 세트 고르기: 관리자 고정 출처 > 최신
 */
@Component
@RequiredArgsConstructor
public class MockExamEligibleSetFinder {

    // 관리자 고정 출처 우선, 그다음 최신
    private static final Comparator<QuestionChoiceSet> PREFERRED_SET_ORDER = Comparator
        .comparing((QuestionChoiceSet choiceSet) -> choiceSet.getSource().isCurated()).reversed()
        .thenComparing(QuestionChoiceSet::getCreatedAt, Comparator.nullsLast(Comparator.reverseOrder()));

    private final QuestionChoiceSetRepository choiceSetRepository;

    /** 문제 UUID > 출제할 세트 1개 (출제 가능 세트가 있는 활성 문제만) */
    public Map<UUID, QuestionChoiceSet> findPreferredSetByQuestion() {
        Map<UUID, QuestionChoiceSet> preferredSetByQuestion = new HashMap<>();
        choiceSetRepository.findMockExamEligibleSets(ChoiceSetStatus.OK, ExecutionMode.CONCEPT_ONLY,
                ChoiceSetSource.CURATED_SOURCES, MockExamRule.CHOICE_COUNT_PER_QUESTION)
            .forEach(choiceSet -> preferredSetByQuestion.merge(choiceSet.getQuestionUuid(), choiceSet,
                (current, candidate) -> PREFERRED_SET_ORDER.compare(current, candidate) <= 0 ? current : candidate));
        return preferredSetByQuestion;
    }

    /** 주어진 세트 중 지금도 출제 가능한 세트 UUID */
    public Set<UUID> findEligibleSetUuidsAmong(Collection<UUID> choiceSetUuids) {
        if (choiceSetUuids.isEmpty()) {
            return Set.of();
        }
        return choiceSetRepository.findMockExamEligibleSetsAmong(ChoiceSetStatus.OK, ExecutionMode.CONCEPT_ONLY,
                ChoiceSetSource.CURATED_SOURCES, MockExamRule.CHOICE_COUNT_PER_QUESTION, choiceSetUuids)
            .stream()
            .map(QuestionChoiceSet::getChoiceSetUuid)
            .collect(Collectors.toSet());
    }
}
