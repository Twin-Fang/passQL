package com.passql.web.service;

import com.passql.question.entity.Question;
import com.passql.question.repository.QuestionRepository;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 문제 삭제 = 비활성화 (#471): 행·회원 기록을 지우지 않고 is_active 만 끈다 */
class AdminQuestionDeleteServiceTest {

    private final QuestionRepository questionRepository = mock(QuestionRepository.class);
    private final AdminQuestionDeleteService adminQuestionDeleteService = new AdminQuestionDeleteService(questionRepository);

    @Test
    void 일괄_비활성화는_활성_문제만_끄고_없는_문제와_이미_비활성은_건너뛴다() {
        Question activeQuestion = Question.builder().questionUuid(UUID.randomUUID()).isActive(true).build();
        Question inactiveQuestion = Question.builder().questionUuid(UUID.randomUUID()).isActive(false).build();
        UUID missingQuestionUuid = UUID.randomUUID();
        List<UUID> requestedUuids = List.of(
                activeQuestion.getQuestionUuid(), inactiveQuestion.getQuestionUuid(), missingQuestionUuid);
        when(questionRepository.findAllById(requestedUuids)).thenReturn(List.of(activeQuestion, inactiveQuestion));

        AdminQuestionDeleteService.BulkDeactivateResult result =
                adminQuestionDeleteService.deactivateQuestions(requestedUuids);

        assertThat(result.deactivated()).isEqualTo(1);
        assertThat(result.skipped()).isEqualTo(2);
        assertThat(activeQuestion.getIsActive()).isFalse();
        // 하드 삭제 경로 없음 (회원 제출·실행 로그 보존)
        verify(questionRepository, never()).delete(any());
        verify(questionRepository, never()).deleteAll(any());
    }
}
