package com.passql.common.crypto;

/**
 * 비밀값 암호화 공통 계약: 평문 > 저장 형식, 저장 형식 > 평문
 * 구현은 PQL-Domain-Meta SettingSecretCipher (AES-256-GCM, associatedData = AAD)
 */
public interface SecretValueCipher {

    /** 평문 > 암호문 (associatedData 가 다르면 복호화 불가) */
    String encrypt(String associatedData, String plainValue);

    /** 암호문 > 평문 (형식 오류·변조·associatedData 불일치는 예외) */
    String decrypt(String associatedData, String storedValue);
}
