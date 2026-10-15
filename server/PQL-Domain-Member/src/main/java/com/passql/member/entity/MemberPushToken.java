package com.passql.member.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.member.constant.PushPlatform;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 회원 기기 푸시 토큰: 기기 1대당 토큰 1건, 알림 수신 동의 여부
 * 같은 토큰이 다른 회원으로 등록되면 소유자 이전 (같은 기기 계정 전환)
 */
@Entity
@Table(
    name = "member_push_token",
    uniqueConstraints = @UniqueConstraint(name = "uk_member_push_token_token", columnNames = "token"),
    indexes = @Index(name = "idx_member_push_token_member", columnList = "member_uuid")
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MemberPushToken extends BaseEntity {

    // FCM 등록 토큰 최대 길이 (문자 수, 실제 약 160자)
    public static final int MAX_TOKEN_LENGTH = 512;

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID memberPushTokenUuid;

    @Column(nullable = false)
    private UUID memberUuid;

    @Column(length = MAX_TOKEN_LENGTH, nullable = false)
    private String token;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private PushPlatform platform;

    // 알림 수신 동의 (설정 화면 토글)
    @Column(nullable = false)
    private Boolean isPushEnabled;

    // 앱이 토큰을 마지막으로 등록·갱신한 시각
    @Column(nullable = false)
    private LocalDateTime lastRefreshedAt;

    /** 새 기기 토큰 (수신 동의 기본 켬) */
    public static MemberPushToken create(UUID memberUuid, String token, PushPlatform platform) {
        MemberPushToken pushToken = new MemberPushToken();
        pushToken.memberUuid = memberUuid;
        pushToken.token = token;
        pushToken.platform = platform;
        pushToken.isPushEnabled = true;
        pushToken.lastRefreshedAt = LocalDateTime.now();
        return pushToken;
    }

    public boolean isOwnedBy(UUID candidateMemberUuid) {
        return memberUuid.equals(candidateMemberUuid);
    }

    /** 다른 회원으로 소유자 이전 (수신 동의는 새 회원 기준 켬으로 초기화) */
    public void transferTo(UUID newMemberUuid) {
        this.memberUuid = newMemberUuid;
        this.isPushEnabled = true;
    }

    /** 등록 갱신: 플랫폼, 수신 동의 (null 이면 기존 값 유지), 갱신 시각 */
    public void refresh(PushPlatform platform, Boolean requestedPushEnabled) {
        this.platform = platform;
        if (requestedPushEnabled != null) {
            this.isPushEnabled = requestedPushEnabled;
        }
        this.lastRefreshedAt = LocalDateTime.now();
    }
}
