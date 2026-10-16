package com.passql.meta.crypto;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import org.junit.jupiter.api.Test;

import java.util.Base64;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/** 설정 비밀값 암호화 (#492): 왕복, AAD 바인딩, 변조, 마스터 키 검증 */
public class SettingSecretCipherTest {

    // 테스트 전용 마스터 키 (0x00..0x1f 32바이트)
    public static final String TEST_MASTER_KEY = Base64.getEncoder().encodeToString(testKeyBytes());
    // Python 테스트(ai/tests/test_setting_secret_cipher.py)와 공유하는 고정 벡터
    static final String FIXED_VECTOR_KEY = "ai.gemini_api_key";
    static final String FIXED_VECTOR_PLAIN = "AIza-test-key-123";
    static final String FIXED_VECTOR_STORED = "enc:v1:AAECAwQFBgcICQoLBkuseuiRp2j5bPzuyMRJX7AOJnAIWX9Qw4vxeETP6FHO";

    private final SettingSecretCipher cipher = new SettingSecretCipher(TEST_MASTER_KEY);

    @Test
    void 암호화_후_복호화하면_원문() {
        String stored = cipher.encrypt("ai.gemini_api_key", "AIza-secret");

        assertThat(stored).startsWith("enc:v1:").doesNotContain("AIza-secret");
        assertThat(cipher.decrypt("ai.gemini_api_key", stored)).isEqualTo("AIza-secret");
    }

    @Test
    void 같은_원문도_매번_다른_암호문() {
        assertThat(cipher.encrypt("k", "v")).isNotEqualTo(cipher.encrypt("k", "v"));
    }

    @Test
    void 다른_setting_key로_복호화하면_거부() {
        String stored = cipher.encrypt("ai.gemini_api_key", "AIza-secret");

        assertThatThrownBy(() -> cipher.decrypt("other.api_key", stored))
                .isInstanceOf(CustomException.class)
                .extracting(e -> ((CustomException) e).getErrorCode())
                .isEqualTo(ErrorCode.SETTING_SECRET_DECRYPT_FAILED);
    }

    @Test
    void 변조된_암호문은_거부() {
        String stored = cipher.encrypt("k", "value");
        byte[] payload = Base64.getDecoder().decode(stored.substring("enc:v1:".length()));
        payload[payload.length - 1] ^= 0x01;
        String tampered = "enc:v1:" + Base64.getEncoder().encodeToString(payload);

        assertThatThrownBy(() -> cipher.decrypt("k", tampered)).isInstanceOf(CustomException.class);
    }

    @Test
    void 접두사_없는_값은_암호문이_아님() {
        assertThat(SettingSecretCipher.isEncrypted("plain")).isFalse();
        assertThat(SettingSecretCipher.isEncrypted(null)).isFalse();
        assertThat(SettingSecretCipher.isEncrypted(cipher.encrypt("k", "v"))).isTrue();
    }

    @Test
    void 마스터_키가_없거나_형식이_틀리면_생성_실패() {
        assertThatThrownBy(() -> new SettingSecretCipher("")).isInstanceOf(IllegalStateException.class);
        assertThatThrownBy(() -> new SettingSecretCipher("not-base64!!")).isInstanceOf(IllegalStateException.class);
        assertThatThrownBy(() -> new SettingSecretCipher(Base64.getEncoder().encodeToString(new byte[16])))
                .isInstanceOf(IllegalStateException.class);
    }

    @Test
    void 고정_벡터는_복호화됨() {
        assertThat(cipher.decrypt(FIXED_VECTOR_KEY, FIXED_VECTOR_STORED)).isEqualTo(FIXED_VECTOR_PLAIN);
    }

    private static byte[] testKeyBytes() {
        byte[] bytes = new byte[32];
        for (int i = 0; i < bytes.length; i++) bytes[i] = (byte) i;
        return bytes;
    }
}
