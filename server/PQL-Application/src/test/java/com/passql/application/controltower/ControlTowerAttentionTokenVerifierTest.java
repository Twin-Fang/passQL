package com.passql.application.controltower;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 관제소 수집 토큰 판정 (#959): 현재·이전 토큰 허용, 설정 토큰 없으면 항상 거절
 */
class ControlTowerAttentionTokenVerifierTest {

    private static final String CURRENT_TOKEN = "current-token";
    private static final String PREVIOUS_TOKEN = "previous-token";

    @Test
    void 현재_토큰과_이전_토큰을_모두_허용한다() {
        ControlTowerAttentionTokenVerifier verifier = verifierOf(CURRENT_TOKEN, PREVIOUS_TOKEN);

        assertThat(verifier.isAcceptedToken(CURRENT_TOKEN)).isTrue();
        assertThat(verifier.isAcceptedToken(PREVIOUS_TOKEN)).isTrue();
        assertThat(verifier.hasConfiguredToken()).isTrue();
        assertThat(verifier.hasConfiguredPreviousToken()).isTrue();
    }

    @Test
    void 틀린_토큰과_빈_토큰은_거절한다() {
        ControlTowerAttentionTokenVerifier verifier = verifierOf(CURRENT_TOKEN, "");

        assertThat(verifier.isAcceptedToken("wrong-token")).isFalse();
        assertThat(verifier.isAcceptedToken(CURRENT_TOKEN + "x")).isFalse();
        assertThat(verifier.isAcceptedToken(null)).isFalse();
        assertThat(verifier.isAcceptedToken(" ")).isFalse();
        assertThat(verifier.hasConfiguredPreviousToken()).isFalse();
    }

    @Test
    void 서버에_토큰이_없으면_어떤_값도_거절한다() {
        ControlTowerAttentionTokenVerifier verifier = verifierOf("", null);

        assertThat(verifier.hasConfiguredToken()).isFalse();
        assertThat(verifier.isAcceptedToken("")).isFalse();
        assertThat(verifier.isAcceptedToken("anything")).isFalse();
    }

    private static ControlTowerAttentionTokenVerifier verifierOf(String token, String tokenPrevious) {
        return new ControlTowerAttentionTokenVerifier(
            new ControlTowerAttentionProperties(token, tokenPrevious, "https://admin.example"));
    }
}
