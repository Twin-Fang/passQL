package com.passql.member.auth.domain;

/**
 * 소셜 제공자 토큰 쌍: access token, refresh token (없으면 null)
 * toString 에 값 미노출 (로그 유출 방지)
 */
public record ProviderTokens(String accessToken, String refreshToken) {

    public boolean hasRefreshToken() {
        return refreshToken != null && !refreshToken.isBlank();
    }

    @Override
    public String toString() {
        return "ProviderTokens[accessToken=***, refreshToken=" + (hasRefreshToken() ? "***" : "null") + "]";
    }
}
