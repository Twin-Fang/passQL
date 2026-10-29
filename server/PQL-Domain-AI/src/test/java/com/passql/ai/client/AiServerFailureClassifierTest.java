package com.passql.ai.client;

import com.fasterxml.jackson.core.JsonParseException;
import com.passql.ai.constant.AiFailureCategory;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.ResourceAccessException;

import java.net.ConnectException;
import java.net.SocketTimeoutException;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * AI 서버 호출 실패 세부 원인 판정과 대시보드 분류 연결 (#575)
 */
class AiServerFailureClassifierTest {

    @Test
    void 요청_검증_거절은_상태_코드로_기록한다() {
        String failureType = AiServerFailureClassifier.toFailureType(
                wrapAsGatewayFailure(HttpClientErrorException.create(HttpStatus.UNPROCESSABLE_ENTITY, "", null, null, null)));

        assertThat(failureType).isEqualTo("AI_SERVER_HTTP_422");
        assertThat(AiFailureCategory.fromErrorType(failureType)).isEqualTo(AiFailureCategory.OTHER);
    }

    @Test
    void 서버_오류는_5xx_분류로_묶인다() {
        String failureType = AiServerFailureClassifier.toFailureType(
                wrapAsGatewayFailure(HttpServerErrorException.create(HttpStatus.INTERNAL_SERVER_ERROR, "", null, null, null)));

        assertThat(failureType).isEqualTo("AI_SERVER_HTTP_500");
        assertThat(AiFailureCategory.fromErrorType(failureType)).isEqualTo(AiFailureCategory.TIMEOUT_OR_SERVER_ERROR);
    }

    @Test
    void 연결_실패와_시간_초과를_구분한다() {
        String connectionFailure = AiServerFailureClassifier.toFailureType(
                wrapAsGatewayFailure(new ResourceAccessException("I/O error", new ConnectException("refused"))));
        String timeout = AiServerFailureClassifier.toFailureType(
                wrapAsGatewayFailure(new ResourceAccessException("I/O error", new SocketTimeoutException("read timed out"))));

        assertThat(connectionFailure).isEqualTo(AiServerFailureClassifier.CONNECTION_FAILED);
        assertThat(timeout).isEqualTo(AiServerFailureClassifier.TIMEOUT);
        assertThat(AiFailureCategory.fromErrorType(connectionFailure)).isEqualTo(AiFailureCategory.TIMEOUT_OR_SERVER_ERROR);
    }

    @Test
    void 응답_파싱_실패와_원인_모름을_구분한다() {
        assertThat(AiServerFailureClassifier.toFailureType(wrapAsGatewayFailure(new JsonParseException(null, "bad json"))))
                .isEqualTo(AiServerFailureClassifier.RESPONSE_PARSE_FAILED);
        assertThat(AiServerFailureClassifier.toFailureType(new CustomException(ErrorCode.AI_SERVER_UNAVAILABLE)))
                .isNull();
    }

    // AiGatewayClient.exchangeWithPython 이 던지는 형태 (CustomException + 원인)
    private static CustomException wrapAsGatewayFailure(Throwable cause) {
        return new CustomException(ErrorCode.AI_SERVER_UNAVAILABLE, "Python AI 서버 호출 실패", cause);
    }
}
