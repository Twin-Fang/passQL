package com.passql.submission.service;

import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.service.SchemaPreviewParser;
import com.passql.submission.dto.mockexam.MockExamChoice;
import com.passql.submission.dto.mockexam.MockExamSheetResponse;
import com.passql.submission.entity.MockExamAnswer;
import com.passql.submission.entity.MockExamRound;
import com.passql.submission.entity.MockExamRoundItem;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 회차 시험지 묶음: 문항(번호순) + 문제 + 고정 세트 보기 + 토픽 이름 (한 번에 읽어 문항마다 조회하지 않게)
 */
public record MockExamPaper(
    MockExamRound round,
    List<MockExamRoundItem> items,
    Map<UUID, Question> questionByUuid,
    Map<UUID, List<QuestionChoiceSetItem>> choiceItemsBySetUuid,
    Map<UUID, String> topicNameByUuid
) {

    public Question questionOf(MockExamRoundItem item) {
        return questionByUuid.get(item.getQuestionUuid());
    }

    public List<QuestionChoiceSetItem> choiceItemsOf(MockExamRoundItem item) {
        return choiceItemsBySetUuid.getOrDefault(item.getChoiceSetUuid(), List.of());
    }

    public String topicNameOf(MockExamRoundItem item) {
        return topicNameByUuid.get(item.getTopicUuid());
    }

    /** 고정 세트 정답 키 (정답 없음은 공개 검사가 막음, 비정상 데이터면 null) */
    public String correctChoiceKeyOf(MockExamRoundItem item) {
        return choiceItemsOf(item).stream()
            .filter(choiceItem -> Boolean.TRUE.equals(choiceItem.getIsCorrect()))
            .map(QuestionChoiceSetItem::getChoiceKey)
            .findFirst()
            .orElse(null);
    }

    /** 문항 + 내 답 > 시험지 문항 (정답·근거 없음) */
    public MockExamSheetResponse.SheetQuestion toSheetQuestion(MockExamRoundItem item, MockExamAnswer answerOrNull) {
        Question question = questionOf(item);
        List<MockExamChoice> choices = choiceItemsOf(item).stream()
            .map(choiceItem -> new MockExamChoice(choiceItem.getChoiceKey(), choiceItem.getKind(), choiceItem.getBody(),
                null, null))
            .toList();
        return new MockExamSheetResponse.SheetQuestion(
            item.getQuestionNumber(),
            item.getSubject(),
            topicNameOf(item),
            question != null ? question.getStem() : "",
            question != null ? question.getSchemaDisplay() : null,
            question != null ? SchemaPreviewParser.parse(question.getSchemaDdl(), question.getSchemaSampleData()) : List.of(),
            choices,
            answerOrNull != null ? answerOrNull.getSelectedChoiceKey() : null,
            answerOrNull != null && Boolean.TRUE.equals(answerOrNull.getIsFlagged()));
    }

    /** 번호 > 문항 (없으면 null) */
    public MockExamRoundItem itemOfNumber(int questionNumber) {
        return items.stream()
            .filter(item -> item.getQuestionNumber() == questionNumber)
            .findFirst()
            .orElse(null);
    }
}
