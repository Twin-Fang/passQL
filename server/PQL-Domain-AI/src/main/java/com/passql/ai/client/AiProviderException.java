package com.passql.ai.client;

import com.passql.ai.constant.AiProvider;
import lombok.Getter;

/**
 * 제공자 호출 실패 공통 예외: 상태 코드·응답 본문 일부 > 다음 연결 시도 여부 판정 재료 (#695)
 * statusCode null = 응답 없이 실패 (타임아웃·연결 오류·키 미설정)
 */
@Getter
public class AiProviderException extends RuntimeException {

    // 판정·로그에 남길 응답 본문 최대 길이
    private static final int RESPONSE_BODY_SNIPPET_MAXIMUM_LENGTH = 300;

    private final AiProvider provider;
    private final Integer statusCode;
    private final String responseBodySnippet;

    public AiProviderException(AiProvider provider, Integer statusCode, String responseBody, Throwable cause) {
        super(provider + " call failed" + (statusCode == null ? "" : " (" + statusCode + ")"), cause);
        this.provider = provider;
        this.statusCode = statusCode;
        this.responseBodySnippet = responseBody == null ? ""
                : responseBody.substring(0, Math.min(responseBody.length(), RESPONSE_BODY_SNIPPET_MAXIMUM_LENGTH));
    }

    /** 호출 기록 errorType: {제공자}_{상태 코드} 또는 {제공자}_NO_RESPONSE */
    public String toErrorType() {
        return provider + "_" + (statusCode == null ? "NO_RESPONSE" : statusCode);
    }
}
