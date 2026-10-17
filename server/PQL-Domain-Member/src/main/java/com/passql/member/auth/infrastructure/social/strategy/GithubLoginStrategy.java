package com.passql.member.auth.infrastructure.social.strategy;

import com.passql.member.auth.infrastructure.social.SocialApiRestTemplates;
import com.passql.member.constant.AuthProvider;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

/**
 * GitHub 로그인: 사용자 ID 조회 (서버가 코드 교환한 토큰만 사용, 토큰 직접 로그인은 AuthService 에서 거부)
 */
@Component
public class GithubLoginStrategy implements SocialLoginStrategy {

    private static final String GITHUB_USER_INFO_URL = "https://api.github.com/user";
    private static final ParameterizedTypeReference<Map<String, Object>> JSON_OBJECT = new ParameterizedTypeReference<>() {
    };
    private final RestTemplate restTemplate = SocialApiRestTemplates.create();

    @Override
    public String validateAndGetSocialId(String accessToken) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setBearerAuth(accessToken);
            headers.set("X-GitHub-Api-Version", "2022-11-28");
            Map<String, Object> body = restTemplate.exchange(
                    GITHUB_USER_INFO_URL, HttpMethod.GET, new HttpEntity<>(headers), JSON_OBJECT).getBody();
            String id = SocialStrategyResponses.stringOf(body, "id");
            if (id == null) {
                throw SocialStrategyResponses.rejectedToken(AuthProvider.GITHUB, "user id missing");
            }
            return id;
        } catch (RestClientException e) {
            throw SocialStrategyResponses.rejectedToken(AuthProvider.GITHUB, e.getClass().getSimpleName());
        }
    }

    @Override
    public AuthProvider getAuthProvider() {
        return AuthProvider.GITHUB;
    }
}
