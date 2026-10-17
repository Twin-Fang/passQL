package com.passql.member.service;

import com.passql.common.crypto.SecretValueCipher;
import com.passql.member.auth.domain.ProviderTokens;
import com.passql.member.constant.AuthProvider;
import com.passql.member.entity.MemberSocialCredential;
import com.passql.member.repository.MemberSocialCredentialRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.Set;
import java.util.UUID;

/**
 * 연결 해제용 제공자 자격 (#516): 암호화 저장, 복호화 조회, 삭제
 * 암호화 AAD = member_social_credential:{memberUuid}:{access|refresh} (다른 회원 행으로 옮긴 값은 복호화 실패)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberSocialCredentialService {

    // 해제에 사용자 토큰이 필요한 제공자 2개 (카카오는 관리자 키, Google·Apple 은 Firebase uid 로 해제)
    private static final Set<AuthProvider> TOKEN_REQUIRED_PROVIDERS = Set.of(AuthProvider.GITHUB, AuthProvider.NAVER);
    private static final String ASSOCIATED_DATA_PREFIX = "member_social_credential:";
    private static final String ACCESS_TOKEN_SUFFIX = ":access";
    private static final String REFRESH_TOKEN_SUFFIX = ":refresh";

    private final MemberSocialCredentialRepository memberSocialCredentialRepository;
    private final SecretValueCipher secretValueCipher;

    /** 대상 제공자만: 암호화 > 신규 저장 또는 갱신 (새 refresh 없으면 기존 유지) */
    @Transactional
    public void saveForUnlink(UUID memberUuid, AuthProvider authProvider, ProviderTokens tokens) {
        if (!TOKEN_REQUIRED_PROVIDERS.contains(authProvider) || tokens == null
                || tokens.accessToken() == null || tokens.accessToken().isBlank()) {
            return;
        }
        String encryptedAccessToken = secretValueCipher.encrypt(accessAssociatedDataOf(memberUuid), tokens.accessToken());
        String encryptedRefreshToken = tokens.hasRefreshToken()
                ? secretValueCipher.encrypt(refreshAssociatedDataOf(memberUuid), tokens.refreshToken())
                : null;

        Optional<MemberSocialCredential> existing = memberSocialCredentialRepository.findById(memberUuid);
        if (existing.isPresent()) {
            existing.get().replaceTokens(authProvider, encryptedAccessToken, encryptedRefreshToken);
            return;
        }
        memberSocialCredentialRepository.save(
                MemberSocialCredential.create(memberUuid, authProvider, encryptedAccessToken, encryptedRefreshToken));
    }

    /** 저장 자격 복호화 (없으면 empty) */
    public Optional<ProviderTokens> findTokens(UUID memberUuid) {
        return memberSocialCredentialRepository.findById(memberUuid)
                .map(credential -> new ProviderTokens(
                        secretValueCipher.decrypt(accessAssociatedDataOf(memberUuid), credential.getEncryptedAccessToken()),
                        credential.getEncryptedRefreshToken() == null ? null
                                : secretValueCipher.decrypt(refreshAssociatedDataOf(memberUuid), credential.getEncryptedRefreshToken())));
    }

    @Transactional
    public void deleteByMemberUuid(UUID memberUuid) {
        memberSocialCredentialRepository.deleteById(memberUuid);
    }

    private static String accessAssociatedDataOf(UUID memberUuid) {
        return ASSOCIATED_DATA_PREFIX + memberUuid + ACCESS_TOKEN_SUFFIX;
    }

    private static String refreshAssociatedDataOf(UUID memberUuid) {
        return ASSOCIATED_DATA_PREFIX + memberUuid + REFRESH_TOKEN_SUFFIX;
    }
}
