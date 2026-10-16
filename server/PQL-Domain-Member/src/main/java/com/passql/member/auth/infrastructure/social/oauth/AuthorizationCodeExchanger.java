package com.passql.member.auth.infrastructure.social.oauth;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.AuthProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

/**
 * 인가 코드 > 제공자 access token 교환 (#509): 카카오, 네이버, GitHub
 * 받은 access token 은 기존 로그인 전략(사용자 정보 API 검증)으로 넘긴다.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AuthorizationCodeExchanger {

    private static final String KAKAO_TOKEN_URL = "https://kauth.kakao.com/oauth/token";
    private static final String NAVER_TOKEN_URL = "https://nid.naver.com/oauth2.0/token";
    private static final String GITHUB_TOKEN_URL = "https://github.com/login/oauth/access_token";
    // 제공자 토큰 API 연결·응답 대기 상한 (5초)
    private static final int TIMEOUT_MILLISECONDS = 5_000;

    private final SocialLoginProperties socialLoginProperties;
    private final RestTemplate restTemplate = createRestTemplate();

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

    /** 검증(설정·redirect URI) > 제공자 토큰 API 호출 > access token */
    public String exchangeForAccessToken(AuthProvider provider, String code, String redirectUri, String state) {
        SocialLoginProperties.ProviderClient client = clientOf(provider);
        if (!client.isConfigured()) {
            log.warn("[social login] rejected 503 : provider not configured ({})", provider);
            throw new CustomException(ErrorCode.SOCIAL_LOGIN_UNAVAILABLE);
        }
        if (!client.isAllowedRedirectUri(redirectUri)) {
            log.warn("[social login] rejected 400 : redirect uri not allowed ({})", provider);
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }
        try {
            String accessToken = switch (provider) {
                case KAKAO -> requestKakaoToken(client, code, redirectUri);
                case NAVER -> requestNaverToken(client, code, state);
                case GITHUB -> requestGithubToken(client, code, redirectUri);
                default -> throw new CustomException(ErrorCode.UNSUPPORTED_AUTH_PROVIDER);
            };
            if (accessToken == null || accessToken.isBlank()) {
                throw new CustomException(ErrorCode.INVALID_SOCIAL_AUTHORIZATION_CODE);
            }
            return accessToken;
        } catch (RestClientException e) {
            log.warn("[social login] rejected 401 : code exchange failed ({}) {}", provider, e.getClass().getSimpleName());
            throw new CustomException(ErrorCode.INVALID_SOCIAL_AUTHORIZATION_CODE);
        }
    }

    private String requestKakaoToken(SocialLoginProperties.ProviderClient client, String code, String redirectUri) {
        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("grant_type", "authorization_code");
        form.add("client_id", client.clientId());
        form.add("redirect_uri", redirectUri);
        form.add("code", code);
        if (client.clientSecret() != null && !client.clientSecret().isBlank()) {
            form.add("client_secret", client.clientSecret());
        }
        return accessTokenOf(postForm(KAKAO_TOKEN_URL, form));
    }

    private String requestNaverToken(SocialLoginProperties.ProviderClient client, String code, String state) {
        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("grant_type", "authorization_code");
        form.add("client_id", client.clientId());
        form.add("client_secret", client.clientSecret());
        form.add("code", code);
        form.add("state", state == null ? "" : state);
        return accessTokenOf(postForm(NAVER_TOKEN_URL, form));
    }

    private String requestGithubToken(SocialLoginProperties.ProviderClient client, String code, String redirectUri) {
        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("client_id", client.clientId());
        form.add("client_secret", client.clientSecret());
        form.add("code", code);
        form.add("redirect_uri", redirectUri);
        return accessTokenOf(postForm(GITHUB_TOKEN_URL, form));
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

    @SuppressWarnings("rawtypes")
    private static String accessTokenOf(Map body) {
        Object accessToken = body == null ? null : body.get("access_token");
        return accessToken == null ? null : accessToken.toString();
    }

    private static RestTemplate createRestTemplate() {
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(TIMEOUT_MILLISECONDS);
        requestFactory.setReadTimeout(TIMEOUT_MILLISECONDS);
        return new RestTemplate(requestFactory);
    }
}
