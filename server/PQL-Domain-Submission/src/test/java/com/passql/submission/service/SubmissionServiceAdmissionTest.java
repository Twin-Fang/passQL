package com.passql.submission.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import com.passql.question.repository.QuestionRepository;
import com.passql.question.service.CachedSandboxExecutor;
import com.passql.submission.repository.ExecutionLogRepository;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.Test;
import org.springframework.transaction.support.TransactionCallback;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

/**
 * 제출 확인이 기록 트랜잭션 안 첫 단계인지 (#867): 거부되면 세트 조회·제출 저장 없이 오류 전파
 */
class SubmissionServiceAdmissionTest {

    private final SubmissionRepository submissionRepository = mock(SubmissionRepository.class);
    private final QuestionChoiceSetRepository choiceSetRepository = mock(QuestionChoiceSetRepository.class);
    private final TransactionTemplate transactionTemplate = mock(TransactionTemplate.class);
    private final SubmissionService submissionService = new SubmissionService(
        submissionRepository, choiceSetRepository, mock(QuestionChoiceSetItemRepository.class),
        mock(QuestionRepository.class), mock(ExecutionLogRepository.class), mock(CachedSandboxExecutor.class),
        transactionTemplate);

    @Test
    @SuppressWarnings("unchecked")
    void 확인이_거부하면_제출을_저장하지_않는다() {
        // 트랜잭션 템플릿은 콜백을 그대로 실행
        when(transactionTemplate.execute(any(TransactionCallback.class)))
            .thenAnswer(invocation -> ((TransactionCallback<Object>) invocation.getArgument(0)).doInTransaction(null));
        SubmissionAdmissionCheck rejectingCheck = () -> {
            throw new CustomException(ErrorCode.FREE_DAILY_LIMIT_REACHED);
        };

        assertThatThrownBy(() -> submissionService.submit(UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID(),
                "A", null, false, rejectingCheck))
            .isInstanceOf(CustomException.class);
        verifyNoInteractions(choiceSetRepository, submissionRepository);
    }
}
