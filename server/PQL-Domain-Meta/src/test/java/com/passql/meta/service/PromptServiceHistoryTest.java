package com.passql.meta.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.PromptChangeType;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.entity.PromptTemplateHistory;
import com.passql.meta.repository.PromptTemplateHistoryRepository;
import com.passql.meta.repository.PromptTemplateRepository;
import com.passql.meta.repository.PromptTestHistoryRepository;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.context.ApplicationEventPublisher;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 프롬프트 삭제·이력 되돌리기 (#615) */
class PromptServiceHistoryTest {

    private final PromptTemplateRepository promptTemplateRepository = mock(PromptTemplateRepository.class);
    private final PromptTemplateHistoryRepository promptTemplateHistoryRepository = mock(PromptTemplateHistoryRepository.class);

    private final PromptService promptService = new PromptService(promptTemplateRepository,
            promptTemplateHistoryRepository, mock(PromptTestHistoryRepository.class), mock(ApplicationEventPublisher.class));

    private PromptTemplate newTemplate(boolean isActive, String systemPrompt) {
        PromptTemplate template = PromptTemplate.builder()
                .keyName("explain_error").version(2).isActive(isActive).build();
        template.setSystemPrompt(systemPrompt);
        return template;
    }

    @Test
    void 활성_버전은_삭제할_수_없다() {
        UUID uuid = UUID.randomUUID();
        when(promptTemplateRepository.findById(uuid)).thenReturn(Optional.of(newTemplate(true, "본문")));

        assertThatThrownBy(() -> promptService.delete(uuid, "passql-admin"))
                .isInstanceOf(CustomException.class)
                .extracting(error -> ((CustomException) error).getErrorCode())
                .isEqualTo(ErrorCode.PROMPT_ACTIVE_DELETE_FORBIDDEN);
        verify(promptTemplateRepository, never()).delete(any());
    }

    @Test
    void 비활성_버전_삭제는_삭제_직전_상태를_이력에_남긴다() {
        UUID uuid = UUID.randomUUID();
        PromptTemplate template = newTemplate(false, "삭제될 본문");
        when(promptTemplateRepository.findById(uuid)).thenReturn(Optional.of(template));

        promptService.delete(uuid, "passql-admin");

        ArgumentCaptor<PromptTemplateHistory> historyCaptor = ArgumentCaptor.forClass(PromptTemplateHistory.class);
        verify(promptTemplateHistoryRepository).save(historyCaptor.capture());
        assertThat(historyCaptor.getValue().getChangeType()).isEqualTo(PromptChangeType.DELETE);
        assertThat(historyCaptor.getValue().getSystemPrompt()).isEqualTo("삭제될 본문");
        assertThat(historyCaptor.getValue().getChangedByAdminUsername()).isEqualTo("passql-admin");
        verify(promptTemplateRepository).delete(template);
    }

    @Test
    void 이력_시점으로_되돌리면_본문만_바뀌고_되돌림_이력이_남는다() {
        PromptTemplate original = newTemplate(true, "옛 본문");
        PromptTemplateHistory oldHistory = PromptTemplateHistory.builder()
                .template(original).changeType(PromptChangeType.UPDATE).changedByAdminUsername("a").build();
        UUID historyUuid = UUID.randomUUID();
        PromptTemplate current = newTemplate(true, "현재 본문");
        when(promptTemplateHistoryRepository.findById(historyUuid)).thenReturn(Optional.of(oldHistory));
        // 이력의 프롬프트 UUID 는 저장 전이라 null, 조회도 null 키로 맞춤
        when(promptTemplateRepository.findById(oldHistory.getPromptTemplateUuid())).thenReturn(Optional.of(current));
        when(promptTemplateRepository.save(current)).thenReturn(current);

        promptService.restoreFromHistory(historyUuid, "passql-admin");

        assertThat(current.getSystemPrompt()).isEqualTo("옛 본문");
        assertThat(current.getVersion()).isEqualTo(2);
        ArgumentCaptor<PromptTemplateHistory> historyCaptor = ArgumentCaptor.forClass(PromptTemplateHistory.class);
        verify(promptTemplateHistoryRepository).save(historyCaptor.capture());
        assertThat(historyCaptor.getValue().getChangeType()).isEqualTo(PromptChangeType.RESTORE);
    }
}
