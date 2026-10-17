package com.passql.member.auth.infrastructure.social.strategy;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.auth.infrastructure.social.SocialApiRestTemplates;
import com.passql.member.auth.infrastructure.social.oauth.SocialLoginProperties;
import com.passql.member.auth.infrastructure.social.oauth.SocialLoginProperties.ProviderClient;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withStatus;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

/**
 * 클라이언트 토큰 출처 검증 (#516): 카카오 app_id, 네이버 client_id, Firebase sign_in_provider
 * 다른 앱에서 발급받은 토큰으로 이 서비스 회원 로그인 차단
 */
class SocialTokenOriginVerificationTest {

    // 테스트용 가짜 식별자 (실제 값 아님)
    private static final String KAKAO_APP_ID = "1000001";
    private static final String NAVER_CLIENT_ID = "naver-test-client";
    private static final String CLIENT_ACCESS_TOKEN = "client-access-token";

    private static final String KAKAO_TOKEN_INFO_URL = "https://kapi.kakao.com/v1/user/access_token_info";
    private static final String NAVER_VERIFY_URL = "https://openapi.naver.com/v1/nid/verify?info=true";

    private SocialLoginProperties properties(String kakaoAppId, List<String> naverAllowedClientIds) {
        return new SocialLoginProperties(
                new ProviderClient("kakao-rest-key", null, List.of(), kakaoAppId, null, List.of()),
                new ProviderClient(NAVER_CLIENT_ID, "naver-secret", List.of(), null, null, naverAllowedClientIds),
                new ProviderClient(null, null, List.of()),
                List.of());
    }

    @Test
    void 카카오_토큰의_app_id_가_이_앱이면_통과한다() {
        RestTemplate restTemplate = SocialApiRestTemplates.create();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo(KAKAO_TOKEN_INFO_URL)).andExpect(method(HttpMethod.GET))
                .andExpect(header("Authorization", "Bearer " + CLIENT_ACCESS_TOKEN))
                .andRespond(withSuccess("{\"id\":42,\"app_id\":" + KAKAO_APP_ID + "}", MediaType.APPLICATION_JSON));

        new KakaoLoginStrategy(properties(KAKAO_APP_ID, List.of()), restTemplate).verifyIssuedForThisApp(CLIENT_ACCESS_TOKEN);

