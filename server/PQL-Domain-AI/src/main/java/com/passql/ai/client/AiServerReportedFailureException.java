package com.passql.ai.client;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;

/**
 * AI 서버가 정상 동작 중 응답으로 알린 실패 (입력 오류·LLM 실패·LLM 응답 형식 오류, #877)
 * 대체 호출 없음(AiGatewayClient 대체 메서드가 그대로 던짐), 서킷 실패 집계 제외(application.yml ignore-exceptions), 재시도 없음
 */
public class AiServerReportedFailureException extends CustomException {

    public AiServerReportedFailureException(ErrorCode errorCode, String detail, Throwable cause) {
        super(errorCode, detail, cause);
    }
}
