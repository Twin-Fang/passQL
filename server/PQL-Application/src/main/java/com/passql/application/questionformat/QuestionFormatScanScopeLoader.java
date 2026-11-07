package com.passql.application.questionformat;

import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import com.passql.question.repository.QuestionRepository;
import com.passql.submission.entity.MockExamRound;
import com.passql.submission.entity.MockExamRoundItem;
import com.passql.submission.repository.MockExamRoundItemRepository;
import com.passql.submission.repository.MockExamRoundRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 형식 점검 대상 읽기 (#905): 문제 > 모의고사 문항 위치 > 공유 세트(고정·재사용 + 모의고사 문항 세트) > 세트 보기
 * 호출부 트랜잭션 안에서 실행 (읽기 전용 점검·정리 적용 공통)
 */
@Component
@RequiredArgsConstructor
class QuestionFormatScanScopeLoader {

    // 세트 보기 조회 IN 절 한 번에 넣을 세트 수
    private static final int CHOICE_SET_UUID_CHUNK_SIZE = 500;

    private final QuestionRepository questionRepository;
    private final QuestionChoiceSetRepository choiceSetRepository;
    private final QuestionChoiceSetItemRepository choiceSetItemRepository;
    private final MockExamRoundRepository mockExamRoundRepository;
    private final MockExamRoundItemRepository mockExamRoundItemRepository;

    /** 활성 문제 전체 */
    QuestionFormatScanScope loadActiveQuestions() {
        return load(questionRepository.findByIsActiveTrue());
    }

    /** 지정 문제만 (정리 적용 대상) */
    QuestionFormatScanScope loadQuestions(Collection<UUID> questionUuids) {
        return load(questionRepository.findAllById(questionUuids));
    }

    private QuestionFormatScanScope load(List<Question> questions) {
        Set<UUID> questionUuids = questions.stream().map(Question::getQuestionUuid).collect(Collectors.toSet());
        List<MockExamRoundItem> mockExamItems = mockExamRoundItemRepository.findAll().stream()
                .filter(item -> questionUuids.contains(item.getQuestionUuid()))
                .toList();

        // 공유 세트: 고정·재사용 OK 세트 + 모의고사 문항이 고정한 세트 (상태 무관, 중복 제거)
        Map<UUID, QuestionChoiceSet> setByUuid = new LinkedHashMap<>();
        choiceSetRepository.findSharedSetsForFormatAudit(ChoiceSetStatus.OK, ChoiceSetSource.CURATED_SOURCES)
                .forEach(choiceSet -> setByUuid.put(choiceSet.getChoiceSetUuid(), choiceSet));
        choiceSetRepository.findAllById(mockExamItems.stream().map(MockExamRoundItem::getChoiceSetUuid).collect(Collectors.toSet()))
                .forEach(choiceSet -> setByUuid.put(choiceSet.getChoiceSetUuid(), choiceSet));
        Map<UUID, List<QuestionChoiceSet>> setsByQuestionUuid = setByUuid.values().stream()
                .filter(choiceSet -> questionUuids.contains(choiceSet.getQuestionUuid()))
                .collect(Collectors.groupingBy(QuestionChoiceSet::getQuestionUuid));

        Set<UUID> choiceSetUuids = new HashSet<>();
        setsByQuestionUuid.values().forEach(sets -> sets.forEach(choiceSet -> choiceSetUuids.add(choiceSet.getChoiceSetUuid())));
        return new QuestionFormatScanScope(questions, setsByQuestionUuid, loadItemsBySetUuid(choiceSetUuids),
                toMockExamLabels(mockExamItems));
    }

    private Map<UUID, List<QuestionChoiceSetItem>> loadItemsBySetUuid(Set<UUID> choiceSetUuids) {
        List<UUID> orderedUuids = new ArrayList<>(choiceSetUuids);
        List<QuestionChoiceSetItem> items = new ArrayList<>();
        for (int start = 0; start < orderedUuids.size(); start += CHOICE_SET_UUID_CHUNK_SIZE) {
            List<UUID> chunk = orderedUuids.subList(start, Math.min(start + CHOICE_SET_UUID_CHUNK_SIZE, orderedUuids.size()));
            items.addAll(choiceSetItemRepository.findByChoiceSetUuidInOrderBySortOrderAsc(chunk));
        }
        return items.stream().collect(Collectors.groupingBy(QuestionChoiceSetItem::getChoiceSetUuid));
    }

    // 문제 > "3회 13번, 5회 2번" (회차 번호순)
    private Map<UUID, String> toMockExamLabels(List<MockExamRoundItem> mockExamItems) {
        Map<UUID, Integer> roundNumberByUuid = mockExamRoundRepository.findAll().stream()
                .collect(Collectors.toMap(MockExamRound::getMockExamRoundUuid, MockExamRound::getRoundNumber));
        return mockExamItems.stream()
                .sorted(Comparator.comparing((MockExamRoundItem item) -> roundNumberByUuid.getOrDefault(item.getMockExamRoundUuid(), 0))
                        .thenComparing(MockExamRoundItem::getQuestionNumber))
                .collect(Collectors.groupingBy(MockExamRoundItem::getQuestionUuid, LinkedHashMap::new,
                        Collectors.mapping(item -> roundNumberByUuid.getOrDefault(item.getMockExamRoundUuid(), 0) + "회 "
                                + item.getQuestionNumber() + "번", Collectors.joining(", "))));
    }
}
