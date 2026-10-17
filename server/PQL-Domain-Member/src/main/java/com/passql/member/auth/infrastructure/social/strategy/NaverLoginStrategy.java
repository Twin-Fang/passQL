package com.passql.member.auth.infrastructure.social.strategy;

import com.passql.member.auth.infrastructure.social.SocialApiRestTemplates;
import com.passql.member.auth.infrastructure.social.oauth.SocialLoginProperties;
import com.passql.member.constant.AuthProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

/**
 * 네이버 로그인: 토큰 발급 앱(client_id) 검증, 사용자 ID 조회
 */
@Component
public class NaverLoginStrategy implements SocialLoginStrategy {

    private static final String NAVER_USER_INFO_URL = "https://openapi.naver.com/v1/nid/me";
    // info=true: 응답 response.client_id 에 토큰 발급 앱 포함
    private static final String NAVER_TOKEN_VERIFY_URL = "https://openapi.naver.com/v1/nid/verify?info=true";
    private static final String RESPONSE_KEY = "response";
    private static final ParameterizedTypeReference<Map<String, Object>> JSON_OBJECT = new ParameterizedTypeReference<>() {
    };

    private final SocialLoginProperties socialLoginProperties;
    private final RestTemplate restTemplate;

    @Autowired
    public NaverLoginStrategy(SocialLoginProperties socialLoginProperties) {
        this(socialLoginProperties, SocialApiRestTemplates.create());
    }

    // 테스트에서 가짜 HTTP 서버를 붙이기 위한 생성자
    public NaverLoginStrategy(SocialLoginProperties socialLoginProperties, RestTemplate restTemplate) {
        this.socialLoginProperties = socialLoginProperties;
        this.restTemplate = restTemplate;
    }

    /** 토큰 검증 조회 > response.client_id ∈ 허용 client ID (기본: social-login.naver.client-id) */
    @Override
    public void verifyIssuedForThisApp(String accessToken) {
        Map<String, Object> tokenInfo = SocialStrategyResponses.childOf(getJson(NAVER_TOKEN_VERIFY_URL, accessToken), RESPONSE_KEY);
        String tokenClientId = SocialStrategyResponses.stringOf(tokenInfo, "client_id");
        SocialLoginProperties.ProviderClient naver = socialLoginProperties.naver();
        if (naver == null || !naver.isAllowedClientId(tokenClientId)) {
            throw SocialStrategyResponses.rejectedToken(AuthProvider.NAVER, "token issued for another app");
        }
    }

    @Override
    public String validateAndGetSocialId(String accessToken) {
        Map<String, Object> profile = SocialStrategyResponses.childOf(getJson(NAVER_USER_INFO_URL, accessToken), RESPONSE_KEY);
        String id = SocialStrategyResponses.stringOf(profile, "id");
        if (id == null) {
            throw SocialStrategyResponses.rejectedToken(AuthProvider.NAVER, "user id missing");
        }
        return id;
    }

    @Override
    public AuthProvider getAuthProvider() {
        return AuthProvider.NAVER;
    }

    /** Bearer 토큰 GET > JSON 본문 (실패·빈 본문은 INVALID_SOCIAL_TOKEN) */
    private Map<String, Object> getJson(String url, String accessToken) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setBearerAuth(accessToken);
            Map<String, Object> body = restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(headers), JSON_OBJECT).getBody();
            if (body == null) {
                throw SocialStrategyResponses.rejectedToken(AuthProvider.NAVER, "empty response");
            }
            return body;
        } catch (RestClientException e) {
            throw SocialStrategyResponses.rejectedToken(AuthProvider.NAVER, e.getClass().getSimpleName());
        }
    }
}
