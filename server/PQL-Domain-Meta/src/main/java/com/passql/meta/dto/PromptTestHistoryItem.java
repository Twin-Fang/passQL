package com.passql.meta.dto;

import com.passql.meta.entity.PromptTestHistory;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 프롬프트 테스트 결과 이력 1건 (입력 변수 JSON 문자열, 응답 원문, 소요 시간, 성공 여부)
 */
public record PromptTestHistoryItem(
        UUID promptTestHistoryUuid,
        String variablesJson,
        String resultText,
        Integer elapsedMilliseconds,
        Boolean isSuccess,
        String errorMessage,
        String testedByAdminUsername,
        LocalDateTime testedAt
) {
    public static PromptTestHistoryItem from(PromptTestHistory history) {
        return new PromptTestHistoryItem(history.getPromptTestHistoryUuid(), history.getVariablesJson(),
                history.getResultText(), history.getElapsedMilliseconds(), history.getIsSuccess(),
                history.getErrorMessage(), history.getTestedByAdminUsername(), history.getCreatedAt());
    }
}
