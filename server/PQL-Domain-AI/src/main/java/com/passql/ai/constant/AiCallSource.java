package com.passql.ai.constant;

/**
 * AI 호출 출처 5종: AI_SERVER Python AI 서버 경유 LLM, GEMINI_DIRECT Spring 직접 Gemini 호출 (#557), CLAUDE_DIRECT Spring 직접 Claude 호출 (#688), OPENAI_DIRECT Spring 직접 OpenAI 호출 (#695)
 * VECTOR_SEARCH Python AI 서버 경유 벡터 색인·검색 (LLM 아님, 토큰 과금 없어 LLM 통계에서 제외, #699)
 */
public enum AiCallSource {
    AI_SERVER,
    GEMINI_DIRECT,
    CLAUDE_DIRECT,
    OPENAI_DIRECT,
    VECTOR_SEARCH
}
