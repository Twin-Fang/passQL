package com.passql.member.auth.infrastructure.social.oauth;

import org.junit.jupiter.api.Test;
import org.springframework.boot.context.properties.bind.Binder;
import org.springframework.boot.context.properties.source.MapConfigurationPropertySource;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * social-login 설정 바인딩 (#516): 새 키(app-id, admin-key, allowed-client-ids, local-redirect-uris), 빈 환경변수 > 빈 목록
 */
class SocialLoginPropertiesBindingTest {

    @Test
    void 새_설정_키를_읽고_빈_값은_빈_목록이_된다() {
        // application.yml 의 ${ENV:} 빈 기본값과 같은 상태
        Map<String, String> source = Map.of(
                "social-login.local-redirect-uris", "",
                "social-login.kakao.client-id", "kakao-rest",
                "social-login.kakao.app-id", "1000001",
                "social-login.kakao.admin-key", "test-admin",
                "social-login.naver.client-id", "naver-web",
                "social-login.naver.allowed-client-ids", "naver-web,naver-app",
                "social-login.github.client-id", "github-id",
                "social-login.github.allowed-redirect-uris[0]", "https://passql.vercel.app/auth/callback/github");

        SocialLoginProperties properties = new Binder(new MapConfigurationPropertySource(source))
                .bind("social-login", SocialLoginProperties.class).get();

        assertThat(properties.localRedirectUris()).isEmpty();
        assertThat(properties.isLocalRedirectUri("http://localhost:5173/auth/callback/github")).isFalse();
        assertThat(properties.kakao().appId()).isEqualTo("1000001");
        assertThat(properties.kakao().hasAdminKey()).isTrue();
        assertThat(properties.naver().isAllowedClientId("naver-app")).isTrue();
        assertThat(properties.naver().isAllowedClientId("other")).isFalse();
        assertThat(properties.github().isAllowedRedirectUri("https://passql.vercel.app/auth/callback/github")).isTrue();
    }
}
