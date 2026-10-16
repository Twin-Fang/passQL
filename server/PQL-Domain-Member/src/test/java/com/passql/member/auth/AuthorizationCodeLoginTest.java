package com.passql.member.auth;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.auth.application.AuthService;
import com.passql.member.auth.application.AuthorizationCodeLoginService;
import com.passql.member.auth.application.dto.result.SocialLoginClientConfig;
import com.passql.member.auth.infrastructure.social.oauth.AuthorizationCodeExchanger;
import com.passql.member.auth.infrastructure.social.oauth.SocialLoginProperties;
import com.passql.member.auth.infrastructure.social.oauth.SocialLoginProperties.ProviderClient;
import com.passql.member.constant.AuthProvider;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;

/**
 * 인가 코드 로그인 (#509): 설정·redirect URI 검증, 공개 설정에 secret 미포함
 */
class AuthorizationCodeLoginTest {

    private static final String ALLOWED_REDIRECT_URI = "https://passql.vercel.app/auth/callback/github";

    private final SocialLoginProperties properties = new SocialLoginProperties(
            new ProviderClient(null, null, List.of()),
            new ProviderClient("naver-id", "naver-secret", List.of("https://passql.vercel.app/auth/callback/naver")),
            new ProviderClient("github-id", "github-secret", List.of(ALLOWED_REDIRECT_URI)));
    private final AuthorizationCodeExchanger exchanger = new AuthorizationCodeExchanger(properties);

    @Test
    void 설정이_없는_제공자는_준비_중으로_거절한다() {
        assertThatThrownBy(() -> exchanger.exchangeForAccessToken(AuthProvider.KAKAO, "code", "https://x", null))
                .isInstanceOf(CustomException.class)
                .extracting(e -> ((CustomException) e).getErrorCode())
                .isEqualTo(ErrorCode.SOCIAL_LOGIN_UNAVAILABLE);
    }

    @Test
    void 허용_목록_밖_redirect_URI_는_교환하지_않는다() {
        assertThatThrownBy(() -> exchanger.exchangeForAccessToken(AuthProvider.GITHUB, "code", "https://evil.example/cb", null))
                .isInstanceOf(CustomException.class)
                .extracting(e -> ((CustomException) e).getErrorCode())
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
    }

    @Test
    void 코드_방식이_아닌_제공자는_지원하지_않는다() {
        assertThatThrownBy(() -> exchanger.exchangeForAccessToken(AuthProvider.GOOGLE, "code", ALLOWED_REDIRECT_URI, null))
                .isInstanceOf(CustomException.class)
                .extracting(e -> ((CustomException) e).getErrorCode())
                .isEqualTo(ErrorCode.UNSUPPORTED_AUTH_PROVIDER);
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
