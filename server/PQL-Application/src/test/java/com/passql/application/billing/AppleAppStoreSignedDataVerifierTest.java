package com.passql.application.billing;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * 실제 Apple 검증기: 루트 인증서 classpath 로드 확인, 형식이 틀린 JWS 는 500 이 아니라 400
 * (Apple 서명 실거래 샘플이 없어 성공 경로는 서비스 테스트의 가짜 검증기로 대신)
 */
class AppleAppStoreSignedDataVerifierTest {

    private final AppleAppStoreSignedDataVerifier verifier = new AppleAppStoreSignedDataVerifier();

    @Test
    void verifyTransaction_malformedJws_rejectedAsInvalidInput() {
        assertThatThrownBy(() -> verifier.verifyTransaction("not-a-jws"))
            .isInstanceOfSatisfying(CustomException.class,
                exception -> assertThat(exception.getErrorCode())
                    .isEqualTo(ErrorCode.INVALID_INPUT_VALUE));
    }

    @Test
    void verifyNotification_unsignedJws_rejectedAsInvalidInput() {
        // 서명 없는 JWT (alg none, x5c 없음)
        String unsignedJws = "eyJhbGciOiJub25lIn0.eyJub3RpZmljYXRpb25UeXBlIjoiUkVGVU5EIn0.";

        assertThatThrownBy(() -> verifier.verifyNotification(unsignedJws))
            .isInstanceOfSatisfying(CustomException.class,
                exception -> assertThat(exception.getErrorCode())
                    .isEqualTo(ErrorCode.INVALID_INPUT_VALUE));
    }
}
