package com.passql.member.auth.infrastructure.social.strategy;

import com.passql.member.auth.domain.SocialProfile;
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
 * GitHub 로그인: 사용자 ID·공개 이메일·아바타 조회 (서버가 코드 교환한 토큰만 사용, 토큰 직접 로그인은 AuthService 에서 거부)
 * 범위 read:user 라 이메일은 공개 설정한 값만 (비공개면 null, #908)
 */
@Component
public class GithubLoginStrategy implements SocialLoginStrategy {

    private static final String GITHUB_USER_INFO_URL = "https://api.github.com/user";
    private static final ParameterizedTypeReference<Map<String, Object>> JSON_OBJECT = new ParameterizedTypeReference<>() {
    };
    private final RestTemplate restTemplate = SocialApiRestTemplates.create();

    @Override
    public SocialProfile fetchSocialProfile(String accessToken) {
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
            // 공개 이메일 인증 여부는 응답에 없음 > 미인증으로 저장
            return new SocialProfile(id, SocialStrategyResponses.stringOf(body, "email"), false,
                    SocialStrategyResponses.stringOf(body, "avatar_url"));
        } catch (RestClientException e) {
            throw SocialStrategyResponses.rejectedToken(AuthProvider.GITHUB, e.getClass().getSimpleName());
        }
    }

    @Override
    public AuthProvider getAuthProvider() {
        return AuthProvider.GITHUB;
    }
}
