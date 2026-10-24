package com.passql.member.dto;

import com.passql.member.constant.AuthProvider;
import com.passql.member.constant.MemberRole;
import com.passql.member.constant.MemberStatus;
import com.passql.member.entity.Member;

import java.time.LocalDateTime;
import java.util.UUID;

public record MemberAdminListResponse(
    UUID memberUuid,
    String nickname,
    MemberStatus status,
    MemberRole role,
    AuthProvider authProvider,
    Boolean isTestAccount,
    LocalDateTime createdAt,
    LocalDateTime lastSeenAt,
    // 프로 이용 중 여부 (만료 전 PRO 등급)
    boolean isProActive
) {
    public static MemberAdminListResponse from(Member m, boolean isProActive) {
        return new MemberAdminListResponse(
            m.getMemberUuid(),
            m.getNickname(),
            m.getStatus(),
            m.getRole(),
            m.getAuthProvider(),
            m.getIsTestAccount(),
            m.getCreatedAt(),
            m.getLastSeenAt(),
            isProActive
        );
    }
}
