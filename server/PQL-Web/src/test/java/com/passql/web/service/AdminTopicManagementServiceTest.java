package com.passql.web.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.Subtopic;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.SubtopicRepository;
import com.passql.meta.repository.TopicRepository;
import com.passql.meta.service.MetaService;
import com.passql.question.repository.QuestionRepository;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 토픽·서브토픽 삭제 (#614): 소속 문제가 있으면 막고 안내, 없으면 삭제. 순서 변경은 전체 목록만 허용 */
class AdminTopicManagementServiceTest {

    private final TopicRepository topicRepository = mock(TopicRepository.class);
    private final SubtopicRepository subtopicRepository = mock(SubtopicRepository.class);
    private final QuestionRepository questionRepository = mock(QuestionRepository.class);
    private final AdminTopicManagementService service =
            new AdminTopicManagementService(topicRepository, subtopicRepository, questionRepository, event -> { });

    private final Topic topic = Topic.builder().topicUuid(UUID.randomUUID()).code("sql_join").displayName("조인").build();
    private final Subtopic subtopic = Subtopic.builder().subtopicUuid(UUID.randomUUID()).topicUuid(topic.getTopicUuid())
            .code("inner_join").displayName("내부 조인").build();

    @Test
    void 소속_문제가_있는_토픽은_삭제하지_않고_개수를_안내한다() {
        when(topicRepository.findByCode("sql_join")).thenReturn(Optional.of(topic));
        when(questionRepository.countByTopicUuid(topic.getTopicUuid())).thenReturn(3L);

        assertThatThrownBy(() -> service.deleteTopic("sql_join"))
                .isInstanceOfSatisfying(CustomException.class, exception -> {
                    assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.TOPIC_HAS_QUESTIONS);
                    assertThat(exception.getMessage()).contains("3개");
                });
        verify(topicRepository, never()).delete(any(Topic.class));
    }

    @Test
    void 문제가_없으면_토픽과_하위_서브토픽을_함께_삭제한다() {
        when(topicRepository.findByCode("sql_join")).thenReturn(Optional.of(topic));
        when(subtopicRepository.findByTopicUuidOrderBySortOrderAsc(topic.getTopicUuid())).thenReturn(List.of(subtopic));

        service.deleteTopic("sql_join");

        verify(subtopicRepository).deleteAll(List.of(subtopic));
        verify(topicRepository).delete(topic);
    }

    @Test
    void 소속_문제가_있는_서브토픽은_삭제하지_않고_다른_토픽_소속_서브토픽은_없음_처리한다() {
        when(topicRepository.findByCode("sql_join")).thenReturn(Optional.of(topic));
        when(subtopicRepository.findByCode("inner_join")).thenReturn(Optional.of(subtopic));
        when(questionRepository.countBySubtopicUuid(subtopic.getSubtopicUuid())).thenReturn(1L);

        assertThatThrownBy(() -> service.deleteSubtopic("sql_join", "inner_join"))
                .isInstanceOf(CustomException.class);
        verify(subtopicRepository, never()).delete(any(Subtopic.class));

        Topic otherTopic = Topic.builder().topicUuid(UUID.randomUUID()).code("other").build();
        when(topicRepository.findByCode("other")).thenReturn(Optional.of(otherTopic));
        assertThatThrownBy(() -> service.deleteSubtopic("other", "inner_join"))
                .isInstanceOfSatisfying(CustomException.class,
                        exception -> assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.TOPIC_NOT_FOUND));
    }

    @Test
    void 토픽_순서_변경은_전체_코드를_새_순서로_받아_정렬값을_다시_매긴다() {
        Topic first = Topic.builder().topicUuid(UUID.randomUUID()).code("a_topic").sortOrder(1).build();
        Topic second = Topic.builder().topicUuid(UUID.randomUUID()).code("b_topic").sortOrder(2).build();
        when(topicRepository.findAllByOrderBySortOrderAsc()).thenReturn(List.of(first, second));
        MetaService metaService = new MetaService(topicRepository, subtopicRepository, null, null, event -> { });

        metaService.reorderTopics(List.of("b_topic", "a_topic"));

        assertThat(second.getSortOrder()).isEqualTo(1);
        assertThat(first.getSortOrder()).isEqualTo(2);
        assertThatThrownBy(() -> metaService.reorderTopics(List.of("a_topic")))
                .as("누락된 코드").isInstanceOf(CustomException.class);
        assertThatThrownBy(() -> metaService.reorderTopics(List.of("a_topic", "a_topic")))
                .as("중복 코드").isInstanceOf(CustomException.class);
    }
}
