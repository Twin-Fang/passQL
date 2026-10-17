package com.passql.member.auth.application;

import com.passql.member.auth.domain.ProviderTokens;
import com.passql.member.auth.infrastructure.social.unlink.SocialUnlinkClient;
import com.passql.member.constant.AuthProvider;
import com.passql.member.event.MemberWithdrawnEvent;
import com.passql.member.repository.MemberRepository;
import com.passql.member.service.MemberSocialCredentialService;
import org.junit.jupiter.api.Test;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 탈퇴 후 제공자 연결 해제 (#516): 제공자별 해제 호출, 실패해도 예외 없음, 저장 자격은 항상 삭제
 */
class SocialUnlinkServiceTest {

    private final SocialUnlinkClient socialUnlinkClient = mock(SocialUnlinkClient.class);
    private final MemberSocialCredentialService credentialService = mock(MemberSocialCredentialService.class);
    private final MemberRepository memberRepository = mock(MemberRepository.class);
    private final SocialUnlinkService service = new SocialUnlinkService(socialUnlinkClient, credentialService, memberRepository);
    private final UUID memberUuid = UUID.randomUUID();

    @Test
    void 카카오는_관리자_키로_사용자_ID_연결을_끊는다() {
        service.onMemberWithdrawn(new MemberWithdrawnEvent(memberUuid, AuthProvider.KAKAO, "4242"));

        verify(socialUnlinkClient).unlinkKakaoUser("4242");
        verify(credentialService).deleteByMemberUuid(memberUuid);
    }

    @Test
    void GitHub_은_저장된_access_token_으로_앱_권한을_회수한다() {
        when(credentialService.findTokens(memberUuid)).thenReturn(Optional.of(new ProviderTokens("gho_access", null)));

        service.onMemberWithdrawn(new MemberWithdrawnEvent(memberUuid, AuthProvider.GITHUB, "777"));

        verify(socialUnlinkClient).revokeGithubGrant("gho_access");
        verify(credentialService).deleteByMemberUuid(memberUuid);
    }

    @Test
    void 저장된_자격이_없으면_GitHub_해제를_건너뛴다() {
        when(credentialService.findTokens(memberUuid)).thenReturn(Optional.empty());

        service.onMemberWithdrawn(new MemberWithdrawnEvent(memberUuid, AuthProvider.GITHUB, "777"));

        verify(socialUnlinkClient, never()).revokeGithubGrant(any());
        verify(credentialService).deleteByMemberUuid(memberUuid);
    }

    @Test
    void 네이버는_저장된_토큰으로_연동을_삭제한다() {
        ProviderTokens naverTokens = new ProviderTokens("naver-access", "naver-refresh");
        when(credentialService.findTokens(memberUuid)).thenReturn(Optional.of(naverTokens));

        service.onMemberWithdrawn(new MemberWithdrawnEvent(memberUuid, AuthProvider.NAVER, "naver-id"));

        verify(socialUnlinkClient).deleteNaverToken(naverTokens);
    }

    @Test
    void 구글과_애플은_Firebase_사용자를_삭제한다() {
        service.onMemberWithdrawn(new MemberWithdrawnEvent(memberUuid, AuthProvider.GOOGLE, "firebase-uid-g"));
        service.onMemberWithdrawn(new MemberWithdrawnEvent(memberUuid, AuthProvider.APPLE, "firebase-uid-a"));

        verify(socialUnlinkClient).deleteFirebaseUser("firebase-uid-g");
        verify(socialUnlinkClient).deleteFirebaseUser("firebase-uid-a");
    }

    @Test
    void 탈퇴_직후_같은_Firebase_uid_로_재가입한_활성_회원이_있으면_Firebase_사용자를_지우지_않는다() {
        when(memberRepository.existsByProviderUserIdAndAuthProviderInAndIsDeletedFalse(
                org.mockito.ArgumentMatchers.eq("firebase-uid-g"), any())).thenReturn(true);

        service.onMemberWithdrawn(new MemberWithdrawnEvent(memberUuid, AuthProvider.GOOGLE, "firebase-uid-g"));

        verify(socialUnlinkClient, never()).deleteFirebaseUser(any());
        verify(credentialService).deleteByMemberUuid(memberUuid);
    }

    @Test
    void 해제_호출이_실패해도_예외를_던지지_않고_자격은_삭제한다() {
        doThrow(new IllegalStateException("kakao 500")).when(socialUnlinkClient).unlinkKakaoUser("4242");

        assertThatCode(() -> service.onMemberWithdrawn(new MemberWithdrawnEvent(memberUuid, AuthProvider.KAKAO, "4242")))
                .doesNotThrowAnyException();
        verify(credentialService).deleteByMemberUuid(memberUuid);
    }
}
