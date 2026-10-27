package com.passql.ai.dto;

import com.passql.ai.constant.AiProvider;

import java.util.UUID;

/**
 * 호출용 AI 연결 1건 (키 평문 포함, 로그·응답에 내보내지 않음)
 */
public record AiConnectionTarget(
        UUID aiConnectionUuid,
        String connectionName,
        AiProvider provider,
        String apiKey,
        String defaultModel
) {
    @Override
    public String toString() {
        // 키 평문이 로그에 찍히지 않게
        return "AiConnectionTarget[" + connectionName + ", " + provider + ", " + defaultModel + "]";
    }
}
