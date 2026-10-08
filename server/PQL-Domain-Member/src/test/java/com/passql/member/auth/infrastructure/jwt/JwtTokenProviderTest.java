package com.passql.member.auth.infrastructure.jwt;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.AuthProvider;
import com.passql.member.constant.MemberRole;
import com.passql.member.entity.Member;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.Duration;
import java.util.Base64;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * jjwt 0.11 → 0.13 API 이전 회귀 테스트 (dependabot #419).
 * 운영 로그인은 Google 계정이 있어야 해 배포 후 직접 확인할 수 없으므로, 발급·검증 왕복을 여기서 고정한다.
 */
class JwtTokenProviderTest {

    private static String key(char c) {
        return Base64.getEncoder().encodeToString(String.valueOf(c).repeat(64).getBytes());
    }

    private final JwtTokenProvider provider = new JwtTokenProvider(new JwtProperties(
            new JwtProperties.TokenConfig(key('a'), Duration.ofMinutes(30)),
            new JwtProperties.TokenConfig(key('r'), Duration.ofDays(14))));

    private Member member() {
        Member m = Member.signUp("google-1", AuthProvider.GOOGLE, "t@passql.kr", true, "테스터");
        ReflectionTestUtils.setField(m, "memberUuid", UUID.randomUUID());
        return m;
    }

    @Test
    void 액세스_토큰_발급_후_회원과_권한을_읽는다() {
        Member m = member();
        String token = provider.createAccessToken(m);

        assertThat(provider.getMemberUuidFromAccessToken(token)).isEqualTo(m.getMemberUuid());
        assertThat(provider.getRoleFromAccessToken(token)).isEqualTo(MemberRole.USER);
    }

    @Test
    void 리프레시_토큰_발급_후_회원을_읽는다() {
        Member m = member();
        String token = provider.createRefreshToken(m);

        assertThat(provider.getMemberUuidFromRefreshToken(token)).isEqualTo(m.getMemberUuid());
        assertThat(provider.getMemberUuidFromRefreshTokenSilently(token)).contains(m.getMemberUuid());
    }

    @Test
    void 다른_키로_서명된_토큰은_INVALID_TOKEN() {
        String access = provider.createAccessToken(member());

        // 액세스 토큰을 리프레시로 쓰면 서명 키가 달라 거부돼야 한다
        assertThatThrownBy(() -> provider.getMemberUuidFromRefreshToken(access))
                .isInstanceOfSatisfying(CustomException.class,
                        e -> assertThat(e.getErrorCode()).isEqualTo(ErrorCode.INVALID_TOKEN));
        assertThat(provider.getMemberUuidFromRefreshTokenSilently(access)).isEmpty();
    }

    @Test
    void 만료된_액세스_토큰은_ACCESS_TOKEN_EXPIRED_만료된_리프레시는_조용히_회원을_돌려준다() {
        JwtTokenProvider expired = new JwtTokenProvider(new JwtProperties(
                new JwtProperties.TokenConfig(key('a'), Duration.ofSeconds(-10)),
                new JwtProperties.TokenConfig(key('r'), Duration.ofSeconds(-10))));
        Member m = member();

        assertThatThrownBy(() -> expired.getMemberUuidFromAccessToken(expired.createAccessToken(m)))
                .isInstanceOfSatisfying(CustomException.class,
                        e -> assertThat(e.getErrorCode()).isEqualTo(ErrorCode.ACCESS_TOKEN_EXPIRED));
        assertThat(expired.getMemberUuidFromRefreshTokenSilently(expired.createRefreshToken(m)))
                .contains(m.getMemberUuid());
    }
}
