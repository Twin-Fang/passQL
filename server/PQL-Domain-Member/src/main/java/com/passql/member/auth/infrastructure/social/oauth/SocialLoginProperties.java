package com.passql.member.auth.infrastructure.social.oauth;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.List;

/**
 * 인가 코드 로그인 제공자 설정 3개: 카카오, 네이버, GitHub (#509)
 * client-id 가 비어 있으면 그 제공자는 "준비 중"으로 취급한다. secret 은 서버에만 둔다.
 * 예: social-login.kakao.client-id / client-secret / allowed-redirect-uris
 */
@ConfigurationProperties(prefix = "social-login")
public record SocialLoginProperties(ProviderClient kakao, ProviderClient naver, ProviderClient github) {

    /** 제공자 1개: 공개 client ID, 비밀 client secret, 허용 redirect URI 목록 */
    public record ProviderClient(String clientId, String clientSecret, List<String> allowedRedirectUris) {

        /** client ID 가 설정돼 있는지 (없으면 준비 중) */
        public boolean isConfigured() {
            return clientId != null && !clientId.isBlank();
        }

        /** redirect URI 가 허용 목록에 있는지 (가로챈 코드를 다른 주소로 교환하지 못하게) */
        public boolean isAllowedRedirectUri(String redirectUri) {
            return allowedRedirectUris != null && allowedRedirectUris.contains(redirectUri);
        }
    }
}
