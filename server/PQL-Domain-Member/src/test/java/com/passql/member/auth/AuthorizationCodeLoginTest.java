package com.passql.member.auth;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.auth.application.AuthService;
import com.passql.member.auth.application.AuthorizationCodeLoginService;
import com.passql.member.auth.application.dto.result.SocialLoginClientConfig;
import com.passql.member.auth.domain.ProviderTokens;
import com.passql.member.auth.infrastructure.social.SocialApiRestTemplates;
import com.passql.member.auth.infrastructure.social.oauth.AuthorizationCodeExchanger;
import com.passql.member.auth.infrastructure.social.oauth.SocialLoginProperties;
import com.passql.member.auth.infrastructure.social.oauth.SocialLoginProperties.ProviderClient;
import com.passql.member.constant.AuthProvider;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.content;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

/**
 * 인가 코드 로그인 (#509, #516): 설정·redirect URI 검증, 공개 설정에 secret 미포함, GitHub PKCE, 로컬 개발 redirect
 */
class AuthorizationCodeLoginTest {

    private static final String ALLOWED_REDIRECT_URI = "https://passql.vercel.app/auth/callback/github";
    private static final String LOCAL_REDIRECT_URI = "http://localhost:5173/auth/callback/github";
    private static final String GITHUB_TOKEN_URL = "https://github.com/login/oauth/access_token";
    private static final String NAVER_TOKEN_URL = "https://nid.naver.com/oauth2.0/token";

    private final SocialLoginProperties properties = new SocialLoginProperties(
            new ProviderClient(null, null, List.of()),
            new ProviderClient("naver-id", "naver-secret", List.of("https://passql.vercel.app/auth/callback/naver")),
            new ProviderClient("github-id", "github-secret", List.of(ALLOWED_REDIRECT_URI)));
    private final AuthorizationCodeExchanger exchanger = new AuthorizationCodeExchanger(properties);

    @Test
    void 설정이_없는_제공자는_준비_중으로_거절한다() {
        assertThatThrownBy(() -> exchanger.exchangeForTokens(AuthProvider.KAKAO, "code", "https://x", null, null))
                .isInstanceOf(CustomException.class)
                .extracting(e -> ((CustomException) e).getErrorCode())
                .isEqualTo(ErrorCode.SOCIAL_LOGIN_UNAVAILABLE);
    }

    @Test
    void 허용_목록_밖_redirect_URI_는_교환하지_않는다() {
        assertThatThrownBy(() -> exchanger.exchangeForTokens(AuthProvider.GITHUB, "code", "https://evil.example/cb", null, null))
                .isInstanceOf(CustomException.class)
                .extracting(e -> ((CustomException) e).getErrorCode())
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
    }

    @Test
    void 운영_기본_설정은_localhost_redirect_를_허용하지_않는다() {
        assertThatThrownBy(() -> exchanger.exchangeForTokens(AuthProvider.GITHUB, "code", LOCAL_REDIRECT_URI, null, null))
                .isInstanceOf(CustomException.class)
                .extracting(e -> ((CustomException) e).getErrorCode())
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
    }

    @Test
    void 로컬_개발용_redirect_목록을_주면_localhost_로_교환한다() {
        SocialLoginProperties localProperties = new SocialLoginProperties(
                properties.kakao(), properties.naver(), properties.github(), List.of(LOCAL_REDIRECT_URI));
        RestTemplate restTemplate = SocialApiRestTemplates.create();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo(GITHUB_TOKEN_URL))
                .andRespond(withSuccess("{\"access_token\":\"gho_local\"}", MediaType.APPLICATION_JSON));

        ProviderTokens tokens = new AuthorizationCodeExchanger(localProperties, restTemplate)
                .exchangeForTokens(AuthProvider.GITHUB, "code", LOCAL_REDIRECT_URI, null, null);

