package com.passql.ai.client;

import com.passql.ai.constant.AiProvider;
import com.passql.ai.dto.AiCallAttempt;
import com.passql.ai.dto.AiConnectionTarget;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * 시도 순서 계산 (AI 서버 llm_client.py 와 같은 규칙, #695)
 * 프롬프트 모델의 제공자 연결이 있으면: 그 제공자 연결들(프롬프트 모델) > 나머지 연결들(각 기본 모델)
 * 없으면: 모든 연결을 우선순위 순으로 각 기본 모델
 */
public final class AiCallAttemptPlanner {

    private AiCallAttemptPlanner() {
    }

    /** connectionsInPriorityOrder: 사용 중 연결, 우선순위 오름차순 */
    public static List<AiCallAttempt> planAttempts(String promptModel, List<AiConnectionTarget> connectionsInPriorityOrder) {
        Optional<AiProvider> promptModelProvider = AiProvider.fromModelName(promptModel);
        boolean hasPromptModelConnection = promptModelProvider.isPresent() && connectionsInPriorityOrder.stream()
                .anyMatch(connection -> connection.provider() == promptModelProvider.get());
        if (!hasPromptModelConnection) {
            return connectionsInPriorityOrder.stream()
                    .map(connection -> new AiCallAttempt(connection, connection.defaultModel()))
                    .toList();
        }
        List<AiCallAttempt> attempts = new ArrayList<>();
        connectionsInPriorityOrder.stream()
                .filter(connection -> connection.provider() == promptModelProvider.get())
                .forEach(connection -> attempts.add(new AiCallAttempt(connection, promptModel.strip())));
        connectionsInPriorityOrder.stream()
                .filter(connection -> connection.provider() != promptModelProvider.get())
                .forEach(connection -> attempts.add(new AiCallAttempt(connection, connection.defaultModel())));
        return attempts;
    }
}
