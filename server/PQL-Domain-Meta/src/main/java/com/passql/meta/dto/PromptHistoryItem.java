package com.passql.meta.dto;

import com.passql.meta.constant.PromptChangeType;
import com.passql.meta.entity.PromptTemplateHistory;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 프롬프트 변경 이력 1건 (변경 직후 본문 스냅숏 + 변경한 관리자·시각)
 */
public record PromptHistoryItem(
        UUID promptTemplateHistoryUuid,
        UUID promptTemplateUuid,
        String keyName,
        Integer version,
        PromptChangeType changeType,
        Boolean isActive,
        String model,
        String systemPrompt,
        String userTemplate,
        Float temperature,
        Integer maxTokens,
        String changedByAdminUsername,
        LocalDateTime changedAt
) {
    public static PromptHistoryItem from(PromptTemplateHistory history) {
        return new PromptHistoryItem(history.getPromptTemplateHistoryUuid(), history.getPromptTemplateUuid(),
                history.getKeyName(), history.getVersion(), history.getChangeType(), history.getIsActive(),
                history.getModel(), history.getSystemPrompt(), history.getUserTemplate(),
                history.getTemperature(), history.getMaxTokens(), history.getChangedByAdminUsername(),
                history.getCreatedAt());
    }
}
