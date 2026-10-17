package com.passql.member.auth.application;

import com.passql.member.auth.application.dto.result.LoginResult;
import com.passql.member.auth.application.dto.result.SocialLoginClientConfig;
import com.passql.member.auth.domain.ProviderTokens;
import com.passql.member.auth.infrastructure.social.oauth.AuthorizationCodeExchanger;
import com.passql.member.auth.infrastructure.social.oauth.SocialLoginProperties;
import com.passql.member.constant.AuthProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 인가 코드 로그인 (#509): 코드 > 제공자 access token 교환(트랜잭션 밖) > 기존 소셜 로그인
 * 카카오·네이버·GitHub 웹 로그인과 GitHub 앱 로그인이 쓴다.
 */
@Service
@RequiredArgsConstructor
public class AuthorizationCodeLoginService {

    private final AuthorizationCodeExchanger authorizationCodeExchanger;
    private final AuthService authService;

    /** 코드 > 제공자 토큰 교환(codeVerifier: GitHub PKCE, 선택) > 서버 교환 토큰 로그인 */
    public LoginResult login(AuthProvider authProvider, String code, String redirectUri, String state, String codeVerifier) {
        ProviderTokens exchangedTokens = authorizationCodeExchanger.exchangeForTokens(
                authProvider, code, redirectUri, state, codeVerifier);
        return authService.loginWithExchangedTokens(authProvider, exchangedTokens);
    }

    /** 공개 설정: 제공자별 사용 여부 + 공개 client ID (secret 제외) */
    public List<SocialLoginClientConfig> getClientConfigs() {
        return AuthorizationCodeExchanger.CODE_FLOW_PROVIDERS.stream()
                .map(provider -> {
                    SocialLoginProperties.ProviderClient client = authorizationCodeExchanger.clientOf(provider);
                    return new SocialLoginClientConfig(provider, client.isConfigured(),
                            client.isConfigured() ? client.clientId() : null);
                })
                .toList();
    }
}
