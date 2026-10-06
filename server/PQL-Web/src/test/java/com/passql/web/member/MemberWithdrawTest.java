package com.passql.web.member;

import com.passql.member.service.MemberService;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.NicknameGenerator;
import com.passql.member.auth.repository.RefreshTokenRepository;
import com.passql.member.constant.AuthProvider;
import com.passql.member.constant.MemberStatus;
import com.passql.member.entity.Member;
import com.passql.member.repository.MemberRepository;
import com.passql.member.repository.MemberSuspendHistoryRepository;
import org.junit.jupiter.api.Test;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/** 회원 탈퇴 규칙 단위 테스트. DB, Redis 없이 협력 객체를 목으로 대체한다. */
class MemberWithdrawTest {

    private final MemberRepository memberRepository = mock(MemberRepository.class);
    private final RefreshTokenRepository refreshTokenRepository = mock(RefreshTokenRepository.class);
    private final MemberService service = new MemberService(
            memberRepository, mock(NicknameGenerator.class),
            mock(MemberSuspendHistoryRepository.class), refreshTokenRepository);

    private Member activeMember(UUID uuid) {
        Member m = Member.signUp("google-123", AuthProvider.GOOGLE, "a@b.com", true, "원래닉네임");
        m.setMemberUuid(uuid);
        when(memberRepository.findByMemberUuidAndIsDeletedFalse(uuid)).thenReturn(Optional.of(m));
        return m;
    }

    @Test
    void 탈퇴하면_개인정보를_비우고_닉네임을_익명화하며_삭제_처리한다() {
        UUID uuid = UUID.randomUUID();
        Member m = activeMember(uuid);

        service.withdraw(uuid);

        assertEquals(MemberStatus.WITHDRAWN, m.getStatus());
        assertNotNull(m.getWithdrawnAt());
        assertNull(m.getEmail());
        assertEquals("탈퇴회원_" + uuid.toString().substring(0, 8), m.getNickname());
        assertEquals("withdrawn:" + uuid, m.getProviderUserId());
        assertTrue(m.getIsDeleted());
    }

    @Test
    void 탈퇴하면_리프레시_토큰을_삭제해_재발급을_막는다() {
        UUID uuid = UUID.randomUUID();
        activeMember(uuid);

        service.withdraw(uuid);

        verify(refreshTokenRepository).delete(uuid);
    }

    @Test
    void 이미_탈퇴했거나_없는_회원은_MEMBER_NOT_FOUND() {
        UUID uuid = UUID.randomUUID();
        when(memberRepository.findByMemberUuidAndIsDeletedFalse(uuid)).thenReturn(Optional.empty());

        CustomException e = assertThrows(CustomException.class, () -> service.withdraw(uuid));

        assertEquals(ErrorCode.MEMBER_NOT_FOUND, e.getErrorCode());
        verify(refreshTokenRepository, never()).delete(any());
    }
}
