package com.passql.member.auth.infrastructure.social.strategy;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.auth.infrastructure.social.SocialApiRestTemplates;
import com.passql.member.auth.infrastructure.social.oauth.SocialLoginProperties;
import com.passql.member.constant.AuthProvider;
import lombok.extern.slf4j.Slf4j;
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
 * 카카오 로그인: 토큰 발급 앱(app_id) 검증, 사용자 ID 조회
 */
@Slf4j
@Component
public class KakaoLoginStrategy implements SocialLoginStrategy {

    private static final String KAKAO_USER_INFO_URL = "https://kapi.kakao.com/v2/user/me";
    private static final String KAKAO_TOKEN_INFO_URL = "https://kapi.kakao.com/v1/user/access_token_info";
    private static final ParameterizedTypeReference<Map<String, Object>> JSON_OBJECT = new ParameterizedTypeReference<>() {
    };

    private final SocialLoginProperties socialLoginProperties;
    private final RestTemplate restTemplate;

    @Autowired
    public KakaoLoginStrategy(SocialLoginProperties socialLoginProperties) {
        this(socialLoginProperties, SocialApiRestTemplates.create());
    }

    // 테스트에서 가짜 HTTP 서버를 붙이기 위한 생성자
    public KakaoLoginStrategy(SocialLoginProperties socialLoginProperties, RestTemplate restTemplate) {
        this.socialLoginProperties = socialLoginProperties;
        this.restTemplate = restTemplate;
    }

    /** 토큰 정보 조회 > app_id <-> social-login.kakao.app-id (설정 없으면 SOCIAL_LOGIN_UNAVAILABLE) */
    @Override
    public void verifyIssuedForThisApp(String accessToken) {
        SocialLoginProperties.ProviderClient kakao = socialLoginProperties.kakao();
        if (kakao == null || !kakao.hasAppId()) {
            log.error("[social login] rejected 503 : social-login.kakao.app-id not configured");
            throw new CustomException(ErrorCode.SOCIAL_LOGIN_UNAVAILABLE);
        }
        String tokenAppId = SocialStrategyResponses.stringOf(getJson(KAKAO_TOKEN_INFO_URL, accessToken), "app_id");
        if (!kakao.appId().equals(tokenAppId)) {
            throw SocialStrategyResponses.rejectedToken(AuthProvider.KAKAO, "token issued for another app");
        }
    }

    @Override
    public String validateAndGetSocialId(String accessToken) {
        String id = SocialStrategyResponses.stringOf(getJson(KAKAO_USER_INFO_URL, accessToken), "id");
        if (id == null) {
            throw SocialStrategyResponses.rejectedToken(AuthProvider.KAKAO, "user id missing");
        }
        return id;
    }

    @Override
    public AuthProvider getAuthProvider() {
        return AuthProvider.KAKAO;
    }

    /** Bearer 토큰 GET > JSON 본문 (실패·빈 본문은 INVALID_SOCIAL_TOKEN) */
    private Map<String, Object> getJson(String url, String accessToken) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setBearerAuth(accessToken);
            Map<String, Object> body = restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(headers), JSON_OBJECT).getBody();
            if (body == null) {
                throw SocialStrategyResponses.rejectedToken(AuthProvider.KAKAO, "empty response");
            }
            return body;
        } catch (RestClientException e) {
            throw SocialStrategyResponses.rejectedToken(AuthProvider.KAKAO, e.getClass().getSimpleName());
        }
    }
}
