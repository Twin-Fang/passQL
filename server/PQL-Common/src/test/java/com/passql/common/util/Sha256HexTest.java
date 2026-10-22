package com.passql.common.util;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * SHA-256 hex: UTF-8 입력 > 소문자 hex 64자 (shasum -a 256 고정 벡터)
 */
class Sha256HexTest {

    @Test
    void of_matchesFixedVectors() {
        // 결제 계정 대조 벡터 (앱 테스트와 같은 값)
        assertThat(Sha256Hex.of("123e4567-e89b-12d3-a456-426614174000"))
            .isEqualTo("986c0dc956dc822b5d8f698661b9eb1ef880786ff9043c16744d2a420e99e9bb");
        // 비ASCII 는 UTF-8 바이트 기준
        assertThat(Sha256Hex.of("한글"))
            .isEqualTo("bd87f9bb68b67d2fa1cb82b6751820e946d5b1316d25d5fd96512fb4be44a2a8");
    }
}
