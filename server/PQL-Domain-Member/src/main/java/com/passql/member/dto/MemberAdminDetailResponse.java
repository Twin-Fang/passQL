package com.passql.member.dto;

import com.passql.member.constant.AuthProvider;
import com.passql.member.constant.MemberRole;
import com.passql.member.constant.MemberStatus;
import com.passql.member.entity.Member;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record MemberAdminDetailResponse(
    UUID memberUuid,
    String nickname,
    MemberStatus status,
    MemberRole role,
    AuthProvider authProvider,
    String providerUserId,
    String email,
    Boolean emailVerified,
    // 소셜 프로필 이미지 (없으면 null, #908)
    String profileImageUrl,
    Boolean isTestAccount,
    LocalDateTime createdAt,
    LocalDateTime lastSeenAt,
    String lastLoginIp,
    LocalDateTime suspendUntil,
    LocalDateTime withdrawnAt,
    String adminMemo,
    List<MemberSuspendHistoryResponse> suspendHistories
) {
    public static MemberAdminDetailResponse from(Member m, List<MemberSuspendHistoryResponse> histories) {
        return new MemberAdminDetailResponse(
            m.getMemberUuid(),
            m.getNickname(),
            m.getStatus(),
            m.getRole(),
            m.getAuthProvider(),
            m.getProviderUserId(),
            m.getEmail(),
            m.getEmailVerified(),
            m.getProfileImageUrl(),
            m.getIsTestAccount(),
            m.getCreatedAt(),
            m.getLastSeenAt(),
            m.getLastLoginIp(),
            m.getSuspendUntil(),
            m.getWithdrawnAt(),
            m.getAdminMemo(),
            histories
        );
    }
}
