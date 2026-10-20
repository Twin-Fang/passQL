package com.passql.ai.constant;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/** 실패 원인 분류 (#557): error_type 문자열 > 4종 */
class AiFailureCategoryTest {

    @Test
    void 한도_초과는_QUOTA_EXCEEDED() {
        assertThat(AiFailureCategory.fromErrorType("GEMINI_QUOTA_EXCEEDED")).isEqualTo(AiFailureCategory.QUOTA_EXCEEDED);
        assertThat(AiFailureCategory.fromErrorType("429")).isEqualTo(AiFailureCategory.QUOTA_EXCEEDED);
        assertThat(AiFailureCategory.fromErrorType("RESOURCE_EXHAUSTED")).isEqualTo(AiFailureCategory.QUOTA_EXCEEDED);
    }

    @Test
    void 권한_결제_문제는_PERMISSION_DENIED() {
        assertThat(AiFailureCategory.fromErrorType("GEMINI_PERMISSION_DENIED")).isEqualTo(AiFailureCategory.PERMISSION_DENIED);
        assertThat(AiFailureCategory.fromErrorType("401")).isEqualTo(AiFailureCategory.PERMISSION_DENIED);
        assertThat(AiFailureCategory.fromErrorType("HTTP 403")).isEqualTo(AiFailureCategory.PERMISSION_DENIED);
    }

    @Test
    void 연결_실패_시간_초과_5xx는_TIMEOUT_OR_SERVER_ERROR() {
        assertThat(AiFailureCategory.fromErrorType("AI_SERVER_UNAVAILABLE")).isEqualTo(AiFailureCategory.TIMEOUT_OR_SERVER_ERROR);
        assertThat(AiFailureCategory.fromErrorType("AI_UNAVAILABLE")).isEqualTo(AiFailureCategory.TIMEOUT_OR_SERVER_ERROR);
        assertThat(AiFailureCategory.fromErrorType("SocketTimeoutException")).isEqualTo(AiFailureCategory.TIMEOUT_OR_SERVER_ERROR);
        assertThat(AiFailureCategory.fromErrorType("GenAiIOException")).isEqualTo(AiFailureCategory.TIMEOUT_OR_SERVER_ERROR);
        assertThat(AiFailureCategory.fromErrorType("ResourceAccessException")).isEqualTo(AiFailureCategory.TIMEOUT_OR_SERVER_ERROR);
        assertThat(AiFailureCategory.fromErrorType("503")).isEqualTo(AiFailureCategory.TIMEOUT_OR_SERVER_ERROR);
    }

    @Test
    void 모르는_값과_빈_값은_OTHER() {
        assertThat(AiFailureCategory.fromErrorType("IllegalStateException")).isEqualTo(AiFailureCategory.OTHER);
        assertThat(AiFailureCategory.fromErrorType("1500")).isEqualTo(AiFailureCategory.OTHER);
        assertThat(AiFailureCategory.fromErrorType(null)).isEqualTo(AiFailureCategory.OTHER);
        assertThat(AiFailureCategory.fromErrorType(" ")).isEqualTo(AiFailureCategory.OTHER);
    }
}
