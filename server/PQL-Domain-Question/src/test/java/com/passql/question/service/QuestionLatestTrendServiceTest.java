package com.passql.question.service;

import com.passql.common.exception.CustomException;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.SubtopicRepository;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.dto.AdminLatestTrendUpdateRequest;
import com.passql.question.dto.AdminLatestTrendUpdateResult;
import com.passql.question.dto.LatestTrendTopicCount;
import com.passql.question.entity.Question;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.question.repository.QuestionChoiceRepository;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import com.passql.question.repository.QuestionRepository;
import com.passql.question.repository.TopicQuestionCountProjection;
import org.junit.jupiter.api.Test;
import org.springframework.context.ApplicationEventPublisher;

import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyIterable;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 최신 경향 문제 (#523): 토픽별 문제 수(비활성 토픽 제외·정렬), 일괄 지정(바뀐 것만 감사 기록·없는 UUID 보고), 요청 검증
 */
class QuestionLatestTrendServiceTest {

    private final QuestionRepository questionRepository = mock(QuestionRepository.class);
    private final TopicRepository topicRepository = mock(TopicRepository.class);
    private final ApplicationEventPublisher eventPublisher = mock(ApplicationEventPublisher.class);
    private final QuestionLatestTrendService service =
            new QuestionLatestTrendService(questionRepository, topicRepository, eventPublisher);

    @Test
    void 토픽별_문제_수는_활성_토픽만_정렬_순서대로_돌려준다() {
        Topic joinTopic = topic("sql_join", "조인", 2, true);
        Topic modelingTopic = topic("data_modeling", "데이터 모델링", 1, true);
        Topic retiredTopic = topic("retired", "폐지 토픽", 0, false);
        when(questionRepository.countActiveLatestTrendByTopic()).thenReturn(List.of(
                topicCount(joinTopic.getTopicUuid(), 3),
                topicCount(retiredTopic.getTopicUuid(), 5),
                topicCount(modelingTopic.getTopicUuid(), 2)));
        when(topicRepository.findAllById(anyIterable())).thenReturn(List.of(joinTopic, modelingTopic, retiredTopic));

        List<LatestTrendTopicCount> topicCounts = service.getLatestTrendTopicCounts();

        assertThat(topicCounts).containsExactly(
                new LatestTrendTopicCount("data_modeling", "데이터 모델링", 2),
                new LatestTrendTopicCount("sql_join", "조인", 3));
    }

    @Test
    void 일괄_지정은_값이_다른_문제만_바꾸고_없는_UUID를_보고한다() {
        Question alreadyFlagged = question(true);
        Question notFlagged = question(false);
        UUID missingQuestionUuid = UUID.randomUUID();
        when(questionRepository.findAllById(anyIterable())).thenReturn(List.of(alreadyFlagged, notFlagged));

        AdminLatestTrendUpdateResult result = service.updateLatestTrend(new AdminLatestTrendUpdateRequest(
                List.of(alreadyFlagged.getQuestionUuid(), notFlagged.getQuestionUuid(), missingQuestionUuid,
                        notFlagged.getQuestionUuid()),
                true));

        assertThat(result.requestedCount()).isEqualTo(3);
        assertThat(result.changedCount()).isEqualTo(1);
        assertThat(result.notFoundQuestionUuids()).containsExactly(missingQuestionUuid);
        assertThat(notFlagged.getIsLatestTrend()).isTrue();
        verify(eventPublisher, times(1)).publishEvent(any(Object.class));
    }

    @Test
    void 일괄_해제는_지정된_문제를_false로_바꾼다() {
        Question flagged = question(true);
        when(questionRepository.findAllById(anyIterable())).thenReturn(List.of(flagged));

        AdminLatestTrendUpdateResult result = service.updateLatestTrend(
                new AdminLatestTrendUpdateRequest(List.of(flagged.getQuestionUuid()), false));

        assertThat(result.changedCount()).isEqualTo(1);
        assertThat(flagged.getIsLatestTrend()).isFalse();
    }

    @Test
    void 빈_목록이나_지정값_없는_요청은_거부한다() {
        assertThatThrownBy(() -> service.updateLatestTrend(new AdminLatestTrendUpdateRequest(List.of(), true)))
                .isInstanceOf(CustomException.class);
        assertThatThrownBy(() -> service.updateLatestTrend(
                new AdminLatestTrendUpdateRequest(List.of(UUID.randomUUID()), null)))
                .isInstanceOf(CustomException.class);
        assertThatThrownBy(() -> service.updateLatestTrend(new AdminLatestTrendUpdateRequest(
                Collections.nCopies(QuestionLatestTrendService.MAXIMUM_UPDATE_QUESTION_COUNT + 1, UUID.randomUUID()),
                true)))
                .isInstanceOf(CustomException.class);
    }

    private static Question question(boolean isLatestTrend) {
        return Question.builder().questionUuid(UUID.randomUUID()).isLatestTrend(isLatestTrend).build();
    }

    private static Topic topic(String code, String displayName, int sortOrder, boolean isActive) {
        return Topic.builder().topicUuid(UUID.randomUUID()).code(code).displayName(displayName)
                .sortOrder(sortOrder).isActive(isActive).build();
    }

    private static TopicQuestionCountProjection topicCount(UUID topicUuid, long questionCount) {
        return new TopicQuestionCountProjection() {
            @Override
            public UUID getTopicUuid() {
                return topicUuid;
            }

            @Override
            public Long getQuestionCount() {
                return questionCount;
            }
        };
    }

    // 문제 응답 최신 경향 표시 (목록 요약·풀이용 상세, null 은 false)
        private final QuestionService questionService = new QuestionService(
            questionRepository,
            mock(QuestionChoiceRepository.class),
            mock(QuestionChoiceSetRepository.class),
            mock(QuestionChoiceSetItemRepository.class),
            mock(DailyChallengeRepository.class),
            mock(TopicRepository.class),
            mock(SubtopicRepository.class),
            mock(ApplicationEventPublisher.class));

    @Test
    void 최신_경향_문제는_요약과_상세에_true로_나간다() {
        Question question = Question.builder().questionUuid(UUID.randomUUID()).stem("지문").isLatestTrend(true).build();
        when(questionRepository.findById(question.getQuestionUuid())).thenReturn(Optional.of(question));

        assertThat(questionService.toSummary(question).isLatestTrend()).isTrue();
        assertThat(questionService.getQuestionForSolving(question.getQuestionUuid()).isLatestTrend()).isTrue();
    }

    @Test
    void 지정되지_않은_문제는_false로_나간다() {
        Question defaultQuestion = Question.builder().questionUuid(UUID.randomUUID()).stem("지문").build();
        Question nullFlagQuestion = Question.builder().questionUuid(UUID.randomUUID()).stem("지문").isLatestTrend(null).build();

        assertThat(questionService.toSummary(defaultQuestion).isLatestTrend()).isFalse();
        assertThat(questionService.toSummary(nullFlagQuestion).isLatestTrend()).isFalse();
    }
}
