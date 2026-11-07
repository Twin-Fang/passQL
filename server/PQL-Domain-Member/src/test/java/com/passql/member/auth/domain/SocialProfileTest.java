package com.passql.member.auth.domain;

import com.passql.member.constant.AuthProvider;
import com.passql.member.entity.Member;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 소셜 정보 저장 판정 (#908): 값 정리, 기존 회원 갱신 규칙
 */
class SocialProfileTest {

    @Test
    void 이미지_http_주소는_https_로_바꾸고_http_아닌_주소는_버린다() {
        assertThat(new SocialProfile("1", null, false, "http://k.kakaocdn.net/dn/a.jpg").profileImageUrl())
                .isEqualTo("https://k.kakaocdn.net/dn/a.jpg");
        assertThat(new SocialProfile("1", null, false, "javascript:alert(1)").profileImageUrl()).isNull();
        assertThat(new SocialProfile("1", null, false, "https://" + "a".repeat(SocialProfile.MAX_PROFILE_IMAGE_URL_LENGTH)).profileImageUrl())
                .isNull();
    }

    @Test
    void 빈_이메일은_없음으로_보고_인증_여부도_끈다() {
        SocialProfile blankEmailProfile = new SocialProfile("1", "  ", true, null);
        assertThat(blankEmailProfile.email()).isNull();
        assertThat(blankEmailProfile.isEmailVerified()).isFalse();
    }

    @Test
    void 기존_회원_갱신은_이메일이_없으면_유지하고_이미지는_최신_값을_따른다() {
        Member member = Member.signUp("1", AuthProvider.KAKAO, "old@kakao.com", true, "https://img/old.jpg", "닉네임");

        boolean isChanged = member.applySocialProfile(null, false, null);

        assertThat(isChanged).isTrue();
        assertThat(member.getEmail()).isEqualTo("old@kakao.com");
        assertThat(member.getProfileImageUrl()).isNull();
        assertThat(member.applySocialProfile(null, false, null)).isFalse();
    }
}
