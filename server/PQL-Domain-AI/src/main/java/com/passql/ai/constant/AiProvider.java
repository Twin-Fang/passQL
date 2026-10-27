package com.passql.ai.constant;

import java.util.List;
import java.util.Locale;
import java.util.Optional;

/**
 * AI 제공자 3종: 모델 이름 접두사 > 제공자 판정 (AI 서버 llm_client.py 와 같은 규칙, #695)
 */
public enum AiProvider {

    GEMINI("Gemini", List.of("gemini-")),
    CLAUDE("Claude", List.of("claude-")),
    OPENAI("OpenAI", List.of("gpt-", "chatgpt-", "o1", "o3", "o4"));

    // 화면 표시 이름
    private final String label;
    // 이 접두사로 시작하는 모델은 이 제공자 소속
    private final List<String> modelPrefixes;

    AiProvider(String label, List<String> modelPrefixes) {
        this.label = label;
        this.modelPrefixes = modelPrefixes;
    }

    public String getLabel() {
        return label;
    }

    /** 모델 이름 > 제공자 (빈 값·모르는 접두사 > empty) */
    public static Optional<AiProvider> fromModelName(String modelName) {
        if (modelName == null || modelName.isBlank()) {
            return Optional.empty();
        }
        String normalizedModelName = modelName.strip().toLowerCase(Locale.ROOT);
        for (AiProvider provider : values()) {
            if (provider.modelPrefixes.stream().anyMatch(normalizedModelName::startsWith)) {
                return Optional.of(provider);
            }
        }
        return Optional.empty();
    }
}
