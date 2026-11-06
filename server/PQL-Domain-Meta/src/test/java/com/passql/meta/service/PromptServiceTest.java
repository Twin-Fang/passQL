package com.passql.meta.service;

import com.passql.meta.constant.PromptKey;
import com.passql.meta.dto.PromptTemplateSaveRequest;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.repository.PromptTemplateHistoryRepository;
import com.passql.meta.repository.PromptTemplateRepository;
import com.passql.meta.repository.PromptTestHistoryRepository;
import org.junit.jupiter.api.Test;
import org.springframework.context.ApplicationEventPublisher;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class PromptServiceTest {

    private final PromptTemplateRepository promptTemplateRepository = mock(PromptTemplateRepository.class);
    private final PromptService promptService = new PromptService(promptTemplateRepository,
            mock(PromptTemplateHistoryRepository.class), mock(PromptTestHistoryRepository.class),
            mock(ApplicationEventPublisher.class));

    @Test
    void 수정_요청의_키가_달라도_기존_키를_유지한다() {
        // 기존 ai_analysis_session 행 <-> 다른 키로 온 수정 요청 (#875: 폼이 explain_error 로 바꿔 보내던 경우)
        UUID promptTemplateUuid = UUID.randomUUID();
        PromptTemplate existing = PromptTemplate.builder()
                .promptTemplateUuid(promptTemplateUuid)
                .keyName(PromptKey.AI_ANALYSIS_SESSION.getKeyName())
                .version(3)
                .isActive(true)
                .build();
        when(promptTemplateRepository.findById(promptTemplateUuid)).thenReturn(Optional.of(existing));
        when(promptTemplateRepository.save(any(PromptTemplate.class))).thenAnswer(call -> call.getArgument(0));
        PromptTemplateSaveRequest request = new PromptTemplateSaveRequest(PromptKey.EXPLAIN_ERROR.getKeyName(), 4,
                true, "model", "system", "user", 0.3f, 1024);

        PromptTemplate saved = promptService.update(promptTemplateUuid, request, "admin");

        // 키는 그대로, 나머지 값은 요청대로
        assertThat(saved.getKeyName()).isEqualTo(PromptKey.AI_ANALYSIS_SESSION.getKeyName());
        assertThat(saved.getVersion()).isEqualTo(4);
        assertThat(saved.getSystemPrompt()).isEqualTo("system");
    }
}
