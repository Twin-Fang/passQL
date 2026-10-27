package com.passql.ai.constant;

/**
 * AI 호출 출처 3종: AI_SERVER Python AI 서버 경유, GEMINI_DIRECT Spring 직접 Gemini 호출 (#557), CLAUDE_DIRECT Spring 직접 Claude 호출 (#688)
 */
public enum AiCallSource {
    AI_SERVER,
    GEMINI_DIRECT,
    CLAUDE_DIRECT
}
