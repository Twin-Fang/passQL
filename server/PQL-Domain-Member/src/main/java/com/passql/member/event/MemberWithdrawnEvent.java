package com.passql.member.event;

import com.passql.member.constant.AuthProvider;

import java.util.UUID;

/**
 * 회원 탈퇴 커밋 후 제공자 연결 해제 요청 (#516): 익명화 전 제공자 키를 담음
 * providerUserId: 카카오 회원번호, 네이버·GitHub ID, Google·Apple 은 Firebase uid
 */
public record MemberWithdrawnEvent(UUID memberUuid, AuthProvider authProvider, String providerUserId) {
}
