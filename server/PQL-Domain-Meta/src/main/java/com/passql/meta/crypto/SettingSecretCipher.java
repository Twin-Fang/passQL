package com.passql.meta.crypto;

import com.passql.common.crypto.SecretValueCipher;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.util.Arrays;
import java.util.Base64;

/**
 * 설정 비밀값 암호화: AES-256-GCM, 저장 형식 enc:v1:{base64(nonce ‖ 암호문 ‖ tag)}
 * AAD = setting_key (다른 키 행으로 옮긴 값은 복호화 실패), AI 서버(Python)와 같은 형식
 */
@Slf4j
@Component
public class SettingSecretCipher implements SecretValueCipher {

    // 암호문 접두사 (없으면 전환 전 평문)
    public static final String ENCRYPTED_PREFIX = "enc:v1:";

    private static final String TRANSFORMATION = "AES/GCM/NoPadding";
    private static final int MASTER_KEY_BYTES = 32;
    private static final int NONCE_BYTES = 12;
    private static final int TAG_BITS = 128;

    private final SecretKeySpec masterKey;
    private final SecureRandom secureRandom = new SecureRandom();

    public SettingSecretCipher(@Value("${passql.setting-encryption-key:}") String base64MasterKey) {
        this.masterKey = parseMasterKey(base64MasterKey);
    }

    /** 평문 > enc:v1:... (호출마다 nonce 새로 생성) */
    @Override
    public String encrypt(String settingKey, String plainValue) {
        try {
            byte[] nonce = new byte[NONCE_BYTES];
            secureRandom.nextBytes(nonce);
            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            cipher.init(Cipher.ENCRYPT_MODE, masterKey, new GCMParameterSpec(TAG_BITS, nonce));
            cipher.updateAAD(settingKey.getBytes(StandardCharsets.UTF_8));
            byte[] cipherAndTag = cipher.doFinal(plainValue.getBytes(StandardCharsets.UTF_8));

            byte[] payload = new byte[NONCE_BYTES + cipherAndTag.length];
            System.arraycopy(nonce, 0, payload, 0, NONCE_BYTES);
            System.arraycopy(cipherAndTag, 0, payload, NONCE_BYTES, cipherAndTag.length);
            return ENCRYPTED_PREFIX + Base64.getEncoder().encodeToString(payload);
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException("setting secret encrypt failed", e);
        }
    }

    /** enc:v1:... > 평문 (형식 오류·변조·AAD 불일치는 SETTING_SECRET_DECRYPT_FAILED) */
    @Override
    public String decrypt(String settingKey, String storedValue) {
        try {
            if (!isEncrypted(storedValue)) {
                throw new IllegalArgumentException("not an encrypted value");
            }
            byte[] payload = Base64.getDecoder().decode(storedValue.substring(ENCRYPTED_PREFIX.length()));
            byte[] nonce = Arrays.copyOfRange(payload, 0, NONCE_BYTES);
            byte[] cipherAndTag = Arrays.copyOfRange(payload, NONCE_BYTES, payload.length);

            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            cipher.init(Cipher.DECRYPT_MODE, masterKey, new GCMParameterSpec(TAG_BITS, nonce));
            cipher.updateAAD(settingKey.getBytes(StandardCharsets.UTF_8));
            return new String(cipher.doFinal(cipherAndTag), StandardCharsets.UTF_8);
        } catch (GeneralSecurityException | IllegalArgumentException e) {
            // 값은 로그에 남기지 않음 (키 이름만)
            log.error("[setting secret] decrypt failed : key={}", settingKey);
            throw new CustomException(ErrorCode.SETTING_SECRET_DECRYPT_FAILED);
        }
    }

    public static boolean isEncrypted(String storedValue) {
        return storedValue != null && storedValue.startsWith(ENCRYPTED_PREFIX);
    }

    /** 마스터 키 검증 (base64, 32바이트) — 틀리면 기동 실패 */
    private static SecretKeySpec parseMasterKey(String base64MasterKey) {
        if (base64MasterKey == null || base64MasterKey.isBlank()) {
            throw new IllegalStateException("passql.setting-encryption-key is not configured");
        }
        byte[] keyBytes;
        try {
            keyBytes = Base64.getDecoder().decode(base64MasterKey.trim());
        } catch (IllegalArgumentException e) {
            throw new IllegalStateException("passql.setting-encryption-key is not valid base64");
        }
        if (keyBytes.length != MASTER_KEY_BYTES) {
            throw new IllegalStateException("passql.setting-encryption-key must be " + MASTER_KEY_BYTES + " bytes");
        }
        return new SecretKeySpec(keyBytes, "AES");
    }
}
