package com.passql.ai.dto;

import com.passql.ai.constant.AiProvider;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 관리자 화면 연결 1행 (키는 끝 4자리만)
 */
public record AiConnectionView(
        UUID aiConnectionUuid,
        int callOrder,
        AiProvider provider,
        String connectionName,
        String defaultModel,
        boolean isEnabled,
        String maskedApiKey,
        LocalDateTime lastSuccessAt,
        LocalDateTime lastFailureAt,
        String lastErrorType,
        long monthCallCount,
        long monthSuccessCount
) {
    /** 최근 결과가 실패인지 (마지막 실패가 마지막 성공보다 나중) */
    public boolean isLastCallFailed() {
        return lastFailureAt != null && (lastSuccessAt == null || lastFailureAt.isAfter(lastSuccessAt));
    }
}
