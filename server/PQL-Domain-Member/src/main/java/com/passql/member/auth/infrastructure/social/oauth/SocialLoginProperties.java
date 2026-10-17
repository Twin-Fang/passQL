package com.passql.member.auth.infrastructure.social.oauth;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.context.properties.bind.ConstructorBinding;

import java.util.List;

/**
 * 소셜 로그인 제공자 설정 3개: 카카오, 네이버, GitHub (#509, #516)
 * client-id 가 비어 있으면 그 제공자는 "준비 중"으로 취급한다. secret·admin-key 는 서버에만 둔다.
 * 예: social-login.kakao.client-id / client-secret / allowed-redirect-uris / app-id / admin-key
 * local-redirect-uris: 로컬 개발 웹 콜백 (dev 프로필에서만 채움, 운영은 빈 목록)
 */
@ConfigurationProperties(prefix = "social-login")
public record SocialLoginProperties(ProviderClient kakao, ProviderClient naver, ProviderClient github,
                                    List<String> localRedirectUris) {

    @ConstructorBinding
    public SocialLoginProperties {
    }

    public SocialLoginProperties(ProviderClient kakao, ProviderClient naver, ProviderClient github) {
        this(kakao, naver, github, List.of());
    }

    /** 로컬 개발용 redirect URI 인지 (운영 기본값은 빈 목록이라 항상 false) */
    public boolean isLocalRedirectUri(String redirectUri) {
        return localRedirectUris != null && localRedirectUris.contains(redirectUri);
    }

    /**
     * 제공자 1개: 공개 client ID, 비밀 client secret, 허용 redirect URI 목록
     * appId·adminKey: 카카오 토큰 출처 검증·연결 끊기, allowedClientIds: 네이버 토큰 출처 검증 (비면 clientId 만)
     */
    public record ProviderClient(String clientId, String clientSecret, List<String> allowedRedirectUris,
                                 String appId, String adminKey, List<String> allowedClientIds) {

        @ConstructorBinding
        public ProviderClient {
        }

        public ProviderClient(String clientId, String clientSecret, List<String> allowedRedirectUris) {
            this(clientId, clientSecret, allowedRedirectUris, null, null, List.of());
        }

        /** client ID 가 설정돼 있는지 (없으면 준비 중) */
        public boolean isConfigured() {
            return clientId != null && !clientId.isBlank();
        }

        /** redirect URI 가 허용 목록에 있는지 (가로챈 코드를 다른 주소로 교환하지 못하게) */
        public boolean isAllowedRedirectUri(String redirectUri) {
            return allowedRedirectUris != null && allowedRedirectUris.contains(redirectUri);
        }

        /** 앱 ID 설정 여부 (카카오 토큰 출처 검증 가능 여부) */
        public boolean hasAppId() {
            return appId != null && !appId.isBlank();
        }

        /** 관리자 키 설정 여부 (카카오 서버 연결 끊기 가능 여부) */
        public boolean hasAdminKey() {
            return adminKey != null && !adminKey.isBlank();
        }

        /** 토큰 발급 client ID 허용 여부 (허용 목록 없으면 clientId 와 비교) */
        public boolean isAllowedClientId(String tokenClientId) {
            if (tokenClientId == null || tokenClientId.isBlank()) {
                return false;
            }
            if (allowedClientIds != null && !allowedClientIds.isEmpty()) {
                return allowedClientIds.contains(tokenClientId);
            }
            return tokenClientId.equals(clientId);
        }
    }
}
