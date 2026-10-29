package com.passql.member.auth.infrastructure.social;

/**
 * 여러 소셜 연동 클래스가 함께 쓰는 제공자 엔드포인트 URL
 * 코드 교환(AuthorizationCodeExchanger)·연결 해제(SocialUnlinkClient) 공통
 */
public final class SocialProviderEndpoints {

    // 네이버 토큰 엔드포인트: 코드 교환·토큰 갱신·토큰 삭제(grant_type 으로 구분)
    public static final String NAVER_TOKEN_URL = "https://nid.naver.com/oauth2.0/token";

    private SocialProviderEndpoints() {
    }
}
