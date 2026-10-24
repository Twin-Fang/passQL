package com.passql.question.service;

import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.dto.AdminChoiceSetBulkResult;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/** 선택지 세트 일괄 비활성화·승격 (#618): 승격은 OK 세트만, 중복·없는 세트는 건너뜀 */
class AdminChoiceSetBulkTest {

    private final QuestionChoiceSetRepository repository = mock(QuestionChoiceSetRepository.class);
    private final AdminChoiceSetService service =
            new AdminChoiceSetService(repository, mock(QuestionChoiceSetItemRepository.class), event -> { });

    private QuestionChoiceSet newChoiceSet(ChoiceSetStatus status, ChoiceSetSource source, boolean isReusable) {
        return QuestionChoiceSet.builder().choiceSetUuid(UUID.randomUUID()).questionUuid(UUID.randomUUID())
                .status(status).source(source).isReusable(isReusable).build();
    }

    @Test
    void 일괄_승격은_OK_세트만_승격하고_실패_세트와_이미_승격된_세트와_없는_세트는_건너뛴다() {
        QuestionChoiceSet okSet = newChoiceSet(ChoiceSetStatus.OK, ChoiceSetSource.AI_RUNTIME, false);
        QuestionChoiceSet failedSet = newChoiceSet(ChoiceSetStatus.FAILED, ChoiceSetSource.AI_RUNTIME, false);
        QuestionChoiceSet promotedSet = newChoiceSet(ChoiceSetStatus.OK, ChoiceSetSource.ADMIN_CURATED, true);
        List<UUID> requestedUuids = List.of(okSet.getChoiceSetUuid(), failedSet.getChoiceSetUuid(),
                promotedSet.getChoiceSetUuid(), UUID.randomUUID());
        when(repository.findAllById(requestedUuids)).thenReturn(List.of(okSet, failedSet, promotedSet));

        AdminChoiceSetBulkResult result = service.promoteChoiceSets(requestedUuids);

        assertThat(result.updated()).isEqualTo(1);
        assertThat(result.skipped()).isEqualTo(3);
        assertThat(okSet.getSource()).isEqualTo(ChoiceSetSource.ADMIN_CURATED);
        assertThat(okSet.getIsReusable()).isTrue();
        assertThat(failedSet.getSource()).isEqualTo(ChoiceSetSource.AI_RUNTIME);
    }

    @Test
    void 일괄_비활성화는_이미_비활성인_세트를_건너뛴다() {
        QuestionChoiceSet okSet = newChoiceSet(ChoiceSetStatus.OK, ChoiceSetSource.AI_RUNTIME, false);
        QuestionChoiceSet disabledSet = newChoiceSet(ChoiceSetStatus.DISABLED, ChoiceSetSource.AI_RUNTIME, false);
        List<UUID> requestedUuids = List.of(okSet.getChoiceSetUuid(), disabledSet.getChoiceSetUuid());
        when(repository.findAllById(requestedUuids)).thenReturn(List.of(okSet, disabledSet));

        AdminChoiceSetBulkResult result = service.disableChoiceSets(requestedUuids);

        assertThat(result.updated()).isEqualTo(1);
        assertThat(result.skipped()).isEqualTo(1);
        assertThat(okSet.getStatus()).isEqualTo(ChoiceSetStatus.DISABLED);
    }
}
