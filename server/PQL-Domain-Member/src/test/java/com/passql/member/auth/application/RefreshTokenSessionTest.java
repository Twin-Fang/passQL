package com.passql.member.auth.application;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.NicknameGenerator;
import com.passql.member.auth.domain.Tokens;
import com.passql.member.auth.infrastructure.jwt.JwtTokenProvider;
import com.passql.member.auth.infrastructure.jwt.RefreshTokenClaims;
import com.passql.member.auth.repository.RefreshTokenRepository;
import com.passql.member.constant.AuthProvider;
import com.passql.member.entity.Member;
import com.passql.member.repository.MemberRepository;
import com.passql.member.service.MemberSocialCredentialService;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.junit.jupiter.api.Test;

import java.util.Date;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 기기별 refresh token 세션 (#516): 기기(jti)별 저장 > 재발급 회전(비교·삭제 원자적) > 재사용 감지 시 전체 폐기
 * 일치할 때만 로그아웃, 옛 단일 키 형식 호환
 */
class RefreshTokenSessionTest {

    private final MemberRepository memberRepository = mock(MemberRepository.class);
    private final RefreshTokenRepository refreshTokenRepository = mock(RefreshTokenRepository.class);
    private final JwtTokenProvider jwtTokenProvider = AuthServiceLoginTest.jwtTokenProvider();
    private final AuthService authService = new AuthService(
            memberRepository, refreshTokenRepository, jwtTokenProvider, mock(NicknameGenerator.class),
            Map.of(), mock(MemberSignUpService.class), mock(MemberSocialCredentialService.class));

    private Member activeMember() {
        Member member = Member.signUp("social-1", AuthProvider.KAKAO, null, false, "세션회원");
        member.setMemberUuid(UUID.randomUUID());
        when(memberRepository.findByMemberUuidAndIsDeletedFalse(member.getMemberUuid())).thenReturn(Optional.of(member));
        return member;
    }

    @Test
    void 리프레시_토큰마다_기기_ID_가_달라_기기별로_저장된다() {
        Member member = activeMember();
        String first = jwtTokenProvider.createRefreshToken(member);
        String second = jwtTokenProvider.createRefreshToken(member);

        RefreshTokenClaims firstClaims = jwtTokenProvider.parseRefreshToken(first);
        RefreshTokenClaims secondClaims = jwtTokenProvider.parseRefreshToken(second);

        assertThat(firstClaims.memberUuid()).isEqualTo(member.getMemberUuid());
        assertThat(firstClaims.tokenId()).isNotBlank();
        assertThat(firstClaims.tokenId()).isNotEqualTo(secondClaims.tokenId());
        assertThat(firstClaims.isLegacyFormat()).isFalse();
    }

    @Test
    void 재발급은_그_기기_키만_회전한다() {
        Member member = activeMember();
        String refreshToken = jwtTokenProvider.createRefreshToken(member);
        String tokenId = jwtTokenProvider.parseRefreshToken(refreshToken).tokenId();
        when(refreshTokenRepository.deleteIfMatches(member.getMemberUuid(), tokenId, refreshToken)).thenReturn(true);

        Tokens reissued = authService.reissueTokens(refreshToken);

        String newTokenId = jwtTokenProvider.parseRefreshToken(reissued.refreshToken()).tokenId();
        assertThat(newTokenId).isNotEqualTo(tokenId);
        verify(refreshTokenRepository).save(eq(member.getMemberUuid()), eq(newTokenId), eq(reissued.refreshToken()), anyLong());
        verify(refreshTokenRepository, never()).deleteAllByMemberUuid(any());
    }

    @Test
    void 이미_회전된_토큰이_다시_오면_재사용으로_보고_회원_세션을_모두_폐기한다() {
        Member member = activeMember();
        String refreshToken = jwtTokenProvider.createRefreshToken(member);
        String tokenId = jwtTokenProvider.parseRefreshToken(refreshToken).tokenId();
        // 키 없음 + 기기 목록에도 없음 = 회전으로 이미 폐기된 토큰
        when(refreshTokenRepository.deleteIfMatches(member.getMemberUuid(), tokenId, refreshToken)).thenReturn(false);
        when(refreshTokenRepository.isActiveTokenId(member.getMemberUuid(), tokenId)).thenReturn(false);

        assertThatThrownBy(() -> authService.reissueTokens(refreshToken))
                .isInstanceOfSatisfying(CustomException.class,
                        e -> assertThat(e.getErrorCode()).isEqualTo(ErrorCode.INVALID_TOKEN));
        verify(refreshTokenRepository).deleteAllByMemberUuid(member.getMemberUuid());
        verify(refreshTokenRepository, never()).save(any(), anyString(), anyString(), anyLong());
    }

    @Test
    void 기기_목록에_남은_토큰의_값만_다르면_세션을_폐기하지_않고_거부한다() {
        Member member = activeMember();
        String refreshToken = jwtTokenProvider.createRefreshToken(member);
        String tokenId = jwtTokenProvider.parseRefreshToken(refreshToken).tokenId();
        when(refreshTokenRepository.deleteIfMatches(member.getMemberUuid(), tokenId, refreshToken)).thenReturn(false);
        when(refreshTokenRepository.isActiveTokenId(member.getMemberUuid(), tokenId)).thenReturn(true);

        assertThatThrownBy(() -> authService.reissueTokens(refreshToken))
                .isInstanceOfSatisfying(CustomException.class,
                        e -> assertThat(e.getErrorCode()).isEqualTo(ErrorCode.INVALID_TOKEN));
        verify(refreshTokenRepository, never()).deleteAllByMemberUuid(any());
    }

    @Test
    void 옛_단일_키_형식_토큰도_재발급되고_기기별_키로_옮겨진다() {
        Member member = activeMember();
        String legacyToken = createLegacyRefreshToken(member.getMemberUuid());
        when(refreshTokenRepository.deleteLegacyIfMatches(member.getMemberUuid(), legacyToken)).thenReturn(true);

        Tokens reissued = authService.reissueTokens(legacyToken);

        String newTokenId = jwtTokenProvider.parseRefreshToken(reissued.refreshToken()).tokenId();
        verify(refreshTokenRepository).save(eq(member.getMemberUuid()), eq(newTokenId), eq(reissued.refreshToken()), anyLong());
    }

    @Test
    void 로그아웃은_저장값과_일치할_때만_그_기기_키를_지운다() {
        Member member = activeMember();
        String refreshToken = jwtTokenProvider.createRefreshToken(member);
        String tokenId = jwtTokenProvider.parseRefreshToken(refreshToken).tokenId();
        when(refreshTokenRepository.deleteIfMatches(member.getMemberUuid(), tokenId, refreshToken)).thenReturn(true);

        authService.logout(refreshToken);

        verify(refreshTokenRepository).deleteIfMatches(member.getMemberUuid(), tokenId, refreshToken);
        verify(refreshTokenRepository, never()).deleteAllByMemberUuid(any());
    }

    @Test
    void 저장값과_다른_토큰으로_로그아웃하면_세션을_폐기하지_않는다() {
        Member member = activeMember();
        String refreshToken = jwtTokenProvider.createRefreshToken(member);
        when(refreshTokenRepository.deleteIfMatches(any(), anyString(), anyString())).thenReturn(false);

        authService.logout(refreshToken);

        verify(refreshTokenRepository, never()).deleteAllByMemberUuid(any());
        verify(refreshTokenRepository, never()).deleteLegacyIfMatches(any(), anyString());
    }

    @Test
    void 옛_형식_토큰으로_로그아웃하면_옛_키를_지운다() {
        Member member = activeMember();
        String legacyToken = createLegacyRefreshToken(member.getMemberUuid());
        when(refreshTokenRepository.deleteLegacyIfMatches(member.getMemberUuid(), legacyToken)).thenReturn(true);

        authService.logout(legacyToken);

        verify(refreshTokenRepository).deleteLegacyIfMatches(member.getMemberUuid(), legacyToken);
    }

    /** jti 없는 옛 형식 refresh token (배포 전 발급분) */
    private static String createLegacyRefreshToken(UUID memberUuid) {
        Date now = new Date();
        return Jwts.builder()
                .subject(memberUuid.toString())
                .issuedAt(now)
                .expiration(new Date(now.getTime() + 60_000))
                .signWith(Keys.hmacShaKeyFor(Decoders.BASE64.decode(AuthServiceLoginTest.testKey('r'))))
                .compact();
    }
}
