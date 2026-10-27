package com.passql.ai.client;

import java.net.ConnectException;
import java.net.NoRouteToHostException;
import java.net.UnknownHostException;
import java.util.function.Predicate;

/**
 * AI 서버 호출 재시도 판정 (resilience4j retry aiServer, #699)
 * 재시도: 연결 자체 실패 3가지 (거부, 경로 없음, 호스트 모름) — 재배포 순간 등 요청이 서버에 닿지 않은 경우
 * 재시도 안 함: 서버 응답 오류(AI 서버가 LLM 일시 오류를 이미 재시도함), 읽기 시간 초과(LLM 호출이 이미 과금됐을 수 있음)
 */
public class AiServerRetryPredicate implements Predicate<Throwable> {

    @Override
    public boolean test(Throwable throwable) {
        for (Throwable cause = throwable; cause != null; cause = cause.getCause()) {
            if (isConnectionFailure(cause)) return true;
            if (cause.getCause() == cause) break;
        }
        return false;
    }

    private static boolean isConnectionFailure(Throwable cause) {
        return cause instanceof ConnectException
                || cause instanceof NoRouteToHostException
                || cause instanceof UnknownHostException;
    }
}
