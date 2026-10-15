package com.passql.member.service;

import com.passql.member.constant.PushPlatform;
import com.passql.member.dto.PushTokenRegisterRequest;
import com.passql.member.dto.PushTokenResponse;
import com.passql.member.entity.MemberPushToken;
import com.passql.member.repository.MemberPushTokenRepository;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 기기 푸시 토큰 등록: 새 기기, 소유자 이전, 수신 동의 유지·변경 (#467) */
class MemberPushTokenServiceTest {

    private final MemberPushTokenRepository memberPushTokenRepository = mock(MemberPushTokenRepository.class);
    private final MemberPushTokenService service = new MemberPushTokenService(memberPushTokenRepository);

    @Test
    void 새_기기_토큰은_수신_동의_켬으로_저장한다() {
        UUID memberUuid = UUID.randomUUID();
        when(memberPushTokenRepository.findByToken("token-new")).thenReturn(Optional.empty());

        PushTokenResponse response = service.registerToken(memberUuid, new PushTokenRegisterRequest("token-new", "IOS", null));

        ArgumentCaptor<MemberPushToken> saved = ArgumentCaptor.forClass(MemberPushToken.class);
        verify(memberPushTokenRepository).save(saved.capture());
        assertThat(saved.getValue().getMemberUuid()).isEqualTo(memberUuid);
        assertThat(saved.getValue().getPlatform()).isEqualTo(PushPlatform.IOS);
        assertThat(response.isPushEnabled()).isTrue();
    }

    @Test
    void 다른_회원_토큰이면_요청_회원으로_소유자를_옮기고_수신_동의를_켠다() {
        UUID previousOwnerUuid = UUID.randomUUID();
        UUID newOwnerUuid = UUID.randomUUID();
        MemberPushToken existing = MemberPushToken.create(previousOwnerUuid, "token-shared", PushPlatform.ANDROID);
        existing.refresh(PushPlatform.ANDROID, false);
        when(memberPushTokenRepository.findByToken("token-shared")).thenReturn(Optional.of(existing));

        PushTokenResponse response = service.registerToken(newOwnerUuid,
                new PushTokenRegisterRequest("token-shared", "ANDROID", null));

        assertThat(existing.getMemberUuid()).isEqualTo(newOwnerUuid);
        assertThat(response.isPushEnabled()).isTrue();
    }

    @Test
    void 같은_회원은_수신_동의를_요청값으로_바꾸고_생략하면_유지한다() {
        UUID memberUuid = UUID.randomUUID();
        MemberPushToken existing = MemberPushToken.create(memberUuid, "token-mine", PushPlatform.IOS);
        when(memberPushTokenRepository.findByToken("token-mine")).thenReturn(Optional.of(existing));

        assertThat(service.registerToken(memberUuid, new PushTokenRegisterRequest("token-mine", "IOS", false))
                .isPushEnabled()).isFalse();
        assertThat(service.registerToken(memberUuid, new PushTokenRegisterRequest("token-mine", "IOS", null))
                .isPushEnabled()).isFalse();
        verify(memberPushTokenRepository, org.mockito.Mockito.times(2)).save(any());
    }
}
