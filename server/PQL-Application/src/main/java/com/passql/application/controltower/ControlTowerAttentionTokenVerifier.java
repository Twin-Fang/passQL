package com.passql.application.controltower;

import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.List;
import java.util.stream.Stream;

/**
 * 관제소 수집 토큰 검증: 현재·이전 토큰 2개와 상수 시간 비교 (설정 토큰이 하나도 없으면 항상 거절)
 */
@Component
public class ControlTowerAttentionTokenVerifier {

    private final List<byte[]> acceptedTokens;

    public ControlTowerAttentionTokenVerifier(ControlTowerAttentionProperties properties) {
        this.acceptedTokens = Stream.of(properties.token(), properties.tokenPrevious())
            .filter(ControlTowerAttentionTokenVerifier::hasText)
            .map(token -> token.getBytes(StandardCharsets.UTF_8))
            .toList();
    }

    /** 요청 헤더 토큰 <-> 허용 토큰 (일치해도 끝까지 비교) */
    public boolean isAcceptedToken(String presentedToken) {
        if (!hasText(presentedToken)) {
            return false;
        }
        byte[] presentedBytes = presentedToken.getBytes(StandardCharsets.UTF_8);
        boolean isMatched = false;
        for (byte[] acceptedToken : acceptedTokens) {
            isMatched |= MessageDigest.isEqual(acceptedToken, presentedBytes);
        }
        return isMatched;
    }

    public boolean hasConfiguredToken() {
        return !acceptedTokens.isEmpty();
    }

    public boolean hasConfiguredPreviousToken() {
        return acceptedTokens.size() > 1;
    }

    private static boolean hasText(String value) {
        return value != null && !value.isBlank();
    }
}
