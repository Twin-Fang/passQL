package com.passql.member.auth.application;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.MemberActivityLogger;
import com.passql.common.util.NicknameGenerator;
import com.passql.member.auth.application.dto.command.LoginCommand;
import com.passql.member.auth.application.dto.result.LoginResult;
import com.passql.member.auth.domain.ProviderTokens;
import com.passql.member.auth.domain.Tokens;
import com.passql.member.auth.infrastructure.jwt.JwtTokenProvider;
import com.passql.member.auth.infrastructure.jwt.RefreshTokenClaims;
import com.passql.member.auth.infrastructure.social.strategy.SocialLoginStrategy;
import com.passql.member.auth.repository.RefreshTokenRepository;
import com.passql.member.constant.AuthProvider;
import com.passql.member.entity.Member;
import com.passql.member.repository.MemberRepository;
import com.passql.member.service.MemberSocialCredentialService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

/**
 * 인증: 소셜 로그인(가입 포함), 토큰 재발급, 로그아웃
 * 로그인: 토큰 검증(트랜잭션 밖) > 조회·가입(짧은 트랜잭션) > 자격 저장(짧은 트랜잭션) > 토큰 발급 (#516)
 * refresh token 은 기기(jti)별 저장·원자적 회전, 회전된 토큰 재사용 시 전체 세션 폐기, 옛 단일 키 형식 호환
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthService {

    private static final int NICKNAME_RETRY = 3;

    // 토큰 직접 로그인 불가 제공자: GitHub 은 앱·웹 모두 인가 코드 로그인만 사용 (출처 검증 수단 없음)
    private static final Set<AuthProvider> CODE_ONLY_PROVIDERS = Set.of(AuthProvider.GITHUB);

    private final MemberRepository memberRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtTokenProvider jwtTokenProvider;
    private final NicknameGenerator nicknameGenerator;
    private final Map<AuthProvider, SocialLoginStrategy> socialLoginStrategyMap;
    private final MemberSignUpService memberSignUpService;
    private final MemberSocialCredentialService memberSocialCredentialService;

    /** 클라이언트 토큰 로그인: 코드 전용 제공자 거부 > 발급 앱 검증 > 사용자 ID > 회원 조회·가입 */
    // 제공자 API 호출(최대 5초 x 2) 동안 DB 커넥션 미보유: 클래스 기본 트랜잭션 해제, 저장은 각 Repository·Service 트랜잭션
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public LoginResult login(LoginCommand command) {
        AuthProvider authProvider = command.authProvider();
        if (CODE_ONLY_PROVIDERS.contains(authProvider)) {
            log.warn("[social login] rejected 400 : direct token login not allowed ({})", authProvider);
            throw new CustomException(ErrorCode.UNSUPPORTED_AUTH_PROVIDER);
        }
        SocialLoginStrategy strategy = strategyOf(authProvider);
        strategy.verifyIssuedForThisApp(command.idToken());
        String socialId = strategy.validateAndGetSocialId(command.idToken());
        return loginVerifiedMember(authProvider, socialId, new ProviderTokens(command.idToken(), null));
    }

    /** 서버가 인가 코드로 교환한 토큰 로그인: 사용자 ID > 회원 조회·가입 (출처는 교환 단계에서 보장) */
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public LoginResult loginWithExchangedTokens(AuthProvider authProvider, ProviderTokens exchangedTokens) {
        String socialId = strategyOf(authProvider).validateAndGetSocialId(exchangedTokens.accessToken());
        return loginVerifiedMember(authProvider, socialId, exchangedTokens);
    }

    /** refresh token 재발급: 서명 검증 > 저장값 비교·삭제(원자적, 실패 시 재사용 판정) > 회원 확인 > 새 기기 키 발급 */
    public Tokens reissueTokens(String refreshToken) {
        RefreshTokenClaims claims = jwtTokenProvider.parseRefreshToken(refreshToken);
        if (!removeStoredRefreshTokenIfMatches(claims, refreshToken)) {
            revokeAllSessionsIfReused(claims);
            throw new CustomException(ErrorCode.INVALID_TOKEN);
        }

        Member member = memberRepository.findByMemberUuidAndIsDeletedFalse(claims.memberUuid())
                .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));
        return issueTokens(member);
    }

    /** 로그아웃: 저장값과 일치할 때만 그 기기 키 삭제 (만료 토큰도 허용, 다른 기기 세션 유지) */
    public void logout(String refreshToken) {
        jwtTokenProvider.parseRefreshTokenSilently(refreshToken)
                .filter(claims -> removeStoredRefreshTokenIfMatches(claims, refreshToken))
                .ifPresent(claims -> log.info("[auth] logout memberUuid={}", claims.memberUuid()));
    }

    private SocialLoginStrategy strategyOf(AuthProvider authProvider) {
        SocialLoginStrategy strategy = socialLoginStrategyMap.get(authProvider);
        if (strategy == null) {
            throw new CustomException(ErrorCode.UNSUPPORTED_AUTH_PROVIDER);
        }
        return strategy;
    }

    /** 검증된 제공자 키 > 기존 회원 또는 신규 가입 > 연결 해제용 자격 저장 > 토큰 발급 */
    private LoginResult loginVerifiedMember(AuthProvider authProvider, String socialId, ProviderTokens providerTokens) {
        ResolvedMember resolved = findActiveMember(authProvider, socialId)
                .map(existing -> new ResolvedMember(existing, false))
                .orElseGet(() -> registerNewMember(socialId, authProvider));
        Member member = resolved.member();
        boolean isNewMember = resolved.isNewMember();

        saveCredentialQuietly(member.getMemberUuid(), authProvider, providerTokens);
        Tokens tokens = issueTokens(member);
        MemberActivityLogger.recordLogin(member.getMemberUuid(), authProvider, isNewMember);
        return LoginResult.of(member, isNewMember, tokens);
    }

    /** 연결 해제용 자격 저장 (실패해도 로그인 유지, 탈퇴 시 해제만 건너뜀) */
    private void saveCredentialQuietly(UUID memberUuid, AuthProvider authProvider, ProviderTokens providerTokens) {
        try {
            memberSocialCredentialService.saveForUnlink(memberUuid, authProvider, providerTokens);
        } catch (RuntimeException e) {
            log.warn("[social login] credential save failed provider={} memberUuid={} : {}",
                    authProvider, memberUuid, e.getClass().getSimpleName());
        }
    }

    private Optional<Member> findActiveMember(AuthProvider authProvider, String socialId) {
        return memberRepository.findByAuthProviderAndProviderUserIdAndIsDeletedFalse(authProvider, socialId);
    }

    /**
     * 신규 가입 (별도 트랜잭션 저장): 유니크 충돌 시 제공자 키 재조회
     * 같은 제공자 키 회원이 이미 있으면 그 회원(동시 가입), 없으면 닉네임 충돌로 보고 재시도
     */
    private ResolvedMember registerNewMember(String socialId, AuthProvider authProvider) {
        for (int attempt = 1; attempt <= NICKNAME_RETRY; attempt++) {
            String nickname = nicknameGenerator.generateUnique(
                    memberRepository::existsByNicknameAndIsDeletedFalse);
            Member member = Member.signUp(socialId, authProvider, null, false, nickname);
            try {
                return new ResolvedMember(memberSignUpService.saveInNewTransaction(member), true);
            } catch (DataIntegrityViolationException e) {
                Optional<Member> concurrentlyRegistered = findActiveMember(authProvider, socialId);
                if (concurrentlyRegistered.isPresent()) {
                    log.warn("[auth] provider key conflict : returning existing member ({})", authProvider);
                    return new ResolvedMember(concurrentlyRegistered.get(), false);
                }
                log.warn("[auth] nickname conflict retry {}/{}", attempt, NICKNAME_RETRY);
                if (attempt == NICKNAME_RETRY) {
                    throw new CustomException(ErrorCode.NICKNAME_GENERATION_FAILED, e);
                }
            }
        }
        throw new CustomException(ErrorCode.NICKNAME_GENERATION_FAILED);
    }

    /** 액세스 + 기기 ID 새로 만든 refresh 발급 > 기기 키 저장 */
    private Tokens issueTokens(Member member) {
        String tokenId = UUID.randomUUID().toString();
        String accessToken = jwtTokenProvider.createAccessToken(member);
        String refreshToken = jwtTokenProvider.createRefreshToken(member, tokenId);
        refreshTokenRepository.save(member.getMemberUuid(), tokenId, refreshToken,
                jwtTokenProvider.getRefreshTokenExpirationMillis());
        return new Tokens(accessToken, refreshToken);
    }

    /** 저장값 일치 시 삭제 (옛 형식은 단일 키, 새 형식은 기기 키), 삭제했으면 true */
    private boolean removeStoredRefreshTokenIfMatches(RefreshTokenClaims claims, String refreshToken) {
        return claims.isLegacyFormat()
                ? refreshTokenRepository.deleteLegacyIfMatches(claims.memberUuid(), refreshToken)
                : refreshTokenRepository.deleteIfMatches(claims.memberUuid(), claims.tokenId(), refreshToken);
    }

    /** 서명 유효한데 키 없음 + 기기 목록에도 없음 = 이미 회전된 토큰 재사용 (탈취 의심) > 회원 전체 세션 폐기 */
    private void revokeAllSessionsIfReused(RefreshTokenClaims claims) {
        if (claims.isLegacyFormat() || refreshTokenRepository.isActiveTokenId(claims.memberUuid(), claims.tokenId())) {
            return;
        }
        refreshTokenRepository.deleteAllByMemberUuid(claims.memberUuid());
        log.warn("[auth] refresh token reuse detected memberUuid={}", claims.memberUuid());
    }

    /** 로그인 대상 회원 + 이번 요청으로 가입했는지 */
    private record ResolvedMember(Member member, boolean isNewMember) {
    }
}
