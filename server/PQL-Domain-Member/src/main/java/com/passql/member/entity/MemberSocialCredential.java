package com.passql.member.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.member.constant.AuthProvider;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

/**
 * 탈퇴 시 제공자 연결 해제용 자격 (#516): 회원 1명당 1행, 토큰은 암호문만 저장
 * 저장 대상: GITHUB(access), NAVER(access, refresh), 로그인마다 갱신, 연결 해제 후 삭제
 * PK = member.member_uuid (회원과 1:1 이라 별도 생성 UUID 없음)
 */
@Entity
@Table(name = "member_social_credential")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MemberSocialCredential extends BaseEntity {

    @Id
    @Column(updatable = false, nullable = false)
    private UUID memberUuid;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private AuthProvider authProvider;

    // SecretValueCipher 암호문 (enc:v1:...)
    @Column(columnDefinition = "TEXT", nullable = false)
    private String encryptedAccessToken;

    // 없으면 null (코드 방식 네이버만 채움)
    @Column(columnDefinition = "TEXT")
    private String encryptedRefreshToken;

    public static MemberSocialCredential create(UUID memberUuid, AuthProvider authProvider,
                                                String encryptedAccessToken, String encryptedRefreshToken) {
        MemberSocialCredential credential = new MemberSocialCredential();
        credential.memberUuid = memberUuid;
        credential.authProvider = authProvider;
        credential.encryptedAccessToken = encryptedAccessToken;
        credential.encryptedRefreshToken = encryptedRefreshToken;
        return credential;
    }

    /** 재로그인 갱신: access 교체, refresh 는 새 값 있을 때만 교체 */
    public void replaceTokens(AuthProvider authProvider, String encryptedAccessToken, String encryptedRefreshToken) {
        this.authProvider = authProvider;
        this.encryptedAccessToken = encryptedAccessToken;
        if (encryptedRefreshToken != null) {
            this.encryptedRefreshToken = encryptedRefreshToken;
        }
    }
}
