package com.passql.member.auth.application;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.NicknameGenerator;
import com.passql.member.auth.application.dto.command.LoginCommand;
import com.passql.member.auth.application.dto.result.LoginResult;
import com.passql.member.auth.domain.ProviderTokens;
import com.passql.member.auth.infrastructure.jwt.JwtProperties;
import com.passql.member.auth.infrastructure.jwt.JwtTokenProvider;
import com.passql.member.auth.infrastructure.social.strategy.SocialLoginStrategy;
import com.passql.member.auth.repository.RefreshTokenRepository;
import com.passql.member.constant.AuthProvider;
import com.passql.member.entity.Member;
import com.passql.member.repository.MemberRepository;
import com.passql.member.service.MemberSocialCredentialService;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.InOrder;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.util.Base64;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 소셜 로그인 규칙 (#516): 직접 로그인 GitHub 거부, 클라이언트 토큰 출처 검증, 제공자 키 충돌 시 기존 회원 반환, 연결 해제용 자격 저장
 */
class AuthServiceLoginTest {

    private static final String SOCIAL_ID = "social-123";

    private final MemberRepository memberRepository = mock(MemberRepository.class);
    private final RefreshTokenRepository refreshTokenRepository = mock(RefreshTokenRepository.class);
    private final NicknameGenerator nicknameGenerator = mock(NicknameGenerator.class);
    private final MemberSignUpService memberSignUpService = mock(MemberSignUpService.class);
    private final MemberSocialCredentialService memberSocialCredentialService = mock(MemberSocialCredentialService.class);
    private final SocialLoginStrategy kakaoStrategy = strategyOf(AuthProvider.KAKAO);
    private final SocialLoginStrategy naverStrategy = strategyOf(AuthProvider.NAVER);
    private final SocialLoginStrategy githubStrategy = strategyOf(AuthProvider.GITHUB);

    private final AuthService authService = new AuthService(
            memberRepository, refreshTokenRepository, jwtTokenProvider(), nicknameGenerator,
            Map.of(AuthProvider.KAKAO, kakaoStrategy, AuthProvider.NAVER, naverStrategy, AuthProvider.GITHUB, githubStrategy),
            memberSignUpService, memberSocialCredentialService);

    @Test
    void 토큰_직접_로그인으로_GitHub_은_거부한다() {
        assertThatThrownBy(() -> authService.login(new LoginCommand(AuthProvider.GITHUB, "github-token")))
                .isInstanceOfSatisfying(CustomException.class,
                        e -> assertThat(e.getErrorCode()).isEqualTo(ErrorCode.UNSUPPORTED_AUTH_PROVIDER));
        verify(githubStrategy, never()).validateAndGetSocialId(anyString());
    }

    @Test
    void 토큰_직접_로그인은_출처_검증_후_사용자_ID_를_읽는다() {
        when(kakaoStrategy.validateAndGetSocialId("kakao-token")).thenReturn(SOCIAL_ID);
        Member existing = memberWithUuid(AuthProvider.KAKAO);
        when(memberRepository.findByAuthProviderAndProviderUserIdAndIsDeletedFalse(AuthProvider.KAKAO, SOCIAL_ID))
                .thenReturn(Optional.of(existing));

        LoginResult result = authService.login(new LoginCommand(AuthProvider.KAKAO, "kakao-token"));

        InOrder order = inOrder(kakaoStrategy);
        order.verify(kakaoStrategy).verifyIssuedForThisApp("kakao-token");
        order.verify(kakaoStrategy).validateAndGetSocialId("kakao-token");
        assertThat(result.member()).isSameAs(existing);
        assertThat(result.isNewMember()).isFalse();
    }

    @Test
    void 출처_검증에_실패하면_회원을_조회하지_않는다() {
        org.mockito.Mockito.doThrow(new CustomException(ErrorCode.INVALID_SOCIAL_TOKEN))
                .when(kakaoStrategy).verifyIssuedForThisApp("other-app-token");

        assertThatThrownBy(() -> authService.login(new LoginCommand(AuthProvider.KAKAO, "other-app-token")))
                .isInstanceOfSatisfying(CustomException.class,
                        e -> assertThat(e.getErrorCode()).isEqualTo(ErrorCode.INVALID_SOCIAL_TOKEN));
        verify(memberRepository, never()).findByAuthProviderAndProviderUserIdAndIsDeletedFalse(any(), any());
    }

    @Test
    void 동시_가입으로_제공자_키가_충돌하면_먼저_가입된_회원을_돌려준다() {
        when(kakaoStrategy.validateAndGetSocialId("kakao-token")).thenReturn(SOCIAL_ID);
        Member alreadyRegistered = memberWithUuid(AuthProvider.KAKAO);
        // 첫 조회 없음 > 저장 시 유니크 충돌 > 재조회 시 다른 요청이 만든 회원
        when(memberRepository.findByAuthProviderAndProviderUserIdAndIsDeletedFalse(AuthProvider.KAKAO, SOCIAL_ID))
                .thenReturn(Optional.empty(), Optional.of(alreadyRegistered));
        when(nicknameGenerator.generateUnique(any())).thenReturn("닉네임");
        when(memberSignUpService.saveInNewTransaction(any()))
                .thenThrow(new DataIntegrityViolationException("uk_member_provider_active"));

        LoginResult result = authService.login(new LoginCommand(AuthProvider.KAKAO, "kakao-token"));

        assertThat(result.member()).isSameAs(alreadyRegistered);
        assertThat(result.isNewMember()).isFalse();
        verify(memberSignUpService).saveInNewTransaction(any());
    }

    @Test
    void 닉네임_충돌은_새_닉네임으로_다시_가입한다() {
        when(kakaoStrategy.validateAndGetSocialId("kakao-token")).thenReturn(SOCIAL_ID);
        when(memberRepository.findByAuthProviderAndProviderUserIdAndIsDeletedFalse(AuthProvider.KAKAO, SOCIAL_ID))
                .thenReturn(Optional.empty());
        when(nicknameGenerator.generateUnique(any())).thenReturn("겹친닉네임", "새닉네임");
        Member saved = memberWithUuid(AuthProvider.KAKAO);
        when(memberSignUpService.saveInNewTransaction(any()))
                .thenThrow(new DataIntegrityViolationException("uk_member_nickname"))
                .thenReturn(saved);

        LoginResult result = authService.login(new LoginCommand(AuthProvider.KAKAO, "kakao-token"));

        assertThat(result.member()).isSameAs(saved);
        assertThat(result.isNewMember()).isTrue();
    }

    @Test
    void 서버가_교환한_토큰은_출처_검증_없이_로그인하고_연결_해제용_자격을_저장한다() {
        ProviderTokens exchanged = new ProviderTokens("naver-access", "naver-refresh");
        when(naverStrategy.validateAndGetSocialId("naver-access")).thenReturn(SOCIAL_ID);
        Member existing = memberWithUuid(AuthProvider.NAVER);
        when(memberRepository.findByAuthProviderAndProviderUserIdAndIsDeletedFalse(AuthProvider.NAVER, SOCIAL_ID))
                .thenReturn(Optional.of(existing));

        authService.loginWithExchangedTokens(AuthProvider.NAVER, exchanged);

        verify(naverStrategy, never()).verifyIssuedForThisApp(anyString());
        verify(memberSocialCredentialService).saveForUnlink(existing.getMemberUuid(), AuthProvider.NAVER, exchanged);
    }

    @Test
    void 토큰_직접_로그인도_access_token_을_연결_해제용으로_저장한다() {
        when(naverStrategy.validateAndGetSocialId("naver-sdk-token")).thenReturn(SOCIAL_ID);
        Member existing = memberWithUuid(AuthProvider.NAVER);
        when(memberRepository.findByAuthProviderAndProviderUserIdAndIsDeletedFalse(AuthProvider.NAVER, SOCIAL_ID))
                .thenReturn(Optional.of(existing));

        authService.login(new LoginCommand(AuthProvider.NAVER, "naver-sdk-token"));

        ArgumentCaptor<ProviderTokens> captor = ArgumentCaptor.forClass(ProviderTokens.class);
        verify(memberSocialCredentialService).saveForUnlink(eq(existing.getMemberUuid()), eq(AuthProvider.NAVER), captor.capture());
        assertThat(captor.getValue().accessToken()).isEqualTo("naver-sdk-token");
        assertThat(captor.getValue().refreshToken()).isNull();
    }

    @Test
    void 연결_해제용_자격_저장이_실패해도_로그인은_성공한다() {
        when(naverStrategy.validateAndGetSocialId("naver-sdk-token")).thenReturn(SOCIAL_ID);
        when(memberRepository.findByAuthProviderAndProviderUserIdAndIsDeletedFalse(AuthProvider.NAVER, SOCIAL_ID))
                .thenReturn(Optional.empty());
        when(nicknameGenerator.generateUnique(any())).thenReturn("새회원");
        Member saved = memberWithUuid(AuthProvider.NAVER);
        when(memberSignUpService.saveInNewTransaction(any())).thenReturn(saved);
        org.mockito.Mockito.doThrow(new IllegalStateException("encryption key mismatch"))
                .when(memberSocialCredentialService).saveForUnlink(any(), any(), any());

        LoginResult result = authService.login(new LoginCommand(AuthProvider.NAVER, "naver-sdk-token"));

        assertThat(result.member()).isSameAs(saved);
        assertThat(result.isNewMember()).isTrue();
        assertThat(result.tokens().refreshToken()).isNotBlank();
    }

    @Test
    void 로그인은_트랜잭션_밖에서_실행돼_외부_호출_중_DB_커넥션을_잡지_않는다() throws Exception {
        // 클래스 기본 readOnly 트랜잭션을 덮어써 제공자 API 호출(최대 5초 x 2) 동안 커넥션 미보유
        for (var method : java.util.List.of(
                AuthService.class.getMethod("login", LoginCommand.class),
                AuthService.class.getMethod("loginWithExchangedTokens", AuthProvider.class, ProviderTokens.class))) {
            Transactional transactional = method.getAnnotation(Transactional.class);
            assertThat(transactional).as(method.getName()).isNotNull();
            assertThat(transactional.propagation()).as(method.getName()).isEqualTo(Propagation.NOT_SUPPORTED);
        }
    }

    @Test
    void 제공자_토큰은_문자열로_찍혀도_값이_드러나지_않는다() {
        assertThat(new ProviderTokens("secret-access", "secret-refresh").toString())
                .doesNotContain("secret-access").doesNotContain("secret-refresh");
    }

    private static SocialLoginStrategy strategyOf(AuthProvider provider) {
        SocialLoginStrategy strategy = mock(SocialLoginStrategy.class);
        when(strategy.getAuthProvider()).thenReturn(provider);
        return strategy;
    }

    private static Member memberWithUuid(AuthProvider provider) {
        Member member = Member.signUp(SOCIAL_ID, provider, null, false, "기존회원");
        member.setMemberUuid(UUID.randomUUID());
        return member;
    }

    static JwtTokenProvider jwtTokenProvider() {
        return new JwtTokenProvider(new JwtProperties(
                new JwtProperties.TokenConfig(testKey('a'), Duration.ofMinutes(30)),
                new JwtProperties.TokenConfig(testKey('r'), Duration.ofDays(14))));
    }

    static String testKey(char filler) {
        return Base64.getEncoder().encodeToString(String.valueOf(filler).repeat(64).getBytes());
    }
}