        server.verify();
    }

    @Test
    void 다른_카카오_앱_토큰은_INVALID_SOCIAL_TOKEN() {
        RestTemplate restTemplate = SocialApiRestTemplates.create();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo(KAKAO_TOKEN_INFO_URL))
                .andRespond(withSuccess("{\"id\":42,\"app_id\":9999999}", MediaType.APPLICATION_JSON));

        assertErrorCode(() -> new KakaoLoginStrategy(properties(KAKAO_APP_ID, List.of()), restTemplate)
                .verifyIssuedForThisApp(CLIENT_ACCESS_TOKEN), ErrorCode.INVALID_SOCIAL_TOKEN);
    }

    @Test
    void 카카오_토큰_정보_응답이_비거나_실패하면_INVALID_SOCIAL_TOKEN() {
        RestTemplate restTemplate = SocialApiRestTemplates.create();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo(KAKAO_TOKEN_INFO_URL)).andRespond(withStatus(HttpStatus.UNAUTHORIZED));

        assertErrorCode(() -> new KakaoLoginStrategy(properties(KAKAO_APP_ID, List.of()), restTemplate)
                .verifyIssuedForThisApp(CLIENT_ACCESS_TOKEN), ErrorCode.INVALID_SOCIAL_TOKEN);
    }

    @Test
    void 카카오_app_id_설정이_없으면_검증_불가로_준비_중() {
        assertErrorCode(() -> new KakaoLoginStrategy(properties("", List.of()), SocialApiRestTemplates.create())
                .verifyIssuedForThisApp(CLIENT_ACCESS_TOKEN), ErrorCode.SOCIAL_LOGIN_UNAVAILABLE);
    }

    @Test
    void 카카오_사용자_응답_본문이_없으면_INVALID_SOCIAL_TOKEN() {
        RestTemplate restTemplate = SocialApiRestTemplates.create();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo("https://kapi.kakao.com/v2/user/me")).andRespond(withSuccess());

        assertErrorCode(() -> new KakaoLoginStrategy(properties(KAKAO_APP_ID, List.of()), restTemplate)
                .validateAndGetSocialId(CLIENT_ACCESS_TOKEN), ErrorCode.INVALID_SOCIAL_TOKEN);
    }

    @Test
    void 네이버_토큰의_client_id_가_허용_목록_기본값이면_통과한다() {
        RestTemplate restTemplate = SocialApiRestTemplates.create();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo(NAVER_VERIFY_URL)).andExpect(method(HttpMethod.GET))
                .andRespond(withSuccess("{\"resultcode\":\"00\",\"response\":{\"client_id\":\"" + NAVER_CLIENT_ID + "\"}}",
                        MediaType.APPLICATION_JSON));

        // 허용 목록이 비면 social-login.naver.client-id 만 허용
        new NaverLoginStrategy(properties(KAKAO_APP_ID, List.of()), restTemplate).verifyIssuedForThisApp(CLIENT_ACCESS_TOKEN);

        server.verify();
    }

    @Test
    void 네이버_허용_목록에_있는_앱_client_id_도_통과한다() {
        RestTemplate restTemplate = SocialApiRestTemplates.create();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo(NAVER_VERIFY_URL))
                .andRespond(withSuccess("{\"response\":{\"client_id\":\"naver-app-client\"}}", MediaType.APPLICATION_JSON));

        new NaverLoginStrategy(properties(KAKAO_APP_ID, List.of(NAVER_CLIENT_ID, "naver-app-client")), restTemplate)
                .verifyIssuedForThisApp(CLIENT_ACCESS_TOKEN);

        server.verify();
    }

    @Test
    void 다른_네이버_앱_토큰이나_빈_응답은_INVALID_SOCIAL_TOKEN() {
        RestTemplate restTemplate = SocialApiRestTemplates.create();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        server.expect(requestTo(NAVER_VERIFY_URL))
                .andRespond(withSuccess("{\"response\":{\"client_id\":\"other-app\"}}", MediaType.APPLICATION_JSON));
        server.expect(requestTo(NAVER_VERIFY_URL))
                .andRespond(withSuccess("{\"resultcode\":\"024\"}", MediaType.APPLICATION_JSON));

        NaverLoginStrategy strategy = new NaverLoginStrategy(properties(KAKAO_APP_ID, List.of()), restTemplate);
        assertErrorCode(() -> strategy.verifyIssuedForThisApp(CLIENT_ACCESS_TOKEN), ErrorCode.INVALID_SOCIAL_TOKEN);
        assertErrorCode(() -> strategy.verifyIssuedForThisApp(CLIENT_ACCESS_TOKEN), ErrorCode.INVALID_SOCIAL_TOKEN);
    }

    @Test
    void 구글_전략은_Firebase_토큰의_로그인_제공자가_google_일_때만_통과한다() throws Exception {
        FirebaseAuth firebaseAuth = mock(FirebaseAuth.class);
        FirebaseToken googleToken = firebaseTokenOf("uid-google", "google.com");
        FirebaseToken appleToken = firebaseTokenOf("uid-apple", "apple.com");
        when(firebaseAuth.verifyIdToken("google-id-token")).thenReturn(googleToken);
        when(firebaseAuth.verifyIdToken("apple-id-token")).thenReturn(appleToken);

        GoogleLoginStrategy googleStrategy = new GoogleLoginStrategy(firebaseAuth);
        AppleLoginStrategy appleStrategy = new AppleLoginStrategy(firebaseAuth);

        assertThat(googleStrategy.validateAndGetSocialId("google-id-token")).isEqualTo("uid-google");
        assertThat(appleStrategy.validateAndGetSocialId("apple-id-token")).isEqualTo("uid-apple");
        // 제공자 바꿔치기 (Apple 토큰으로 GOOGLE 로그인) 거부
        assertErrorCode(() -> googleStrategy.validateAndGetSocialId("apple-id-token"), ErrorCode.INVALID_SOCIAL_TOKEN);
        assertErrorCode(() -> appleStrategy.validateAndGetSocialId("google-id-token"), ErrorCode.INVALID_SOCIAL_TOKEN);
    }

    @Test
    void Firebase_토큰에_로그인_제공자_클레임이_없으면_INVALID_SOCIAL_TOKEN() throws Exception {
        FirebaseAuth firebaseAuth = mock(FirebaseAuth.class);
        FirebaseToken tokenWithoutProvider = mock(FirebaseToken.class);
        when(tokenWithoutProvider.getUid()).thenReturn("uid-anonymous");
        when(tokenWithoutProvider.getClaims()).thenReturn(Map.of());
        when(firebaseAuth.verifyIdToken("anonymous-id-token")).thenReturn(tokenWithoutProvider);

        assertErrorCode(() -> new GoogleLoginStrategy(firebaseAuth).validateAndGetSocialId("anonymous-id-token"),
                ErrorCode.INVALID_SOCIAL_TOKEN);
    }

    private static FirebaseToken firebaseTokenOf(String uid, String signInProvider) {
        FirebaseToken token = mock(FirebaseToken.class);
        when(token.getUid()).thenReturn(uid);
        when(token.getClaims()).thenReturn(Map.of("firebase", Map.of("sign_in_provider", signInProvider)));
        return token;
    }

    private static void assertErrorCode(org.assertj.core.api.ThrowableAssert.ThrowingCallable call, ErrorCode expected) {
        assertThatThrownBy(call)
                .isInstanceOfSatisfying(CustomException.class, e -> assertThat(e.getErrorCode()).isEqualTo(expected));
    }
}
