package com.passql.member.auth.infrastructure.social.unlink;

import com.google.firebase.auth.FirebaseAuth;
import com.passql.member.auth.domain.ProviderTokens;
import com.passql.member.auth.infrastructure.social.SocialApiRestTemplates;
import com.passql.member.auth.infrastructure.social.oauth.SocialLoginProperties;
import com.passql.member.auth.infrastructure.social.oauth.SocialLoginProperties.ProviderClient;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestTemplate;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.content;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withNoContent;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

/**
 * 제공자 연결 해제 HTTP 요청 형식 (#516): 카카오 unlink, GitHub grant 삭제, 네이버 토큰 갱신 후 삭제, Firebase 사용자 삭제
 */
class SocialUnlinkClientTest {

    // 테스트용 가짜 키 (실제 값 아님)
    private static final String KAKAO_ADMIN_KEY = "test-admin-key";
    private static final String GITHUB_CLIENT_ID = "github-test-client";
    private static final String GITHUB_CLIENT_SECRET = "github-test-secret";

    private final FirebaseAuth firebaseAuth = mock(FirebaseAuth.class);

    private SocialLoginProperties properties(String kakaoAdminKey) {
        return new SocialLoginProperties(
                new ProviderClient("kakao-rest-key", null, List.of(), "1000001", kakaoAdminKey, List.of()),
                new ProviderClient("naver-client", "naver-secret", List.of()),
                new ProviderClient(GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, List.of()),
                List.of());
    }

    @Test
    void 카카오_연결_끊기는_관리자_키와_사용자_ID_로_요청한다() {
        RestTemplate restTemplate = SocialApiRestTemplates.create();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo("https://kapi.kakao.com/v1/user/unlink")).andExpect(method(HttpMethod.POST))
                .andExpect(header("Authorization", "KakaoAK " + KAKAO_ADMIN_KEY))
                .andExpect(content().formDataContains(java.util.Map.of("target_id_type", "user_id", "target_id", "4242")))
                .andRespond(withSuccess("{\"id\":4242}", MediaType.APPLICATION_JSON));

        new SocialUnlinkClient(properties(KAKAO_ADMIN_KEY), firebaseAuth, restTemplate).unlinkKakaoUser("4242");

        server.verify();
    }

    @Test
    void 카카오_관리자_키가_없으면_해제할_수_없다() {
        SocialUnlinkClient client = new SocialUnlinkClient(properties(""), firebaseAuth, SocialApiRestTemplates.create());

        assertThatThrownBy(() -> client.unlinkKakaoUser("4242")).isInstanceOf(IllegalStateException.class);
    }

    @Test
    void GitHub_권한_회수는_앱_기본_인증으로_grant_를_삭제한다() {
        RestTemplate restTemplate = SocialApiRestTemplates.create();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        String basic = Base64.getEncoder().encodeToString(
                (GITHUB_CLIENT_ID + ":" + GITHUB_CLIENT_SECRET).getBytes(StandardCharsets.UTF_8));
        server.expect(requestTo("https://api.github.com/applications/" + GITHUB_CLIENT_ID + "/grant"))
                .andExpect(method(HttpMethod.DELETE))
                .andExpect(header("Authorization", "Basic " + basic))
                .andExpect(content().json("{\"access_token\":\"gho_access\"}"))
                .andRespond(withNoContent());

        new SocialUnlinkClient(properties(KAKAO_ADMIN_KEY), firebaseAuth, restTemplate).revokeGithubGrant("gho_access");

        server.verify();
    }

    @Test
    void 네이버는_refresh_token_으로_새_access_token_을_받아_연동을_삭제한다() {
        RestTemplate restTemplate = SocialApiRestTemplates.create();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo("https://nid.naver.com/oauth2.0/token")).andExpect(method(HttpMethod.POST))
                .andExpect(content().formDataContains(java.util.Map.of("grant_type", "refresh_token", "refresh_token", "naver-refresh")))
                .andRespond(withSuccess("{\"access_token\":\"naver-new-access\"}", MediaType.APPLICATION_JSON));
        server.expect(requestTo("https://nid.naver.com/oauth2.0/token")).andExpect(method(HttpMethod.POST))
                .andExpect(content().formDataContains(java.util.Map.of(
                        "grant_type", "delete", "access_token", "naver-new-access", "service_provider", "NAVER")))
                .andRespond(withSuccess("{\"result\":\"success\"}", MediaType.APPLICATION_JSON));

        new SocialUnlinkClient(properties(KAKAO_ADMIN_KEY), firebaseAuth, restTemplate)
                .deleteNaverToken(new ProviderTokens("naver-old-access", "naver-refresh"));

        server.verify();
    }

    @Test
    void 네이버_refresh_token_이_없으면_저장된_access_token_으로_삭제한다() {
        RestTemplate restTemplate = SocialApiRestTemplates.create();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo("https://nid.naver.com/oauth2.0/token"))
                .andExpect(content().formDataContains(java.util.Map.of("grant_type", "delete", "access_token", "naver-access")))
                .andRespond(withSuccess("{\"result\":\"success\"}", MediaType.APPLICATION_JSON));

        new SocialUnlinkClient(properties(KAKAO_ADMIN_KEY), firebaseAuth, restTemplate)
                .deleteNaverToken(new ProviderTokens("naver-access", null));

        server.verify();
    }

    @Test
    void 네이버_삭제_응답에_오류가_있으면_실패로_본다() {
        RestTemplate restTemplate = SocialApiRestTemplates.create();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo("https://nid.naver.com/oauth2.0/token"))
                .andRespond(withSuccess("{\"error\":\"invalid_request\"}", MediaType.APPLICATION_JSON));

        SocialUnlinkClient client = new SocialUnlinkClient(properties(KAKAO_ADMIN_KEY), firebaseAuth, restTemplate);
        assertThatThrownBy(() -> client.deleteNaverToken(new ProviderTokens("naver-access", null)))
                .isInstanceOf(IllegalStateException.class);
    }

    @Test
    void Firebase_사용자_삭제는_uid_로_요청한다() throws Exception {
        new SocialUnlinkClient(properties(KAKAO_ADMIN_KEY), firebaseAuth, SocialApiRestTemplates.create())
                .deleteFirebaseUser("firebase-uid");

        verify(firebaseAuth).deleteUser("firebase-uid");
    }
}
