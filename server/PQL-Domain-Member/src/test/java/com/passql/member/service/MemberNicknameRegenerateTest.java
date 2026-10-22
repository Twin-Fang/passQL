package com.passql.member.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.NicknameGenerator;
import com.passql.member.constant.AuthProvider;
import com.passql.member.dto.NicknameChangeRequest;
import com.passql.member.dto.NicknameRegenerateResponse;
import com.passql.member.entity.Member;
import com.passql.member.repository.MemberRepository;
import org.junit.jupiter.api.Test;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/** 닉네임 랜덤 재생성: 3일 쿨다운 공유 (#579) */
class MemberNicknameRegenerateTest {

    private final MemberRepository memberRepository = mock(MemberRepository.class);
    private final NicknameGenerator nicknameGenerator = mock(NicknameGenerator.class);
    private final MemberService service = new MemberService(
            memberRepository, nicknameGenerator, null, null, null, null);

    private final UUID memberUuid = UUID.randomUUID();
    private final Member member = Member.signUp("provider-user", AuthProvider.GOOGLE, null, true, "처음닉네임");

    private void givenActiveMember() {
        when(memberRepository.findByMemberUuidAndIsDeletedFalse(memberUuid)).thenReturn(Optional.of(member));
        when(nicknameGenerator.generateUnique(any())).thenReturn("새닉네임");
    }

    @Test
    void 재생성하면_닉네임이_바뀌고_쿨다운이_시작된다() {
        givenActiveMember();

        NicknameRegenerateResponse response = service.regenerateNickname(memberUuid);

        assertThat(response.getNickname()).isEqualTo("새닉네임");
        assertThat(member.isNicknameChangeCooldown()).isTrue();
    }

    @Test
    void 쿨다운_중에는_재생성을_거절하고_닉네임을_유지한다() {
        givenActiveMember();
        member.changeNickname("직접바꾼닉");

        assertThatThrownBy(() -> service.regenerateNickname(memberUuid))
                .isInstanceOfSatisfying(CustomException.class,
                        exception -> assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.NICKNAME_COOLDOWN));
        assertThat(member.getNickname()).isEqualTo("직접바꾼닉");
    }

    @Test
    void 재생성_직후에는_직접_변경도_거절한다() {
        givenActiveMember();
        service.regenerateNickname(memberUuid);

        assertThatThrownBy(() -> service.changeNickname(memberUuid, new NicknameChangeRequest("다른닉")))
                .isInstanceOfSatisfying(CustomException.class,
                        exception -> assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.NICKNAME_COOLDOWN));
    }
}
