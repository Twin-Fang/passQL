package com.passql.ai.client;

import java.util.List;
import java.util.Locale;
import java.util.Set;

/**
 * 다음 AI 연결로 넘어갈지 판정 (AI 서버 llm_client.py 와 같은 규칙, #695)
 * 넘어감: 응답 없음(타임아웃·연결·키 미설정), 401·402·403·404·429·5xx, 400 중 크레딧·한도 부족·무효 키 문구
 * 즉시 실패: 그 외 400 등 요청 자체 문제 (다른 연결도 같은 이유로 실패)
 */
public final class AiFallbackPolicy {

    private static final Set<Integer> FALLBACK_STATUS_CODES = Set.of(401, 402, 403, 404, 429);
    private static final int SERVER_ERROR_MINIMUM_STATUS_CODE = 500;
    private static final int BAD_REQUEST_STATUS_CODE = 400;
    // 400 이지만 계정 문제인 응답 문구 (Claude 크레딧 부족, OpenAI 한도, Gemini 무효·만료 키)
    private static final List<String> ACCOUNT_ERROR_MESSAGE_FRAGMENTS = List.of("credit balance", "insufficient_quota", "quota",
            "api_key_invalid", "api key not valid", "api key expired");

    private AiFallbackPolicy() {
    }

    public static boolean shouldTryNextConnection(AiProviderException exception) {
        Integer statusCode = exception.getStatusCode();
        if (statusCode == null) {
            return true;
        }
        if (FALLBACK_STATUS_CODES.contains(statusCode) || statusCode >= SERVER_ERROR_MINIMUM_STATUS_CODE) {
            return true;
        }
        if (statusCode == BAD_REQUEST_STATUS_CODE) {
            String responseBody = exception.getResponseBodySnippet().toLowerCase(Locale.ROOT);
            return ACCOUNT_ERROR_MESSAGE_FRAGMENTS.stream().anyMatch(responseBody::contains);
        }
        return false;
    }
}
