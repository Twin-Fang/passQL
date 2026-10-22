package com.passql.common.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;

/**
 * 문자열 > SHA-256 소문자 hex 64자 (UTF-8 바이트 기준, 중복 판별·캐시 키·식별값 가림용)
 */
public final class Sha256Hex {

    private Sha256Hex() {
    }

    /** 문자열 > SHA-256 소문자 hex 64자 (JVM 에 SHA-256 없으면 IllegalStateException) */
    public static String of(String value) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 unavailable", exception);
        }
    }
}