        assertThat(tokens.accessToken()).isEqualTo("gho_local");
    }

    @Test
    void 코드_방식이_아닌_제공자는_지원하지_않는다() {
        assertThatThrownBy(() -> exchanger.exchangeForTokens(AuthProvider.GOOGLE, "code", ALLOWED_REDIRECT_URI, null, null))
                .isInstanceOf(CustomException.class)
                .extracting(e -> ((CustomException) e).getErrorCode())
                .isEqualTo(ErrorCode.UNSUPPORTED_AUTH_PROVIDER);
    }

    @Test
    void GitHub_코드_교환에_PKCE_code_verifier_를_넘긴다() {
        RestTemplate restTemplate = SocialApiRestTemplates.create();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo(GITHUB_TOKEN_URL))
                .andExpect(content().formDataContains(Map.of("code", "code-1", "code_verifier", "verifier-abc")))
                .andRespond(withSuccess("{\"access_token\":\"gho_1\"}", MediaType.APPLICATION_JSON));

        new AuthorizationCodeExchanger(properties, restTemplate)
                .exchangeForTokens(AuthProvider.GITHUB, "code-1", ALLOWED_REDIRECT_URI, null, "verifier-abc");

        server.verify();
    }

    @Test
    void code_verifier_가_없으면_GitHub_요청에_넣지_않는다() {
        RestTemplate restTemplate = SocialApiRestTemplates.create();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo(GITHUB_TOKEN_URL))
                .andExpect(content().string(org.hamcrest.Matchers.not(org.hamcrest.Matchers.containsString("code_verifier"))))
                .andRespond(withSuccess("{\"access_token\":\"gho_2\"}", MediaType.APPLICATION_JSON));

        new AuthorizationCodeExchanger(properties, restTemplate)
                .exchangeForTokens(AuthProvider.GITHUB, "code-2", ALLOWED_REDIRECT_URI, null, null);

        server.verify();
    }

    @Test
    void 네이버_코드_교환은_refresh_token_도_돌려준다() {
        RestTemplate restTemplate = SocialApiRestTemplates.create();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo(NAVER_TOKEN_URL))
                .andRespond(withSuccess("{\"access_token\":\"naver-a\",\"refresh_token\":\"naver-r\"}", MediaType.APPLICATION_JSON));

        ProviderTokens tokens = new AuthorizationCodeExchanger(properties, restTemplate)
                .exchangeForTokens(AuthProvider.NAVER, "code", "https://passql.vercel.app/auth/callback/naver", "state", null);

        assertThat(tokens.accessToken()).isEqualTo("naver-a");
        assertThat(tokens.refreshToken()).isEqualTo("naver-r");
    }

    @Test
    void 코드_로그인은_교환한_토큰으로_서버_교환_로그인을_한다() {
        AuthorizationCodeExchanger mockExchanger = mock(AuthorizationCodeExchanger.class);
        AuthService authService = mock(AuthService.class);
        ProviderTokens exchanged = new ProviderTokens("gho_x", null);
        org.mockito.Mockito.when(mockExchanger.exchangeForTokens(AuthProvider.GITHUB, "c", ALLOWED_REDIRECT_URI, null, "v"))
                .thenReturn(exchanged);

        new AuthorizationCodeLoginService(mockExchanger, authService)
                .login(AuthProvider.GITHUB, "c", ALLOWED_REDIRECT_URI, null, "v");

        verify(authService).loginWithExchangedTokens(AuthProvider.GITHUB, exchanged);
    }

    @Test
    void 공개_설정은_사용_여부와_client_ID_만_내려준다() {
        AuthorizationCodeLoginService service = new AuthorizationCodeLoginService(exchanger, mock(AuthService.class));

        List<SocialLoginClientConfig> configs = service.getClientConfigs();

        assertThat(configs).extracting(SocialLoginClientConfig::authProvider)
                .containsExactly(AuthProvider.KAKAO, AuthProvider.NAVER, AuthProvider.GITHUB);
        assertThat(configs.get(0).isEnabled()).isFalse();
        assertThat(configs.get(0).clientId()).isNull();
        assertThat(configs.get(2).isEnabled()).isTrue();
        assertThat(configs.get(2).clientId()).isEqualTo("github-id");
        assertThat(configs.toString()).doesNotContain("secret");
    }
}
