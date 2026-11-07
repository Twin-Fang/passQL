package com.passql.member.auth.infrastructure.social.strategy;

import com.passql.member.auth.domain.SocialProfile;
import com.passql.member.constant.AuthProvider;

public interface SocialLoginStrategy {

    /** idToken(또는 accessToken) 검증 > 제공자 사용자 ID + 이메일·프로필 이미지 (동의 안 했으면 null, #908) */
    SocialProfile fetchSocialProfile(String idToken);

    AuthProvider getAuthProvider();

    /**
     * 클라이언트가 보낸 토큰의 발급 앱 검증 (#516): 다른 앱 토큰이면 INVALID_SOCIAL_TOKEN
     * 서버가 직접 교환한 토큰은 호출하지 않음, 기본: 검증 없음 (Firebase 는 fetchSocialProfile 안에서 확인)
     */
    default void verifyIssuedForThisApp(String providerAccessToken) {
    }
}
