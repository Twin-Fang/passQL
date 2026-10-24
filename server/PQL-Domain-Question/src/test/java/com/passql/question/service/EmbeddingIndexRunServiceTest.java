package com.passql.question.service;

import com.passql.ai.dto.IndexQuestionsBulkResult;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.constant.EmbeddingIndexRunStatus;
import com.passql.question.constant.EmbeddingIndexRunType;
import com.passql.question.entity.EmbeddingIndexRun;
import com.passql.question.repository.EmbeddingIndexRunRepository;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.context.ApplicationEventPublisher;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 임베딩 색인 실행 이력·실패 재시도 (#616) */
class EmbeddingIndexRunServiceTest {

    private final QuestionVectorIndexService questionVectorIndexService = mock(QuestionVectorIndexService.class);
    private final EmbeddingIndexRunRepository embeddingIndexRunRepository = mock(EmbeddingIndexRunRepository.class);

    private final EmbeddingIndexRunService embeddingIndexRunService = new EmbeddingIndexRunService(
            questionVectorIndexService, embeddingIndexRunRepository, mock(ApplicationEventPublisher.class));

    @Test
    void 직전_실행에_실패가_없으면_재시도는_거부한다() {
        EmbeddingIndexRun allSucceededRun = EmbeddingIndexRun.start(EmbeddingIndexRunType.ALL, "passql-admin");
        allSucceededRun.complete(3, 3, 0, List.of());
        when(embeddingIndexRunRepository.findFirstByStatusNotOrderByStartedAtDesc(EmbeddingIndexRunStatus.RUNNING))
                .thenReturn(Optional.of(allSucceededRun));

        assertThatThrownBy(() -> embeddingIndexRunService.startRetryFailed("passql-admin"))
                .isInstanceOf(CustomException.class)
                .extracting(error -> ((CustomException) error).getErrorCode())
                .isEqualTo(ErrorCode.EMBEDDING_INDEX_TARGET_EMPTY);
    }

    @Test
    void 선택_색인은_결과와_실패_문제를_이력에_남긴다() {
        when(embeddingIndexRunRepository.save(any(EmbeddingIndexRun.class))).thenAnswer(call -> call.getArgument(0));
        when(questionVectorIndexService.reindexSelected(List.of("a", "b")))
                .thenReturn(new IndexQuestionsBulkResult(2, 1, 1, List.of("b")));

        embeddingIndexRunService.runSelectedSynchronously(List.of("a", "b"), "passql-admin");

        ArgumentCaptor<EmbeddingIndexRun> runCaptor = ArgumentCaptor.forClass(EmbeddingIndexRun.class);
        verify(embeddingIndexRunRepository, atLeastOnce()).save(runCaptor.capture());
        EmbeddingIndexRun savedRun = runCaptor.getValue();
        assertThat(savedRun.getStatus()).isEqualTo(EmbeddingIndexRunStatus.COMPLETED);
        assertThat(savedRun.getFailedCount()).isEqualTo(1);
        assertThat(savedRun.getFailedQuestionUuidList()).containsExactly("b");
    }

    @Test
    void 실행_중이_아니면_진행률은_idle() {
        assertThat(embeddingIndexRunService.getCurrentProgress().isRunning()).isFalse();
    }
}
