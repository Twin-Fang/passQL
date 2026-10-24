package com.passql.meta.dto;

import com.passql.meta.entity.PromptTemplate;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 같은 keyName 의 버전 1건 (버전 간 diff·롤백 화면용, 본문 포함)
 */
public record PromptVersionItem(
        UUID promptTemplateUuid,
        Integer version,
        Boolean isActive,
        String model,
        String systemPrompt,
        String userTemplate,
        Float temperature,
        Integer maxTokens,
        LocalDateTime updatedAt
) {
    public static PromptVersionItem from(PromptTemplate template) {
        return new PromptVersionItem(template.getPromptTemplateUuid(), template.getVersion(), template.getIsActive(),
                template.getModel(), template.getSystemPrompt(), template.getUserTemplate(),
                template.getTemperature(), template.getMaxTokens(), template.getUpdatedAt());
    }
}
