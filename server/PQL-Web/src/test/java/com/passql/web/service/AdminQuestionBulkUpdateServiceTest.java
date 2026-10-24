package com.passql.web.service;

import com.passql.common.exception.CustomException;
import com.passql.meta.entity.Subtopic;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.SubtopicRepository;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.dto.QuestionBulkClassifyRequest;
import com.passql.question.entity.Question;
import com.passql.question.repository.QuestionRepository;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/** 문제 일괄 활성화·토픽·난이도 변경 (#612): 바뀐 문제만 집계, 없는 문제·변화 없음은 건너뜀 */
class AdminQuestionBulkUpdateServiceTest {

    private final QuestionRepository questionRepository = mock(QuestionRepository.class);
    private final TopicRepository topicRepository = mock(TopicRepository.class);
    private final SubtopicRepository subtopicRepository = mock(SubtopicRepository.class);
    private final AdminQuestionBulkUpdateService service =
            new AdminQuestionBulkUpdateService(questionRepository, topicRepository, subtopicRepository, event -> { });

    @Test
    void 일괄_활성화는_비활성_문제만_켜고_이미_활성과_없는_문제는_건너뛴다() {
        Question inactiveQuestion = Question.builder().questionUuid(UUID.randomUUID()).isActive(false).build();
        Question activeQuestion = Question.builder().questionUuid(UUID.randomUUID()).isActive(true).build();
        List<UUID> requestedUuids = List.of(inactiveQuestion.getQuestionUuid(), activeQuestion.getQuestionUuid(), UUID.randomUUID());
        when(questionRepository.findAllById(requestedUuids)).thenReturn(List.of(inactiveQuestion, activeQuestion));

        AdminQuestionBulkUpdateService.BulkUpdateResult result = service.activateQuestions(requestedUuids);

        assertThat(result.updated()).isEqualTo(1);
        assertThat(result.skipped()).isEqualTo(2);
        assertThat(inactiveQuestion.getIsActive()).isTrue();
    }

    @Test
    void 토픽을_바꾸면_서브토픽은_비우고_난이도도_함께_바꾼다() {
        Topic joinTopic = Topic.builder().topicUuid(UUID.randomUUID()).code("sql_join").build();
        Question question = Question.builder().questionUuid(UUID.randomUUID()).topicUuid(UUID.randomUUID())
                .subtopicUuid(UUID.randomUUID()).difficulty(1).build();
        when(topicRepository.findByCode("sql_join")).thenReturn(Optional.of(joinTopic));
        when(questionRepository.findAllById(List.of(question.getQuestionUuid()))).thenReturn(List.of(question));

        AdminQuestionBulkUpdateService.BulkUpdateResult result = service.classifyQuestions(
                new QuestionBulkClassifyRequest(List.of(question.getQuestionUuid()), "sql_join", null, 4));

        assertThat(result.updated()).isEqualTo(1);
        assertThat(question.getTopicUuid()).isEqualTo(joinTopic.getTopicUuid());
        assertThat(question.getSubtopicUuid()).isNull();
        assertThat(question.getDifficulty()).isEqualTo(4);
    }

    @Test
    void 같은_토픽이고_난이도도_같으면_변경_없음으로_건너뛴다() {
        Topic joinTopic = Topic.builder().topicUuid(UUID.randomUUID()).code("sql_join").build();
        Question question = Question.builder().questionUuid(UUID.randomUUID()).topicUuid(joinTopic.getTopicUuid())
                .subtopicUuid(UUID.randomUUID()).difficulty(3).build();
        when(topicRepository.findByCode("sql_join")).thenReturn(Optional.of(joinTopic));
        when(questionRepository.findAllById(List.of(question.getQuestionUuid()))).thenReturn(List.of(question));

        AdminQuestionBulkUpdateService.BulkUpdateResult result = service.classifyQuestions(
                new QuestionBulkClassifyRequest(List.of(question.getQuestionUuid()), "sql_join", null, 3));

        assertThat(result.updated()).isZero();
        assertThat(result.skipped()).isEqualTo(1);
        assertThat(question.getSubtopicUuid()).as("같은 토픽이면 서브토픽 유지").isNotNull();
    }

    @Test
    void 다른_토픽_소속_서브토픽과_범위_밖_난이도는_거부한다() {
        Topic joinTopic = Topic.builder().topicUuid(UUID.randomUUID()).code("sql_join").build();
        Subtopic otherSubtopic = Subtopic.builder().subtopicUuid(UUID.randomUUID()).topicUuid(UUID.randomUUID()).code("other").build();
        when(topicRepository.findByCode("sql_join")).thenReturn(Optional.of(joinTopic));
        when(subtopicRepository.findByCode("other")).thenReturn(Optional.of(otherSubtopic));
        List<UUID> questionUuids = List.of(UUID.randomUUID());

        assertThatThrownBy(() -> service.classifyQuestions(new QuestionBulkClassifyRequest(questionUuids, "sql_join", "other", null)))
                .isInstanceOf(CustomException.class);
        assertThatThrownBy(() -> service.classifyQuestions(new QuestionBulkClassifyRequest(questionUuids, null, null, 9)))
                .isInstanceOf(CustomException.class);
        assertThatThrownBy(() -> service.classifyQuestions(new QuestionBulkClassifyRequest(questionUuids, null, null, null)))
                .isInstanceOf(CustomException.class);
    }
}
