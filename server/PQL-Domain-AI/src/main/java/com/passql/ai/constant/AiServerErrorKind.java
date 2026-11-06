package com.passql.ai.constant;

import com.passql.common.exception.constant.ErrorCode;

import java.util.Arrays;

/**
 * AI 서버 실패 응답 본문 error_kind 4종 (AI 서버 ErrorKind 와 같은 이름, ai/tests/snapshots/error_kinds.json 고정, #877)
 * AI 서버가 직접 판정한 실패 3종 > 대체 호출·서킷 실패 없이 해당 ErrorCode, 그 외 > AI 서버 장애(대체 호출)
 */
public enum AiServerErrorKind {

    // 요청 형식 오류 (LLM 호출 전 거부)
    INVALID_REQUEST(ErrorCode.AI_SERVER_REQUEST_REJECTED),
    // LLM 연결 전부 실패·시간 상한 초과 (같은 연결 목록이라 직접 호출해도 같은 결과)
    LLM_UNAVAILABLE(ErrorCode.AI_UNAVAILABLE),
    // LLM 응답 형식 오류 (이미 과금됨, 선택지 생성은 새 시도로 재시도)
    LLM_RESPONSE_INVALID(ErrorCode.AI_STRUCTURED_SCHEMA_VIOLATION),
    // AI 서버 내부 오류 > 장애로 보고 대체 호출
    INTERNAL_ERROR(null);

    // AI 서버가 판정한 실패의 ErrorCode (null = AI 서버 장애)
    private final ErrorCode reportedErrorCode;

    AiServerErrorKind(ErrorCode reportedErrorCode) {
        this.reportedErrorCode = reportedErrorCode;
    }

    /** 응답 본문 값 > 종류 (없거나 모르는 값 > INTERNAL_ERROR) */
    public static AiServerErrorKind fromResponseValue(String responseValue) {
        return Arrays.stream(values())
                .filter(kind -> kind.name().equals(responseValue))
                .findFirst()
                .orElse(INTERNAL_ERROR);
    }

    /** AI 서버가 정상 동작 중 판정한 실패인지 (대체 호출·서킷 실패 집계 제외) */
    public boolean isReportedByHealthyAiServer() {
        return reportedErrorCode != null;
    }

    public ErrorCode getReportedErrorCode() {
        return reportedErrorCode;
    }
}
