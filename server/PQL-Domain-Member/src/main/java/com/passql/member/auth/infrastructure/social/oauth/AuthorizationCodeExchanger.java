package com.passql.member.auth.infrastructure.social.oauth;

import com.passql.member.auth.infrastructure.social.SocialProviderEndpoints;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.auth.domain.ProviderTokens;
import com.passql.member.auth.infrastructure.social.SocialApiRestTemplates;
import com.passql.member.constant.AuthProvider;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

/**
 * 인가 코드 > 제공자 토큰 교환 (#509, #516): 카카오, 네이버, GitHub
 * 받은 access token 은 기존 로그인 전략(사용자 정보 API 검증)으로, refresh token 은 연결 해제용 자격으로 넘긴다.
 */
@Slf4j
@Component
public class AuthorizationCodeExchanger {

    private static final String KAKAO_TOKEN_URL = "https://kauth.kakao.com/oauth/token";
    private static final String GITHUB_TOKEN_URL = "https://github.com/login/oauth/access_token";

    private final SocialLoginProperties socialLoginProperties;
    private final RestTemplate restTemplate;

    @Autowired
    public AuthorizationCodeExchanger(SocialLoginProperties socialLoginProperties) {
        this(socialLoginProperties, SocialApiRestTemplates.create());
    }

    // 테스트에서 가짜 HTTP 서버를 붙이기 위한 생성자
    public AuthorizationCodeExchanger(SocialLoginProperties socialLoginProperties, RestTemplate restTemplate) {
        this.socialLoginProperties = socialLoginProperties;
        this.restTemplate = restTemplate;
    }

    /** 인가 코드 로그인을 지원하는 제공자 3개 */
    public static final List<AuthProvider> CODE_FLOW_PROVIDERS =
            List.of(AuthProvider.KAKAO, AuthProvider.NAVER, AuthProvider.GITHUB);

    /** 제공자 설정 조회 (코드 방식이 아닌 제공자 > UNSUPPORTED_AUTH_PROVIDER) */
    public SocialLoginProperties.ProviderClient clientOf(AuthProvider provider) {
        SocialLoginProperties.ProviderClient client = switch (provider) {
            case KAKAO -> socialLoginProperties.kakao();
            case NAVER -> socialLoginProperties.naver();
            case GITHUB -> socialLoginProperties.github();
            default -> throw new CustomException(ErrorCode.UNSUPPORTED_AUTH_PROVIDER);
        };
        return client != null ? client : new SocialLoginProperties.ProviderClient(null, null, List.of());
    }

    /**
     * 검증(설정·redirect URI) > 제공자 토큰 API 호출 > 토큰 쌍
     * codeVerifier: GitHub PKCE (값 있을 때만 전달)
     */
    public ProviderTokens exchangeForTokens(AuthProvider provider, String code, String redirectUri, String state,
                                            String codeVerifier) {
        SocialLoginProperties.ProviderClient client = clientOf(provider);
        if (!client.isConfigured()) {
            log.warn("[social login] rejected 503 : provider not configured ({})", provider);
            throw new CustomException(ErrorCode.SOCIAL_LOGIN_UNAVAILABLE);
        }
        if (!client.isAllowedRedirectUri(redirectUri) && !socialLoginProperties.isLocalRedirectUri(redirectUri)) {
            log.warn("[social login] rejected 400 : redirect uri not allowed ({})", provider);
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }
        try {
            ProviderTokens tokens = toProviderTokens(switch (provider) {
                case KAKAO -> requestKakaoToken(client, code, redirectUri);
                case NAVER -> requestNaverToken(client, code, state);
                case GITHUB -> requestGithubToken(client, code, redirectUri, codeVerifier);
                default -> throw new CustomException(ErrorCode.UNSUPPORTED_AUTH_PROVIDER);
            });
            if (tokens == null) {
                throw new CustomException(ErrorCode.INVALID_SOCIAL_AUTHORIZATION_CODE);
            }
            return tokens;
        } catch (RestClientException e) {
            log.warn("[social login] rejected 401 : code exchange failed ({}) {}", provider, e.getClass().getSimpleName());
            throw new CustomException(ErrorCode.INVALID_SOCIAL_AUTHORIZATION_CODE);
        }
    }

    @SuppressWarnings("rawtypes")
    private Map requestKakaoToken(SocialLoginProperties.ProviderClient client, String code, String redirectUri) {
        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("grant_type", "authorization_code");
        form.add("client_id", client.clientId());
        form.add("redirect_uri", redirectUri);
        form.add("code", code);
        if (client.clientSecret() != null && !client.clientSecret().isBlank()) {
            form.add("client_secret", client.clientSecret());
        }
        return postForm(KAKAO_TOKEN_URL, form);
    }

    @SuppressWarnings("rawtypes")
    private Map requestNaverToken(SocialLoginProperties.ProviderClient client, String code, String state) {
        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("grant_type", "authorization_code");
        form.add("client_id", client.clientId());
        form.add("client_secret", client.clientSecret());
        form.add("code", code);
        form.add("state", state == null ? "" : state);
        return postForm(SocialProviderEndpoints.NAVER_TOKEN_URL, form);
    }

    @SuppressWarnings("rawtypes")
    private Map requestGithubToken(SocialLoginProperties.ProviderClient client, String code, String redirectUri,
                                   String codeVerifier) {
        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("client_id", client.clientId());
        form.add("client_secret", client.clientSecret());
        form.add("code", code);
        form.add("redirect_uri", redirectUri);
        // PKCE: 앱이 만든 verifier 가 있을 때만 (가로챈 코드 단독 교환 차단)
        if (codeVerifier != null && !codeVerifier.isBlank()) {
            form.add("code_verifier", codeVerifier);
        }
        return postForm(GITHUB_TOKEN_URL, form);
    }

    @SuppressWarnings("rawtypes")
    private Map postForm(String url, MultiValueMap<String, String> form) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
        // GitHub 는 Accept 가 JSON 이어야 JSON 으로 응답
        headers.setAccept(List.of(MediaType.APPLICATION_JSON));
        ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.POST, new HttpEntity<>(form, headers), Map.class);
        return response.getBody();
    }

    /** 토큰 응답 본문 > 토큰 쌍 (access token 없으면 null) */
    @SuppressWarnings("rawtypes")
    private static ProviderTokens toProviderTokens(Map body) {
        String accessToken = stringValueOf(body, "access_token");
        if (accessToken == null || accessToken.isBlank()) {
            return null;
        }
        return new ProviderTokens(accessToken, stringValueOf(body, "refresh_token"));
    }

    @SuppressWarnings("rawtypes")
    private static String stringValueOf(Map body, String key) {
        Object value = body == null ? null : body.get(key);
        return value == null ? null : value.toString();
    }
}
