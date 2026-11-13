package com.passql.application.service;

import com.passql.meta.service.LockScreenSettingService;
import com.passql.question.dto.LockScreenQuestionResponse;
import com.passql.question.service.QuestionService;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 잠금화면 출제 (#990): 스위치 꺼짐 empty > 실행형 제외(관리자·요청) > 준비된 후보 중 안 푼 문제 우선
 */
class LockScreenQuestionServiceTest {

    private final LockScreenSettingService lockScreenSettingService = mock(LockScreenSettingService.class);
    private final QuestionService questionService = mock(QuestionService.class);
    private final SubmissionRepository submissionRepository = mock(SubmissionRepository.class);
    private final LockScreenQuestionService lockScreenQuestionService = new LockScreenQuestionService(
            lockScreenSettingService, questionService, new RandomPracticeService(questionService, submissionRepository));

    private final UUID memberUuid = UUID.randomUUID();

    @Test
    void 스위치가_꺼지면_후보를_조회하지_않고_비어_있다() {
        when(lockScreenSettingService.isEnabled()).thenReturn(false);

        assertThat(lockScreenQuestionService.findLockScreenQuestion(memberUuid, false)).isEmpty();
        verify(questionService, never()).findReadyActiveQuestionUuids(anyBoolean());
    }

    @Test
    void 관리자가_실행형을_빼면_요청과_무관하게_실행형을_제외하고_안_푼_문제를_고른다() {
        UUID solvedQuestionUuid = UUID.randomUUID();
        UUID unsolvedQuestionUuid = UUID.randomUUID();
        when(lockScreenSettingService.isEnabled()).thenReturn(true);
        when(lockScreenSettingService.isExecutableIncluded()).thenReturn(false);
        when(questionService.findReadyActiveQuestionUuids(true)).thenReturn(List.of(solvedQuestionUuid, unsolvedQuestionUuid));
        when(submissionRepository.findAllSubmittedQuestionUuids(memberUuid)).thenReturn(List.of(solvedQuestionUuid));

        Optional<LockScreenQuestionResponse> response = lockScreenQuestionService.findLockScreenQuestion(memberUuid, false);

        assertThat(response).map(LockScreenQuestionResponse::questionUuid).contains(unsolvedQuestionUuid);
    }

    @Test
    void 요청이_실행형을_빼면_실행형_제외로_조회하고_후보가_없으면_비어_있다() {
        when(lockScreenSettingService.isEnabled()).thenReturn(true);
        when(lockScreenSettingService.isExecutableIncluded()).thenReturn(true);
        when(questionService.findReadyActiveQuestionUuids(true)).thenReturn(List.of());

        assertThat(lockScreenQuestionService.findLockScreenQuestion(memberUuid, true)).isEmpty();
        verify(questionService).findReadyActiveQuestionUuids(true);
    }
}
