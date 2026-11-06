package com.passql.submission.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionRepository;
import com.passql.submission.entity.MockExamRound;
import com.passql.submission.entity.MockExamRoundItem;
import com.passql.submission.repository.MockExamRoundItemRepository;
import com.passql.submission.repository.MockExamRoundRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 회차 시험지 읽기: 회차 > 문항 > 문제·세트 보기·토픽 이름 (쿼리 4번)
 */
@Component
@RequiredArgsConstructor
public class MockExamPaperLoader {

    private final MockExamRoundRepository roundRepository;
    private final MockExamRoundItemRepository roundItemRepository;
    private final QuestionRepository questionRepository;
    private final QuestionChoiceSetItemRepository choiceSetItemRepository;
    private final TopicRepository topicRepository;

    public MockExamRound getRound(UUID roundUuid) {
        return roundRepository.findById(roundUuid)
            .orElseThrow(() -> new CustomException(ErrorCode.MOCK_EXAM_ROUND_NOT_FOUND));
    }

    public MockExamPaper load(UUID roundUuid) {
        return load(getRound(roundUuid));
    }

    public MockExamPaper load(MockExamRound round) {
        List<MockExamRoundItem> items = roundItemRepository
            .findByMockExamRoundUuidOrderByQuestionNumberAsc(round.getMockExamRoundUuid());

        Map<UUID, Question> questionByUuid = questionRepository
            .findAllById(items.stream().map(MockExamRoundItem::getQuestionUuid).toList())
            .stream()
            .collect(Collectors.toMap(Question::getQuestionUuid, Function.identity()));
        Map<UUID, List<QuestionChoiceSetItem>> choiceItemsBySetUuid = choiceSetItemRepository
            .findByChoiceSetUuidInOrderBySortOrderAsc(items.stream().map(MockExamRoundItem::getChoiceSetUuid).toList())
            .stream()
            .collect(Collectors.groupingBy(QuestionChoiceSetItem::getChoiceSetUuid));
        Map<UUID, String> topicNameByUuid = topicRepository
            .findAllById(items.stream().map(MockExamRoundItem::getTopicUuid).distinct().toList())
            .stream()
            .collect(Collectors.toMap(Topic::getTopicUuid, topic -> topic.getDisplayName() != null
                ? topic.getDisplayName() : topic.getCode()));

        return new MockExamPaper(round, items, questionByUuid, choiceItemsBySetUuid, topicNameByUuid);
    }
}
