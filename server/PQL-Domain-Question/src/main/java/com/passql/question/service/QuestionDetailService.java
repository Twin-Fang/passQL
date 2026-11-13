package com.passql.question.service;

import com.passql.meta.entity.Subtopic;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.SubtopicRepository;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.dto.QuestionDetail;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 문제 상세 조립: 관리자 상세(모든 세트·정답 포함), 풀이용 상세(정답 제외·세트 1개)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuestionDetailService {

    private final QuestionChoiceSetRepository choiceSetRepository;
    private final QuestionChoiceSetItemRepository choiceSetItemRepository;
    private final TopicRepository topicRepository;
    private final SubtopicRepository subtopicRepository;
    private final QuestionService questionService;

    /** 관리자 상세: 문제 전체 + 모든 선택지 세트 (정답 여부·해설·정답 SQL 포함) */
    public QuestionDetail getQuestionForAdmin(UUID questionUuid) {
        Question question = questionService.getQuestionEntity(questionUuid);
        List<QuestionDetail.ChoiceSetSummary> choiceSets = choiceSetRepository
                .findByQuestionUuidOrderByCreatedAtDesc(questionUuid)
                .stream()
                .map(choiceSet -> toChoiceSetSummary(choiceSet, true, false))
                .toList();
        return toQuestionDetail(question, question.getAnswerSql(), choiceSets);
    }

    /**
     * 풀이용 상세: 정답 SQL 제외, 최신 OK 세트 1개만 (정답 여부·해설 제외) (#503)
     * 정답·해설은 제출 응답에서만 내려간다.
     */
    public QuestionDetail getQuestionForSolving(UUID questionUuid) {
        Question question = questionService.getActiveQuestionEntity(questionUuid);
        List<QuestionDetail.ChoiceSetSummary> choiceSets = findSolvingChoiceSet(question)
                .map(choiceSet -> List.of(toChoiceSetSummary(choiceSet, false, QuestionChoiceSetQueryService.isCuratedChoiceSet(question, choiceSet))))
                .orElse(List.of());
        return toQuestionDetail(question, null, choiceSets);
    }

    /** 풀이용 세트 1개: CURATED_ONLY 는 고정 세트 우선(없으면 최신 OK), 그 외 최신 OK (#511) */
    private Optional<QuestionChoiceSet> findSolvingChoiceSet(Question question) {
        UUID questionUuid = question.getQuestionUuid();
        if (question.getChoiceSetPolicy() == ChoiceSetPolicy.CURATED_ONLY) {
            Optional<QuestionChoiceSet> curatedSet = choiceSetRepository
                    .findFirstByQuestionUuidAndStatusAndSourceInOrderByCreatedAtDesc(
                            questionUuid, ChoiceSetStatus.OK, ChoiceSetSource.CURATED_SOURCES);
            if (curatedSet.isPresent()) {
                return curatedSet;
            }
        }
        return choiceSetRepository.findFirstByQuestionUuidAndStatusOrderByCreatedAtDesc(questionUuid, ChoiceSetStatus.OK);
    }

    /** 선택지 세트 > 요약 (shouldIncludeAnswer=false 면 정답 여부·해설 null, shouldShuffle 이면 표시 순서 섞기) */
    private QuestionDetail.ChoiceSetSummary toChoiceSetSummary(QuestionChoiceSet choiceSet, boolean shouldIncludeAnswer,
                                                               boolean shouldShuffle) {
        List<QuestionDetail.ChoiceItem> items = choiceSetItemRepository
                .findByChoiceSetUuidOrderBySortOrderAsc(choiceSet.getChoiceSetUuid())
                .stream()
                .map(item -> new QuestionDetail.ChoiceItem(
                        item.getChoiceKey(), item.getKind(), item.getBody(),
                        shouldIncludeAnswer ? item.getIsCorrect() : null,
                        shouldIncludeAnswer ? item.getRationale() : null,
                        item.getSortOrder()))
                .toList();
        // 풀이용 고정 세트는 표시 순서 섞기 (관리자 화면은 저장 순서 유지)
        if (shouldShuffle) {
            items = ChoiceOrderShuffler.shuffle(items, QuestionDetail.ChoiceItem::body, (item, sortOrder) -> new QuestionDetail.ChoiceItem(
                    item.key(), item.kind(), item.body(), item.isCorrect(), item.rationale(), sortOrder));
        }
        return new QuestionDetail.ChoiceSetSummary(
                choiceSet.getChoiceSetUuid(),
                choiceSet.getSource(),
                choiceSet.getStatus(),
                choiceSet.getSandboxValidationPassed(),
                choiceSet.getCreatedAt(),
                items);
    }

    private QuestionDetail toQuestionDetail(Question question, String answerSql,
                                            List<QuestionDetail.ChoiceSetSummary> choiceSets) {
        return new QuestionDetail(
                question.getQuestionUuid(),
                topicName(question.getTopicUuid()),
                subtopicName(question.getSubtopicUuid()),
                question.getDifficulty(),
                question.getExecutionMode(),
                question.getChoiceSetPolicy(),
                question.getStem(),
                question.getSchemaDisplay(),
                question.getSchemaDdl(),
                question.getSchemaSampleData(),
                question.getSchemaIntent(),
                SchemaPreviewParser.parse(question.getSchemaDdl(), question.getSchemaSampleData()),
                answerSql,
                question.getHint(),
                choiceSets,
                Boolean.TRUE.equals(question.getIsLatestTrend()),
                false
        );
    }

    private String topicName(UUID topicUuid) {
        if (topicUuid == null) return null;
        return topicRepository.findById(topicUuid).map(Topic::getDisplayName).orElse(null);
    }

    private String subtopicName(UUID subtopicUuid) {
        if (subtopicUuid == null) return null;
        return subtopicRepository.findById(subtopicUuid).map(Subtopic::getDisplayName).orElse(null);
    }
}
