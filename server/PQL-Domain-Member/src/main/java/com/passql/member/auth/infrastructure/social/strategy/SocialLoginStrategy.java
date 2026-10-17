package com.passql.member.auth.infrastructure.social.strategy;

import com.passql.member.constant.AuthProvider;

public interface SocialLoginStrategy {

    /** idToken(또는 accessToken)을 검증하고 provider의 고유 사용자 ID를 반환한다. */
    String validateAndGetSocialId(String idToken);

    AuthProvider getAuthProvider();

    /**
     * 클라이언트가 보낸 토큰의 발급 앱 검증 (#516): 다른 앱 토큰이면 INVALID_SOCIAL_TOKEN
     * 서버가 직접 교환한 토큰은 호출하지 않음, 기본: 검증 없음 (Firebase 는 validateAndGetSocialId 안에서 확인)
     */
    default void verifyIssuedForThisApp(String providerAccessToken) {
    }
}
