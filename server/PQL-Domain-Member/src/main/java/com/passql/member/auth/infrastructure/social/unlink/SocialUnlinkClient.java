package com.passql.member.auth.infrastructure.social.unlink;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.passql.member.auth.domain.ProviderTokens;
import com.passql.member.auth.infrastructure.social.SocialApiRestTemplates;
import com.passql.member.auth.infrastructure.social.oauth.SocialLoginProperties;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

/**
 * 제공자 연결 해제 호출 (#516): 카카오 unlink, GitHub grant 삭제, 네이버 토큰 삭제, Firebase 사용자 삭제
 * 실패는 예외로 알림 (기록·무시 판단은 호출자)
 */
@Component
public class SocialUnlinkClient {

    private static final String KAKAO_UNLINK_URL = "https://kapi.kakao.com/v1/user/unlink";
    // {client_id} 자리에 GitHub OAuth 앱 client ID
    private static final String GITHUB_GRANT_URL = "https://api.github.com/applications/{clientId}/grant";
    private static final String NAVER_TOKEN_URL = "https://nid.naver.com/oauth2.0/token";
    private static final String KAKAO_ADMIN_AUTHORIZATION_PREFIX = "KakaoAK ";
    private static final ParameterizedTypeReference<Map<String, Object>> JSON_OBJECT = new ParameterizedTypeReference<>() {
    };

    private final SocialLoginProperties socialLoginProperties;
    private final FirebaseAuth firebaseAuth;
    private final RestTemplate restTemplate;

    @Autowired
    public SocialUnlinkClient(SocialLoginProperties socialLoginProperties, FirebaseAuth firebaseAuth) {
        this(socialLoginProperties, firebaseAuth, SocialApiRestTemplates.create());
    }

    // 테스트에서 가짜 HTTP 서버를 붙이기 위한 생성자
    public SocialUnlinkClient(SocialLoginProperties socialLoginProperties, FirebaseAuth firebaseAuth, RestTemplate restTemplate) {
        this.socialLoginProperties = socialLoginProperties;
        this.firebaseAuth = firebaseAuth;
        this.restTemplate = restTemplate;
    }

    /** 카카오: 관리자 키 + 회원번호로 연결 끊기 (관리자 키 없으면 IllegalStateException) */
    public void unlinkKakaoUser(String kakaoUserId) {
        SocialLoginProperties.ProviderClient kakao = socialLoginProperties.kakao();
        if (kakao == null || !kakao.hasAdminKey()) {
            throw new IllegalStateException("social-login.kakao.admin-key not configured");
        }
        HttpHeaders headers = formHeaders();
        headers.set(HttpHeaders.AUTHORIZATION, KAKAO_ADMIN_AUTHORIZATION_PREFIX + kakao.adminKey());
        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("target_id_type", "user_id");
        form.add("target_id", kakaoUserId);
        restTemplate.exchange(KAKAO_UNLINK_URL, HttpMethod.POST, new HttpEntity<>(form, headers), JSON_OBJECT);
    }

    /** GitHub: 앱 client ID·secret 기본 인증으로 사용자 grant 삭제 (앱 권한 전체 회수) */
    public void revokeGithubGrant(String accessToken) {
        SocialLoginProperties.ProviderClient github = configuredClient(socialLoginProperties.github(), "github");
        HttpHeaders headers = new HttpHeaders();
        headers.setBasicAuth(github.clientId(), github.clientSecret());
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(List.of(MediaType.valueOf("application/vnd.github+json")));
        restTemplate.exchange(GITHUB_GRANT_URL, HttpMethod.DELETE,
                new HttpEntity<>(Map.of("access_token", accessToken), headers), Void.class, github.clientId());
    }

    /** 네이버: refresh 있으면 access 갱신 > grant_type=delete (응답 error 있으면 실패) */
    public void deleteNaverToken(ProviderTokens tokens) {
        SocialLoginProperties.ProviderClient naver = configuredClient(socialLoginProperties.naver(), "naver");
        String accessToken = tokens.hasRefreshToken() ? refreshNaverAccessToken(naver, tokens.refreshToken()) : tokens.accessToken();

        MultiValueMap<String, String> form = naverClientForm(naver, "delete");
        form.add("access_token", accessToken);
        form.add("service_provider", "NAVER");
        requireNoNaverError(postNaverForm(form));
    }

    /** Google·Apple: Firebase 사용자 삭제 (같은 계정 재로그인 시 새 uid) */
    public void deleteFirebaseUser(String firebaseUid) {
        try {
            firebaseAuth.deleteUser(firebaseUid);
        } catch (FirebaseAuthException e) {
            throw new IllegalStateException("firebase delete user failed : " + e.getAuthErrorCode(), e);
        }
    }

    private String refreshNaverAccessToken(SocialLoginProperties.ProviderClient naver, String refreshToken) {
        MultiValueMap<String, String> form = naverClientForm(naver, "refresh_token");
        form.add("refresh_token", refreshToken);
        Map<String, Object> body = requireNoNaverError(postNaverForm(form));
        Object accessToken = body.get("access_token");
        if (accessToken == null) {
            throw new IllegalStateException("naver refresh returned no access token");
        }
        return accessToken.toString();
    }

    private MultiValueMap<String, String> naverClientForm(SocialLoginProperties.ProviderClient naver, String grantType) {
        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("grant_type", grantType);
        form.add("client_id", naver.clientId());
        form.add("client_secret", naver.clientSecret());
        return form;
    }

    private Map<String, Object> postNaverForm(MultiValueMap<String, String> form) {
        return restTemplate.exchange(NAVER_TOKEN_URL, HttpMethod.POST, new HttpEntity<>(form, formHeaders()), JSON_OBJECT).getBody();
    }

    /** 네이버는 실패도 200 + error 필드로 응답 */
    private static Map<String, Object> requireNoNaverError(Map<String, Object> body) {
        if (body == null || body.get("error") != null) {
            throw new IllegalStateException("naver token api error : " + (body == null ? "empty" : body.get("error")));
        }
        return body;
    }

    private static SocialLoginProperties.ProviderClient configuredClient(SocialLoginProperties.ProviderClient client, String providerName) {
        if (client == null || !client.isConfigured()) {
            throw new IllegalStateException("social-login." + providerName + " not configured");
        }
        return client;
    }

    private static HttpHeaders formHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
        headers.setAccept(List.of(MediaType.APPLICATION_JSON));
        return headers;
    }
}
