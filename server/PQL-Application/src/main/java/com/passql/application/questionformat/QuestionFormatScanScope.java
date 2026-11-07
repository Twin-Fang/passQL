package com.passql.application.questionformat;

import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 형식 점검 대상 묶음 (#905): 활성 문제 + 공유 세트(고정·재사용·모의고사 문항 세트) + 세트 보기 + 모의고사 위치 표시
 * 회원별 일회성 AI 세트는 다시 보이지 않아 제외
 */
record QuestionFormatScanScope(
        List<Question> questions,
        Map<UUID, List<QuestionChoiceSet>> setsByQuestionUuid,
        Map<UUID, List<QuestionChoiceSetItem>> itemsBySetUuid,
        Map<UUID, String> mockExamLabelByQuestionUuid
) {

    List<QuestionChoiceSet> setsOf(UUID questionUuid) {
        return setsByQuestionUuid.getOrDefault(questionUuid, List.of());
    }

    List<QuestionChoiceSetItem> itemsOf(UUID choiceSetUuid) {
        return itemsBySetUuid.getOrDefault(choiceSetUuid, List.of());
    }

    /** 모의고사 위치 (예: 3회 13번), 없으면 null */
    String mockExamLabelOf(UUID questionUuid) {
        return mockExamLabelByQuestionUuid.get(questionUuid);
    }

    int choiceSetCount() {
        return setsByQuestionUuid.values().stream().mapToInt(List::size).sum();
    }
}
