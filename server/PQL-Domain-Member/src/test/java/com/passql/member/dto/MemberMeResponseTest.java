package com.passql.member.dto;

import com.passql.member.constant.AuthProvider;
import com.passql.member.entity.Member;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 본인 정보 응답 (#516): 앱·웹 탈퇴 분기 원본 authProvider, 재인증 계정 대조용 providerUserId 포함
 */
class MemberMeResponseTest {

    @Test
    void 본인_정보에_가입_제공자를_담는다() {
        Member member = Member.signUp("apple-uid", AuthProvider.APPLE, null, false, "애플회원");
        member.setMemberUuid(UUID.randomUUID());

        MemberMeResponse response = MemberMeResponse.from(member);

        assertThat(response.getAuthProvider()).isEqualTo(AuthProvider.APPLE);
        assertThat(response.getProviderUserId()).isEqualTo("apple-uid");
    }
}
