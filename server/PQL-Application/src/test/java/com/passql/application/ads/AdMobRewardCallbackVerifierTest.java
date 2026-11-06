package com.passql.application.ads;

import com.passql.common.exception.CustomException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.Signature;
import java.security.spec.ECGenParameterSpec;
import java.util.Base64;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * AdMob 서버 검증 콜백 서명 판정 (#860): 서명 대상 = "&signature=" 앞, 꼬리는 signature·key_id 만
 */
class AdMobRewardCallbackVerifierTest {

    // 테스트 공개키 key_id
    private static final long TEST_KEY_ID = 1234L;
    private static final String SIGNED_CONTENT = "ad_network=5450213213286189855&ad_unit=ca-app-pub-1%2F2"
        + "&custom_data=nonce-1&reward_amount=1&reward_item=bonus&timestamp=1730000000000"
        + "&transaction_id=tx-1&user_id=11111111-1111-1111-1111-111111111111";

    private KeyPair keyPair;
    private AdMobRewardCallbackVerifier verifier;

    @BeforeEach
    void setUp() throws Exception {
        KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance("EC");
        keyPairGenerator.initialize(new ECGenParameterSpec("secp256r1"));
        keyPair = keyPairGenerator.generateKeyPair();
        verifier = new AdMobRewardCallbackVerifier(
            keyId -> keyId == TEST_KEY_ID ? Optional.of(keyPair.getPublic()) : Optional.empty());
    }

    @Test
    void 올바른_서명이면_디코딩한_값을_돌려준다() throws Exception {
        AdMobRewardCallback callback = verifier.verify(signedQuery(SIGNED_CONTENT, TEST_KEY_ID));

        assertThat(callback.adUnit()).isEqualTo("ca-app-pub-1/2");
        assertThat(callback.userId()).isEqualTo("11111111-1111-1111-1111-111111111111");
        assertThat(callback.customData()).isEqualTo("nonce-1");
        assertThat(callback.transactionId()).isEqualTo("tx-1");
    }

    @Test
    void 서명_뒤_회원을_바꾸면_거부한다() throws Exception {
        String query = signedQuery(SIGNED_CONTENT, TEST_KEY_ID)
            .replace("user_id=11111111-1111-1111-1111-111111111111", "user_id=22222222-2222-2222-2222-222222222222");

        assertThatThrownBy(() -> verifier.verify(query)).isInstanceOf(CustomException.class);
    }

    @Test
    void 꼬리에_값을_덧붙이면_거부한다() throws Exception {
        String query = signedQuery(SIGNED_CONTENT, TEST_KEY_ID) + "&user_id=22222222-2222-2222-2222-222222222222";

        assertThatThrownBy(() -> verifier.verify(query)).isInstanceOf(CustomException.class);
    }

    @Test
    void 모르는_key_id_면_거부한다() throws Exception {
        String query = signedQuery(SIGNED_CONTENT, TEST_KEY_ID).replace("key_id=" + TEST_KEY_ID, "key_id=999");

        assertThatThrownBy(() -> verifier.verify(query)).isInstanceOf(CustomException.class);
    }

    @Test
    void 서명이_없으면_거부한다() {
        assertThatThrownBy(() -> verifier.verify(SIGNED_CONTENT)).isInstanceOf(CustomException.class);
    }

    /** 서명 대상 > ECDSA(DER) 서명 > 웹 안전 base64(패딩 없음) > "대상&signature=..&key_id=.." */
    private String signedQuery(String signedContent, long keyId) throws Exception {
        Signature signer = Signature.getInstance("SHA256withECDSA");
        signer.initSign(keyPair.getPrivate());
        signer.update(signedContent.getBytes(StandardCharsets.UTF_8));
        String signature = Base64.getUrlEncoder().withoutPadding().encodeToString(signer.sign());
        return signedContent + "&signature=" + signature + "&key_id=" + keyId;
    }
}
