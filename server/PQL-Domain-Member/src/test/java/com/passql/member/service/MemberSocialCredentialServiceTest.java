package com.passql.member.service;

import com.passql.common.crypto.SecretValueCipher;
import com.passql.member.auth.domain.ProviderTokens;
import com.passql.member.constant.AuthProvider;
import com.passql.member.entity.MemberSocialCredential;
import com.passql.member.repository.MemberSocialCredentialRepository;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 연결 해제용 제공자 자격 저장 (#516): GitHub·네이버만, 암호화 저장, 로그인마다 갱신(새 refresh 없으면 기존 유지)
 */
class MemberSocialCredentialServiceTest {

    /** 테스트용 가역 암호기: enc:{aad}:{뒤집은 평문} */
    private static final SecretValueCipher FAKE_CIPHER = new SecretValueCipher() {
        @Override
        public String encrypt(String associatedData, String plainValue) {
            return "enc:" + associatedData + ":" + new StringBuilder(plainValue).reverse();
        }

        @Override
        public String decrypt(String associatedData, String storedValue) {
            String prefix = "enc:" + associatedData + ":";
            if (!storedValue.startsWith(prefix)) {
                throw new IllegalStateException("associated data mismatch");
            }
            return new StringBuilder(storedValue.substring(prefix.length())).reverse().toString();
        }
    };

    private final MemberSocialCredentialRepository repository = mock(MemberSocialCredentialRepository.class);
    private final MemberSocialCredentialService service = new MemberSocialCredentialService(repository, FAKE_CIPHER);
    private final UUID memberUuid = UUID.randomUUID();

    @Test
    void GitHub_자격은_암호화해_저장하고_복호화해_읽는다() {
        when(repository.findById(memberUuid)).thenReturn(Optional.empty());

        service.saveForUnlink(memberUuid, AuthProvider.GITHUB, new ProviderTokens("gho_plain", null));

        ArgumentCaptor<MemberSocialCredential> captor = ArgumentCaptor.forClass(MemberSocialCredential.class);
        verify(repository).save(captor.capture());
        MemberSocialCredential saved = captor.getValue();
        assertThat(saved.getEncryptedAccessToken()).doesNotContain("gho_plain");
        assertThat(saved.getEncryptedRefreshToken()).isNull();

        when(repository.findById(memberUuid)).thenReturn(Optional.of(saved));
        assertThat(service.findTokens(memberUuid)).get()
                .extracting(ProviderTokens::accessToken).isEqualTo("gho_plain");
    }

    @Test
    void 해제에_토큰이_필요_없는_제공자는_저장하지_않는다() {
        service.saveForUnlink(memberUuid, AuthProvider.KAKAO, new ProviderTokens("kakao-access", null));
        service.saveForUnlink(memberUuid, AuthProvider.GOOGLE, new ProviderTokens("firebase-id-token", null));

        verify(repository, never()).save(any());
    }

    @Test
    void 다시_로그인하면_access_는_갱신하고_새_refresh_가_없으면_기존_refresh_를_유지한다() {
        when(repository.findById(memberUuid)).thenReturn(Optional.empty());
        service.saveForUnlink(memberUuid, AuthProvider.NAVER, new ProviderTokens("access-1", "refresh-1"));
        ArgumentCaptor<MemberSocialCredential> captor = ArgumentCaptor.forClass(MemberSocialCredential.class);
        verify(repository).save(captor.capture());
        MemberSocialCredential existing = captor.getValue();

        when(repository.findById(memberUuid)).thenReturn(Optional.of(existing));
        service.saveForUnlink(memberUuid, AuthProvider.NAVER, new ProviderTokens("access-2", null));

        ProviderTokens tokens = service.findTokens(memberUuid).orElseThrow();
        assertThat(tokens.accessToken()).isEqualTo("access-2");
        assertThat(tokens.refreshToken()).isEqualTo("refresh-1");
    }
}
